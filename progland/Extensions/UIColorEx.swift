//
//  UIColorEx.swift
//  friendme
//
//  Created by ISHIGO Yusuke on 2024/07/24.
//

import UIKit

extension UIColor {
	convenience init(hexString: String, alpha: CGFloat = 1.0) {
		// 不要なスペースや改行があれば除去
		let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
		// スキャナーオブジェクトの生成
		let scanner = Scanner(string: hexString)

		// 先頭(0番目)が#であれば無視させる
		if (hexString.hasPrefix("#")) {
			scanner.charactersToBeSkipped = CharacterSet(charactersIn: "#")
		}

		var color:Int64 = 0
		// 文字列内から16進数を探索し、Int64型で color変数に格納
		scanner.scanHexInt64(&color)

		let mask:Int = 0x000000FF
		let r = Int(color >> 16) & mask
		let g = Int(color >> 8) & mask
		let b = Int(color) & mask

		let red   = CGFloat(r) / 255.0
		let green = CGFloat(g) / 255.0
		let blue  = CGFloat(b) / 255.0

		self.init(red:red, green:green, blue:blue, alpha:alpha)
	}

	class func rgba(red: Int, green: Int, blue: Int, alpha: CGFloat) -> UIColor{
		return UIColor(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: alpha)
	}
}
