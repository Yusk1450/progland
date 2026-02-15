//
//  MarkerCopter.swift
//  progland
//
//  Created by ISHIGO Yusuke on 2025/08/07.
//

import UIKit
import RxSwift
import RxCocoa

class MarkerCopter: MarkerBase
{
	// ベース速度
	var speed = BehaviorRelay<Double>(value: 1.0)
	// 速度倍率
	var speedScale = BehaviorRelay<Double>(value: 1.0)
	
	
	
	override init(image: UIImage?)
	{
		super.init(image: image)
		
		self.isMovableControl.accept(true)
	}
	
	@MainActor required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func run()
	{
		super.run()
		
		// 右
		if (self.direction.value == 1)
		{
			self.frame.origin.x = self.frame.origin.x + self.speed.value * self.speedScale.value
		}
		// 下
		else if (self.direction.value == 2)
		{
			self.frame.origin.y = self.frame.origin.y + self.speed.value * self.speedScale.value
		}
		// 左
		else if (self.direction.value == 3)
		{
			self.frame.origin.x = self.frame.origin.x - self.speed.value * self.speedScale.value
		}
		// 上
		else if (self.direction.value == 4)
		{
			self.frame.origin.y = self.frame.origin.y - self.speed.value * self.speedScale.value
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
		
	}

}
