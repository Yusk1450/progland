//
//  MarkerBase.swift
//  progland
//
//  Created by ISHIGO Yusuke on 2025/06/20.
//

import UIKit
import RxSwift
import RxCocoa

class MarkerBase: UIImageView
{
	// マーカー種類名
	var markerTypeName:String?
	// マーカー固有番号
	let uuid = UUID()
	// マーカー
	var markerIndex = -1
	// 必須マーカーかどうか
	var isMustMarker = false
	
	// 移動体かどうか
	var isMovable = BehaviorRelay<Bool>(value: false)
	// 移動制御可能か
	var isMovableControl = BehaviorRelay<Bool>(value: false)
	// スルーするかどうか
	var isThroughObject = BehaviorRelay<Bool>(value: false)

	// オブジェクトの高さ
	let objectHeight = BehaviorRelay<Int>(value: 0)
	
	// 矢印表示
	var isArrowShown = BehaviorRelay<Bool>(value: false)
	var rightBtn: UIImageView?
	var leftBtn: UIImageView?
	var upBtn: UIImageView?
	var downBtn: UIImageView?
	
	// マーカー削除時の処理
	let didRemoveMarkerSubject = PublishSubject<Void>()
	
	// 方向
	// 右1、下2、左3、上4
	var direction = BehaviorRelay<Int>(value: 3)
	// フレームカウント
	var frameCount = BehaviorRelay<Int>(value: 0)
	
	let disposeBag = DisposeBag()
	
	/* --------------------------------------------------------------
	 * コンストラクタ
	 -------------------------------------------------------------- */
	override init(image: UIImage?)
	{
		super.init(image: image)

		self.isUserInteractionEnabled = true
		
		let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.onLongPress(gestureRecognizer:)))
		self.addGestureRecognizer(longPressGestureRecognizer)

		self.didRemoveMarkerSubject.asObservable()
			.observe(on: MainScheduler.instance)
			.subscribe(onNext: { [weak self] () in
				guard let wself = self else { return }
				
				wself.upBtn?.removeFromSuperview()
				wself.downBtn?.removeFromSuperview()
				wself.leftBtn?.removeFromSuperview()
				wself.rightBtn?.removeFromSuperview()
				
			})
			.disposed(by: self.disposeBag)
	}
	
	func setupGesture()
	{
		if (!self.isMovableControl.value)
		{
			return
		}
		
		let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.onSingleTap(gestureRecognizer:)))
		self.addGestureRecognizer(singleTapGestureRecognizer)
		
		self.direction.asObservable()
			.observe(on: MainScheduler.instance)
			.skip(1)
			.subscribe(onNext: { [weak self] direction in
				guard let wself = self else { return }
				
				// 右
				if (direction == 1)
				{
					wself.transform = CGAffineTransformMakeRotation(Double.pi).scaledBy(x: 1.2, y: 1.2)
				}
				// 下
				else if (direction == 2)
				{
					wself.transform = CGAffineTransformMakeRotation(-Double.pi/2).scaledBy(x: 1.2, y: 1.2)
				}
				// 左
				else if (direction == 3)
				{
					wself.transform = CGAffineTransformMakeScale(1.2, 1.2)
				}
				// 上
				else if (direction == 4)
				{
					wself.transform = CGAffineTransformMakeRotation(Double.pi/2).scaledBy(x: 1.2, y: 1.2)
				}
				
			}).disposed(by: self.disposeBag)
		
		self.isArrowShown.asObservable()
			.observe(on: MainScheduler.instance)
			.skip(1)
			.subscribe(onNext: { [weak self] isShown in
				guard let wself = self else { return }
				
				if (isShown)
				{
					let padding = 20.0
					
					// 上矢印
					let upbtnSize = CGSize(width: 96.0, height: 208.0)
					wself.upBtn = UIImageView(frame: CGRect(x: (wself.frame.origin.x + wself.frame.size.width / 2) - upbtnSize.width / 2,
														 y: ((wself.frame.origin.y + wself.frame.size.height / 2) - upbtnSize.height) - padding,
														 width: upbtnSize.width,
														 height: upbtnSize.height))
					wself.upBtn?.image = wself.direction.value == 4 ? UIImage(named: "uparrow") : UIImage(named: "uparrow_off")
					wself.upBtn?.isUserInteractionEnabled = true
					let upTapGestureRecognizer = UITapGestureRecognizer(target: wself, action: #selector(wself.onArrowTap(gestureRecognizer:)))
					wself.upBtn?.addGestureRecognizer(upTapGestureRecognizer)
					wself.superview?.addSubview(wself.upBtn!)
					
					// 下矢印
					let downbtnSize = CGSize(width: 96.0, height: 208.0)
					wself.downBtn = UIImageView(frame: CGRect(x: (wself.frame.origin.x + wself.frame.size.width / 2) - downbtnSize.width / 2,
														  y: (wself.frame.origin.y + wself.frame.size.height / 2) + padding,
														  width: downbtnSize.width,
														  height: downbtnSize.height))
					wself.downBtn?.image = wself.direction.value == 2 ? UIImage(named: "downarrow") : UIImage(named: "downarrow_off")
					wself.downBtn?.isUserInteractionEnabled = true
					let downTapGestureRecognizer = UITapGestureRecognizer(target: wself, action: #selector(wself.onArrowTap(gestureRecognizer:)))
					wself.downBtn?.addGestureRecognizer(downTapGestureRecognizer)
					wself.superview?.addSubview(wself.downBtn!)
					
					// 左矢印
					let leftbtnSize = CGSize(width: 208.0, height: 96.0)
					wself.leftBtn = UIImageView(frame: CGRect(x: ((wself.frame.origin.x + wself.frame.size.width / 2) - leftbtnSize.width) - padding,
															y: (wself.frame.origin.y + wself.frame.size.height / 2) - leftbtnSize.height / 2,
															width: leftbtnSize.width,
															height: leftbtnSize.height))
					wself.leftBtn?.image = wself.direction.value == 3 ? UIImage(named: "leftarrow") : UIImage(named: "leftarrow_off")
					wself.leftBtn?.isUserInteractionEnabled = true
					let leftTapGestureRecognizer = UITapGestureRecognizer(target: wself, action: #selector(wself.onArrowTap(gestureRecognizer:)))
					wself.leftBtn?.addGestureRecognizer(leftTapGestureRecognizer)
					wself.superview?.addSubview(wself.leftBtn!)

					// 右矢印
					let rightbtnSize = CGSize(width: 208.0, height: 96.0)
					wself.rightBtn = UIImageView(frame: CGRect(x: (wself.frame.origin.x + wself.frame.size.width / 2) + padding,
															 y: (wself.frame.origin.y + wself.frame.size.height / 2) - rightbtnSize.height / 2,
															 width: rightbtnSize.width,
															 height: rightbtnSize.height))
					wself.rightBtn?.image = wself.direction.value == 1 ? UIImage(named: "rightarrow") : UIImage(named: "rightarrow_off")
					wself.rightBtn?.isUserInteractionEnabled = true
					let rightTapGestureRecognizer = UITapGestureRecognizer(target: wself, action: #selector(wself.onArrowTap(gestureRecognizer:)))
					wself.rightBtn?.addGestureRecognizer(rightTapGestureRecognizer)
					wself.superview?.addSubview(wself.rightBtn!)
				}
				else
				{
					wself.rightBtn?.removeFromSuperview()
					wself.leftBtn?.removeFromSuperview()
					wself.upBtn?.removeFromSuperview()
					wself.downBtn?.removeFromSuperview()
					
					wself.rightBtn = nil
					wself.leftBtn = nil
					wself.upBtn = nil
					wself.downBtn = nil
				}
				
			}).disposed(by: self.disposeBag)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func initParam()
	{
	}
	
	/* --------------------------------------------------------------
	 * 矢印をタップしたとき
	 -------------------------------------------------------------- */
	@objc func onArrowTap(gestureRecognizer: UITapGestureRecognizer)
	{
		self.rightBtn?.image = UIImage(named: "rightarrow_off")
		self.leftBtn?.image = UIImage(named: "leftarrow_off")
		self.upBtn?.image = UIImage(named: "uparrow_off")
		self.downBtn?.image = UIImage(named: "downarrow_off")
		
		let btn = gestureRecognizer.view as! UIImageView
		// 右
		if (self.rightBtn == btn)
		{
			self.rightBtn?.image = UIImage(named: "rightarrow")
			self.direction.accept(1)
		}
		// 下
		else if (self.downBtn == btn)
		{
			self.downBtn?.image = UIImage(named: "downarrow")
			self.direction.accept(2)
		}
		// 左
		else if (self.leftBtn == btn)
		{
			self.leftBtn?.image = UIImage(named: "leftarrow")
			self.direction.accept(3)
		}
		// 上
		else if (self.upBtn == btn)
		{
			self.upBtn?.image = UIImage(named: "uparrow")
			self.direction.accept(4)
		}
	}
	
	@objc func onSingleTap(gestureRecognizer: UITapGestureRecognizer)
	{
		self.isArrowShown.accept(!self.isArrowShown.value)
	}
	
	/* --------------------------------------------------------------
	 * 長押しの処理
	 -------------------------------------------------------------- */
	@objc func onLongPress(gestureRecognizer: UILongPressGestureRecognizer)
	{
		UIView.animate(withDuration: 0.7) {
			
			self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
			self.alpha = 0
			
		} completion: { isFinished in
			if (isFinished)
			{
				self.didRemoveMarkerSubject.onNext(())
				self.didRemoveMarkerSubject.onCompleted()
				
				// マーカーを削除する
				ProglandEngine.shared.removeMarker(self)
			}
		}

	}
	
	/* --------------------------------------------------------------
	 * ドラッグアンドドロップ
	 -------------------------------------------------------------- */
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
	{
		guard let touch = touches.first else { return }
		guard let superview = superview else { return }
				
		self.isArrowShown.accept(false)
		
		self.center = touch.location(in: superview)
	}
	
	/* --------------------------------------------------------------
	 * ランダムにマーカーを作成する
	 -------------------------------------------------------------- */
	class func createRandomMarker() -> MarkerBase?
	{
		// "monster1"を除外する
		let availableTypes = MarkerTypeName.allCases.filter { $0 != .monster1 }
		guard let markerType = availableTypes.randomElement(),
			  let markerImage = UIImage(named: "marker_\(markerType.rawValue)_1") else
		{
			return nil
		}
		
		return createMarker(markerTypeName: markerType.rawValue, markerImage: markerImage)
	}
	
	class func createMarker(markerTypeName: String, markerImage: UIImage) -> MarkerBase?
	{
		var marker: MarkerBase?
				
		// 建物
		if (markerTypeName.contains("building"))
		{
			let buildingMarker = MarkerBuilding(image: markerImage)
			
			if (markerTypeName.contains("building1"))
			{
				buildingMarker.objectHeight.accept(10)
			}
			else if (markerTypeName.contains("building2"))
			{
				buildingMarker.objectHeight.accept(20)
			}
			else if (markerTypeName.contains("building3"))
			{
				buildingMarker.objectHeight.accept(30)
			}
			else if (markerTypeName.contains("building4"))
			{
				buildingMarker.objectHeight.accept(40)
			}
			
			marker = buildingMarker
		}
		// 車
		else if (markerTypeName.contains("car"))
		{
			let carMarker = MarkerCar(image: markerImage)
			
			if (markerTypeName.contains("car1"))
			{
				carMarker.speedScale.accept(1.0)
			}
			else if (markerTypeName.contains("car2"))
			{
				carMarker.speedScale.accept(5.0)
			}
			else if (markerTypeName.contains("car3"))
			{
				carMarker.speedScale.accept(2.0)
			}
			else if (markerTypeName.contains("car4"))
			{
				carMarker.speedScale.accept(3.0)
			}
			
			marker = carMarker
		}
		// 信号
		else if (markerTypeName.contains("signal"))
		{
			marker = MarkerSignal(image: markerImage)
		}
		// ヘリコプター
		else if (markerTypeName.contains("copter"))
		{
			let copterMarker = MarkerCopter(image: markerImage)
			copterMarker.objectHeight.accept(25)
			
			marker = copterMarker
		}
		// 怪獣
		else if (markerTypeName.contains("monster"))
		{
			marker = MarkerMonster(image: markerImage)
		}
		// 速度標識
		else if (markerTypeName.contains("speedsign"))
		{
			marker = MarkerSpeedSign(image: markerImage)
		}
		
		marker?.setupGesture()
		marker?.markerTypeName = markerTypeName
		
		return marker
	}
	
	func run()
	{
		self.frameCount.accept(self.frameCount.value + 1)
	}
	
	func onCollision(marker: MarkerBase)
	{
		// マーカーをスルーするかどうか
		if (marker.isThroughObject.value)
		{
			
		}
	}
}
