//
//  MarkerBuilding.swift
//  progland
//
//  Created by ISHIGO Yusuke on 2025/06/20.
//

import UIKit

class MarkerBuilding: MarkerBase
{
	override init(image: UIImage?)
	{
		super.init(image: image)
		
		self.isMovable.accept(false)
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
		// 建物同士は接触しない
		if (marker.markerTypeName!.contains("building"))
		{
			return
		}
		
		self.isHidden = true
		marker.isHidden = true
	}
}
