//
//  MarkerSpeedSign.swift
//  progland
//
//  Created by ISHIGO Yusuke on 2025/08/07.
//

import UIKit
import RxSwift
import RxCocoa

class MarkerSpeedSign: MarkerBase
{
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
	}
	
	override func onCollision(marker: MarkerBase)
	{
		super.onCollision(marker: marker)
	}
	
}
