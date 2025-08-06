//
//  RoundView.swift
//  progland
//
//  Created by ISHIGO Yusuke on 2025/06/20.
//

import UIKit

class RoundView: UIView
{
	override func awakeFromNib()
	{
		self.layer.cornerRadius = 16.0
		self.layer.masksToBounds = true
	}
	
	
}
