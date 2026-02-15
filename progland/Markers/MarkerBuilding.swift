//
//  MarkerBuilding.swift
//  progland
//
//  Created by ISHIGO Yusuke on 2025/06/20.
//

import UIKit
import RxSwift
import RxCocoa

class MarkerBuilding: MarkerBase
{
	// 最大ライフ
	let maxLife = 2
	// 現在のライフ
	let life = BehaviorRelay<Int>(value: 2)
	
	// クールタイム
	let coolTime = BehaviorRelay<Int>(value: 50)
	
	override init(image: UIImage?)
	{
		super.init(image: image)
		
		self.isMovableControl.accept(false)
	}
	
	@MainActor required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func initParam()
	{
		self.life.accept(self.maxLife)
	}
	
	override func run()
	{
		super.run()
	}
	
	override func onCollision(marker: MarkerBase)
	{
		super.onCollision(marker: marker)
		
		// 建物同士は接触しない
		if (marker.markerTypeName!.contains("building"))
		{
			return
		}
		
		// 相手が怪獣の場合
		if let _ = marker as? MarkerMonster
		{
			if (self.coolTime.value == 200)
			{
				// 破壊コマンド
				ProglandEngine.shared.sendBuildingChangeMarkerCmd(buildingMarker: self)
				return
			}
			
			if (self.coolTime.value > 0)
			{
				self.coolTime.accept(self.coolTime.value - 1)
				return
			}
		}
		
		// ヘリの場合は接触しない
		if let copterMarker = marker as? MarkerCopter
		{
			if (self.objectHeight.value < copterMarker.objectHeight.value)
			{
				return
			}
			else
			{
				copterMarker.isHidden = true
			}
		}
		
		self.life.accept(self.life.value - 1)

		// 相手が車の場合
		if let _ = marker as? MarkerCar
		{
			marker.isHidden = true
		}
		
		if (self.life.value == 1)
		{
			// 破壊コマンド
			ProglandEngine.shared.sendBuildingChangeMarkerCmd(buildingMarker: self)
		}
		else if (self.life.value <= 0)
		{
			self.isHidden = true
		}
	}
}
