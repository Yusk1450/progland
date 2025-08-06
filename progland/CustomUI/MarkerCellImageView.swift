//
//  MarkerCellImage.swift
//  progland
//
//  Created by ISHIGO Yusuke on 2025/06/22.
//

import UIKit

protocol MarkerCellImageDelegate: AnyObject
{
	func markerCellImageDidDragStart(markerCellImage: MarkerCellImageView, location:CGPoint)
	func markerCellImageDidDragChange(markerCellImage: MarkerCellImageView, location:CGPoint)
	func markerCellImageDidDragStop(markerCellImage: MarkerCellImageView, location:CGPoint)
}

class MarkerCellImageView: UIImageView
{
	weak var delegate: MarkerCellImageDelegate?
	var markerName = ""
	
	override func awakeFromNib()
	{
		self.isUserInteractionEnabled = true
		let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.panGesture(gestureRecognizer:)))
		self.addGestureRecognizer(panGestureRecognizer)
	}
		
	@objc func panGesture(gestureRecognizer: UIPanGestureRecognizer)
	{
		let locationInView = gestureRecognizer.location(in: self.window)
		
		switch (gestureRecognizer.state)
		{
			case .began:
				self.delegate?.markerCellImageDidDragStart(markerCellImage: self, location: locationInView)
			case .changed:
				self.delegate?.markerCellImageDidDragChange(markerCellImage: self, location: locationInView)
			case .ended:
				self.delegate?.markerCellImageDidDragStop(markerCellImage: self, location: locationInView)
			default:
				break
		}
	}
	
}
