//
//  MarkerSignal.swift
//  progland
//
//  Created by ISHIGO Yusuke on 2025/06/27.
//

import UIKit
import RxSwift
import RxCocoa

class MarkerSignal: MarkerBase
{
	// 青:1、黄:2、赤:3
	var signalState = BehaviorRelay<Int>(value: 1)
	
	override init(image: UIImage?)
	{
		super.init(image: image)
		
		self.isMovableControl.accept(false)
				
		self.signalState.asObservable()
			.observe(on: MainScheduler.instance)
			.skip(1)
			.subscribe(onNext: { [weak self] signalState in
				guard let wself = self else { return }
								
				ProglandEngine.shared.sendSignalChangeMarkerCmd(signalMarker: wself)
				
				if (wself.signalState.value == 1)
				{
					print("青")
				}
				else if (wself.signalState.value == 2)
				{
					print("黄色")
				}
				else if (wself.signalState.value == 3)
				{
					print("赤")
				}
			})
			.disposed(by: self.disposeBag)
		
		self.frameCount.asObservable()
			.observe(on: MainScheduler.instance)
			.subscribe(onNext: { [weak self] frameCount in
				guard let wself = self else { return }
				
				if (frameCount % 1000 == 999)
				{
					let state = wself.signalState.value
					if (state >= 3)
					{
						wself.signalState.accept(1)
					}
					else
					{
						wself.signalState.accept(state + 1)
					}
					
				}
			})
			.disposed(by: self.disposeBag)
	}
	
	@MainActor required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func run()
	{
		super.run()
	}
}
