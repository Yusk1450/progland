//
//  ProglandEngine.swift
//  progland
//
//  Created by ISHIGO Yusuke on 2025/06/25.
//

import UIKit
import RxSwift
import RxCocoa
import OSCKit

protocol ProglandEngineDelegate: AnyObject
{
	func markerDidAdded(engine: ProglandEngine, marker: MarkerBase)
	func markerDidRemoved(engine: ProglandEngine, marker: MarkerBase)
}

extension ProglandEngineDelegate
{
	func markerDidAdded(engine: ProglandEngine, marker: MarkerBase) {}
	func markerDidRemoved(engine: ProglandEngine, marker: MarkerBase) {}
}

class ProglandEngine: NSObject
{
	public static let shared = ProglandEngine()
	
	weak var delegate: ProglandEngineDelegate?

	private let OscAddressReset = "/reset"
	private let OscAddressSignalState = "/signal"
	private let OscAddressCameraConnected = "/camera/app/check"
	private let OscAddressCameraConnectReceived = "/app/camera/check"

	var ip = BehaviorRelay<String>(value: "")
	let port:UInt16 = 8000
	
	private let oscServer:OSCUdpServer!
	
	var markers = [MarkerBase]()
	var startPositions = [String:CGPoint]()
	
	var isRunning = BehaviorRelay<Bool>(value: false)
	
	var timer:Timer?
	
	let disposeBag = DisposeBag()
	
	private override init()
	{
		self.oscServer = OSCUdpServer(port: self.port)

		super.init()
		
		self.oscServer.delegate = self
		
		do
		{
			try self.oscServer.startListening()
		}
		catch
		{
			print(error.localizedDescription)
		}
		
		self.isRunning.asObservable()
			.observe(on: MainScheduler.instance)
			.skip(1)
			.subscribe(onNext: { [weak self] isRunning in
				guard let wself = self else { return }
				
				if (isRunning)
				{
					wself.startPositions.removeAll()
					for marker in wself.markers
					{
						wself.startPositions[marker.uuid.uuidString] = marker.frame.origin
						marker.isUserInteractionEnabled = false
						marker.frameCount.accept(0)
						marker.isArrowShown.accept(false)
					}

					wself.timer = Timer.scheduledTimer(timeInterval: 0.01,
													   target: wself,
													   selector: #selector(wself.update),
													   userInfo: nil,
													   repeats: true)
				}
				else
				{
					wself.timer?.invalidate()
					
					for marker in wself.markers
					{
						marker.frame.origin = wself.startPositions[marker.uuid.uuidString]!
						
						marker.isHidden = false
						marker.isUserInteractionEnabled = true
					}
					
					wself.sendResetCmd()
				}
			})
			.disposed(by: self.disposeBag)
	}
	
	@objc func update()
	{
		for marker in self.markers
		{
			if (marker.isHidden)
			{
				continue
			}
			
			marker.run()
			
			// 当たり判定
			for otherMarker in self.markers
			{
				if marker !== otherMarker
				{
					let rect1 = CGRect(origin: marker.frame.origin, size: marker.frame.size)
					let rect2 = CGRect(origin: otherMarker.frame.origin, size: otherMarker.frame.size)
					if rect1.intersects(rect2)
					{
						marker.onCollision(marker: otherMarker)
					}
				}
			}
		}
	}
	
	func reset()
	{
		self.markers.removeAll()
		self.timer?.invalidate()
		self.isRunning.accept(false)
	}
	
	/* --------------------------------------------------------------
	 * マーカーを追加する
	 --------------------------------------------------------------*/
	func addMarker(_ marker: MarkerBase)
	{
		self.markers.append(marker)
		self.delegate?.markerDidAdded(engine: self, marker: marker)
	}
	
	/* --------------------------------------------------------------
	 * マーカーを削除する
	 --------------------------------------------------------------*/
	func removeMarker(_ marker: MarkerBase)
	{
		var idx = -1
		for i in stride(from: 0, to: self.markers.count, by: 1)
		{
			if (self.markers[i].uuid == marker.uuid)
			{
				idx = i
			}
		}
		
		if (idx != -1)
		{
			self.markers.remove(at: idx)
			
			self.delegate?.markerDidRemoved(engine: self, marker: marker)
		}
	}
	
	/* --------------------------------------------------------------
	 * 指定したマーカーが画面上にいくつあるかを返す
	 --------------------------------------------------------------*/
	func markerCount(markerTypeName: String) -> Int
	{
		var count = 0
		for marker in self.markers
		{
			if (marker.markerTypeName!.contains(markerTypeName))
			{
				count += 1
			}
		}
		return count
	}
	
	func markerExists(markerTypeName: String, index: Int) -> Bool
	{
		for marker in self.markers
		{
			if (marker.markerTypeName!.contains(markerTypeName) && marker.markerIndex == index)
			{
				return true
			}
		}
		return false
	}
	
	func sendSignalChangeMarkerCmd(signalMarker:MarkerSignal)
	{
		let client = OSCUdpClient(host: ip.value, port: self.port)
		if let message = try? OSCMessage(with: self.OscAddressSignalState, arguments: [signalMarker.markerIndex, signalMarker.signalState.value])
		{
			if let _ = try? client.send(message)
			{
				print("send signal state \(signalMarker.signalState.value)")
			}
		}
	}
	
	func sendResetCmd()
	{
		let client = OSCUdpClient(host: ip.value, port: self.port)
		if let message = try? OSCMessage(with: self.OscAddressReset, arguments: [])
		{
			if let _ = try? client.send(message)
			{
				print("reset")
			}
		}
	}
}

extension ProglandEngine: OSCUdpServerDelegate
{
	func server(_ server: OSCUdpServer, didReceivePacket packet: any OSCPacket, fromHost host: String, port: UInt16)
	{
		guard let message = packet as? OSCMessage else { return }
		
		print(message.addressPattern.fullPath)
		
		// カメラからの接続確認
		if (message.addressPattern.fullPath == self.OscAddressCameraConnected)
		{
			self.ip.accept(host)
			print(host)

			let client = OSCUdpClient(host: host, port: self.port)
			if let message = try? OSCMessage(with: self.OscAddressCameraConnectReceived, arguments: [])
			{
				if let _ = try? client.send(message)
				{
				}
			}
		}
	}
	
	func server(_ server: OSCUdpServer, socketDidCloseWithError error: (any Error)?)
	{
	}
	
	func server(_ server: OSCUdpServer, didReadData data: Data, with error: any Error)
	{
	}

}
