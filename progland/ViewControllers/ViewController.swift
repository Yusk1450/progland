//
//  ViewController.swift
//  progland
//
//  Created by ISHIGO Yusuke on 2025/06/20.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController
{
	var isFreeMode = false
	
	var actionTimer:Timer?
	var carImages = [UIImageView]()
	
	@IBOutlet weak var connectingImageView: UIImageView!
	
	
	
	let disposeBag = DisposeBag()
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		
		let engine = ProglandEngine.shared
		
		engine.ip.asObservable()
			.observe(on: MainScheduler.instance)
			.skip(1)
			.subscribe(onNext: { [weak self] ip in
				guard let wself = self else { return }
				
				if (ip != "")
				{
					wself.connectingImageView.image = UIImage(named: "connecting")
				}
				
			}).disposed(by: self.disposeBag)

		
		self.generateTimerAction(timer: nil)
		self.actionTimer = Timer.scheduledTimer(timeInterval: 0.01,
												target: self,
												selector: #selector(self.actionTimerAction(timer:)),
												userInfo: nil,
												repeats: true)
	}
	
	@objc func actionTimerAction(timer:Timer)
	{
		for subview in self.view.subviews
		{
			if let car = subview as? UIImageView
			{
				if (car.tag == 101)
				{
					car.frame.origin.x = car.frame.origin.x - 1.0
					
					if (car.frame.origin.x < -car.frame.width)
					{
						car.removeFromSuperview()
					}
				}
				else if (car.tag == 102)
				{
					car.frame.origin.x = car.frame.origin.x + 1.0
					
					if (car.frame.origin.x > self.view.frame.width)
					{
						car.removeFromSuperview()
					}
				}
			}
		}
	}
	
	@objc func generateTimerAction(timer:Timer?)
	{
		let carIndex = Int.random(in: 1...4)
		if let img = UIImage(named: "car\(carIndex)")
		{
			let imgView = UIImageView(image: img)
			
			// 上
			if (Int.random(in: 0...5) <= 2)
			{
				imgView.transform = CGAffineTransform(scaleX: 1.0, y: -1.0)
				imgView.frame.origin = CGPoint(x: self.view.frame.size.width, y: 0.0)
				imgView.tag = 101
			}
			// 下
			else
			{
				imgView.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
				imgView.frame.origin = CGPoint(x: -img.size.height, y: self.view.frame.size.height - img.size.height)
				imgView.tag = 102
			}
			
			self.view.insertSubview(imgView, belowSubview: self.connectingImageView)
		}
		
		
		Timer.scheduledTimer(timeInterval: Double.random(in: 3.0...5.0),
							 target: self,
							 selector: #selector(self.generateTimerAction(timer:)),
							 userInfo: nil,
							 repeats: false)
	}
	
	@IBAction func freeBtnAction(_ sender: Any)
	{
		self.isFreeMode = true
		self.performSegue(withIdentifier: "toProgramming", sender: nil)
	}
	
	@IBAction func challengeBtnAction(_ sender: Any)
	{
		self.performSegue(withIdentifier: "toProgramming", sender: nil)
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?)
	{
		if let nextViewController = segue.destination as? CodingViewController
		{
			nextViewController.isFreeMode = self.isFreeMode
		}
	}

}

