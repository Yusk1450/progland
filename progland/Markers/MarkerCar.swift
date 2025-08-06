//
//  MarkerCar.swift
//  progland
//
//  Created by ISHIGO Yusuke on 2025/06/27.
//

import UIKit
import RxSwift
import RxCocoa

class MarkerCar: MarkerBase
{
	var isStopStatus = BehaviorRelay<Bool>(value: false)
	
	var speed = BehaviorRelay<Double>(value: 1.0)
	
	override init(image: UIImage?)
	{
		super.init(image: image)
		
		self.isMovable.accept(true)
	}
	
	@MainActor required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func run()
	{
		super.run()
		
		if (self.isStopStatus.value)
		{
			return
		}
		
		// 右
		if (self.direction.value == 1)
		{
			self.frame.origin.x = self.frame.origin.x + self.speed.value
		}
		// 下
		else if (self.direction.value == 2)
		{
			self.frame.origin.y = self.frame.origin.y + self.speed.value
		}
		// 左
		else if (self.direction.value == 3)
		{
			self.frame.origin.x = self.frame.origin.x - self.speed.value
		}
		// 上
		else if (self.direction.value == 4)
		{
			self.frame.origin.y = self.frame.origin.y - self.speed.value
		}
		
		let screenSize = self.superview!.frame.size

		// 左端
		if (self.frame.origin.x < -self.frame.size.width)
		{
			self.frame.origin.x = screenSize.width
		}
		// 右端
		if (self.frame.origin.x > screenSize.width)
		{
			self.frame.origin.x = -self.frame.size.width
		}
		// 上端
		if (self.frame.origin.y < -self.frame.size.height)
		{
			self.frame.origin.y = screenSize.height
		}
		// 下端
		if (self.frame.origin.y > screenSize.height)
		{
			self.frame.origin.y = -self.frame.size.height
		}
	}
	
	override func onCollision(marker: MarkerBase)
	{
		if let signalMarker = marker as? MarkerSignal
		{
			if (signalMarker.signalState.value == 3)
			{
				self.isStopStatus.accept(true)
			}
			else
			{
				self.isStopStatus.accept(false)
			}
		}
	}
}
