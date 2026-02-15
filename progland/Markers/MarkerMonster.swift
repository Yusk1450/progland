//
//  MarkerMonster.swift
//  progland
//
//  Created by ISHIGO Yusuke on 2025/08/07.
//

import UIKit
import RxSwift
import RxCocoa

class MarkerMonster: MarkerBase
{
	var speed = BehaviorRelay<Double>(value: 1.0)
	
	override init(image: UIImage?)
	{
		super.init(image: image)
		
		self.isMovableControl.accept(false)
	}

	@MainActor required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func run()
	{
		super.run()
		
		self.frame.origin.x = self.frame.origin.x - self.speed.value

		let screenSize = self.superview!.frame.size
		
		// 左端
		if (self.frame.origin.x < -self.frame.size.width)
		{
			self.frame.origin.x = screenSize.width
		}
	}
	


}
