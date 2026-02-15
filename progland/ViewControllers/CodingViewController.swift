//
//  CodingViewController.swift
//  progland
//
//  Created by ISHIGO Yusuke on 2025/06/20.
//

import UIKit
import RxSwift
import RxCocoa

class CodingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
	@IBOutlet weak var saveBtn: UIButton!
	@IBOutlet weak var loadBtn: UIButton!
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var playBtn: UIButton!
	@IBOutlet weak var backBtn: UIButton!
	
	@IBOutlet weak var bgView: UIImageView!
	
	@IBOutlet weak var mustMarkerImageView1: UIImageView!
	@IBOutlet weak var mustMarkerImageView2: UIImageView!
	@IBOutlet weak var mustMarkerImageView3: UIImageView!
	
	var draggingImageView: MarkerBase?
	var markerListEnabled = [Bool]()

	var isFreeMode = false
	
	var blackView:UIView?
	@IBOutlet weak var challengeReadView: UIView!
	
	var disposeBag = DisposeBag()
	
	var markerList = [
		"category_building",
		"marker_building1_1",
		"marker_building2_1",
		"marker_building3_1",
		"marker_building4_1",
		"category_move",
		"marker_car1_1",
		"marker_car2_1",
		"marker_car3_1",
		"marker_car4_1",
		"marker_copter1_1",
		"marker_monster1_1",
		"category_control",
		"marker_signal1_1",
		"marker_speedsign1_1"
	]
	
    override func viewDidLoad()
	{
        super.viewDidLoad()
		
		// 挑戦モード
		if (!self.isFreeMode)
		{
			markerList.removeAll(where: {$0 == "marker_monster1_1"})

			self.challengeReadView.isHidden = false
			
			self.blackView = UIView(frame: self.view.frame)
			self.blackView?.backgroundColor = UIColor.black
			self.blackView?.alpha = 0.5
			
			self.view.insertSubview(blackView!, belowSubview: self.challengeReadView)
			
			// 怪獣マーカーを追加する
			self.addMarker(markerName: "marker_monster1_1")
			
			let mustMarkerImageViews = [self.mustMarkerImageView1, self.mustMarkerImageView2, self.mustMarkerImageView3]
			for i in stride(from: 0, to: 3, by: 1)
			{
				let marker = MarkerBase.createRandomMarker()!

				// すでに登録されているマーカーは採用しない
				if ProglandEngine.shared.markers.contains(where: { $0.markerTypeName == marker.markerTypeName }) {
					continue
				}

				mustMarkerImageViews[i]?.image = marker.image
				self.addMarker(markerName: "marker_\(marker.markerTypeName!)_1")
			}
		}
		
		for _ in markerList
		{
			self.markerListEnabled.append(true)
		}
		
		self.bgView.isUserInteractionEnabled = false
		
		ProglandEngine.shared.isRunning.asObservable()
			.observe(on: MainScheduler.instance)
			.skip(1)
			.subscribe(onNext: { [weak self] isRunning in
				guard let wself = self else { return }
				
				if (isRunning)
				{
					UIView.animate(withDuration: 0.7) {
						
//						wself.saveBtn.alpha = 0.0
//						wself.loadBtn.alpha = 0.0
						wself.tableView.alpha = 0.0
						wself.playBtn.alpha = 0.0
						wself.backBtn.alpha = 0.0
						
					} completion: { isFinished in
						if (isFinished)
						{
//							wself.saveBtn.isHidden = true
//							wself.loadBtn.isHidden = true
							wself.tableView.isHidden = true
							wself.playBtn.isHidden = true
							wself.backBtn.isHidden = true
						}
					}
				}
				else
				{
//					wself.saveBtn.isHidden = false
//					wself.loadBtn.isHidden = false
					wself.tableView.isHidden = false
					wself.playBtn.isHidden = false
					wself.backBtn.isHidden = false
					
					UIView.animate(withDuration: 0.7) {
						
						wself.saveBtn.alpha = 1.0
						wself.loadBtn.alpha = 1.0
						wself.tableView.alpha = 1.0
						wself.playBtn.alpha = 1.0
						wself.backBtn.alpha = 1.0
						
					} completion: { isFinished in
						if (isFinished)
						{
						}
					}

				}
				
			})
			.disposed(by: self.disposeBag)
		
    }
	
	override func viewDidAppear(_ animated: Bool)
	{
		super.viewDidAppear(animated)
		ProglandEngine.shared.delegate = self
	}
	
	override func viewDidDisappear(_ animated: Bool)
	{
		super.viewDidDisappear(animated)
		
		ProglandEngine.shared.reset()
		ProglandEngine.shared.delegate = nil
	}
	
	@IBAction func backBtnAction(_ sender: Any)
	{
		self.dismiss(animated: true)
	}
	
	@IBAction func readBtnAction(_ sender: Any)
	{
		self.blackView?.removeFromSuperview()
		self.challengeReadView.removeFromSuperview()
	}
	
	@IBAction func playBtnAction(_ sender: Any)
	{
		ProglandEngine.shared.isRunning.accept(true)
		self.bgView.isUserInteractionEnabled = true
	}
	
	@IBAction func saveBtnAction(_ sender: Any)
	{
		self.performSegue(withIdentifier: "toSave", sender: nil)
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
	{
		guard let touch = touches.first else { return }

		if (touch.view == self.bgView)
		{
			if (ProglandEngine.shared.isRunning.value)
			{
				ProglandEngine.shared.isRunning.accept(false)
				self.bgView.isUserInteractionEnabled = false
			}
		}
	}
		
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
	{
		if (self.markerList[indexPath.row].contains("category_"))
		{
			return 110.0
		}
		return 204.0
	}
	
	func numberOfSections(in tableView: UITableView) -> Int
	{
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return self.markerList.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		var identifier = "cell"
		
		if (self.markerList[indexPath.row].contains("category_"))
		{
			identifier = "category_cell"
		}
		
		var cell = tableView.dequeueReusableCell(withIdentifier: identifier)

		if (cell == nil)
		{
			cell = UITableViewCell(style: .default, reuseIdentifier: identifier)
		}

		cell?.selectionStyle = .none
		cell?.backgroundColor = .clear
		
		let imgName = self.markerList[indexPath.row]
		
		if (self.markerList[indexPath.row].contains("marker_"))
		{
			let cellEnabled = self.markerListEnabled[indexPath.row]
			
			let imgView = cell?.viewWithTag(100) as? MarkerCellImageView
			imgView?.delegate = self
			imgView?.image = UIImage(named: imgName)
			imgView?.markerName = imgName
			imgView?.isUserInteractionEnabled = true
			imgView?.alpha = 1.0

			if (imgName.contains("category_"))
			{
				imgView?.isUserInteractionEnabled = false
			}
			
			if (!cellEnabled)
			{
				imgView?.alpha = 0.5
				imgView?.isUserInteractionEnabled = false
			}
		}
		else if (self.markerList[indexPath.row].contains("category_"))
		{
			let imgView = cell?.viewWithTag(100) as? UIImageView
			imgView?.image = UIImage(named: imgName)
		}

		return cell!
	}

	/*
	 * マーカーの初期設定
	 */
	func addMarker(markerName:String)
	{
		var markerTypeName = markerName.replacingOccurrences(of: "marker_", with: "")
		markerTypeName = markerTypeName.replacingOccurrences(of: "_1", with: "")
		markerTypeName = markerTypeName.replacingOccurrences(of: "_2", with: "")

		let markerImage = UIImage(named: "marker_\(markerTypeName)_1")
		
		guard let markerImage = markerImage else { return }
		
		if let markerImageView = MarkerBase.createMarker(markerTypeName: markerTypeName, markerImage: markerImage)
		{
//			markerImageView.markerTypeName = markerTypeName
			markerImageView.markerIndex = 1
			markerImageView.frame = CGRect(
				x: CGFloat.random(in: 0...max(0, self.view.bounds.size.width - markerImage.size.width)),
				y: CGFloat.random(in: 0...max(0, self.view.bounds.size.height - markerImage.size.height)),
				width: 182.4,
				height: 182.4
			)
			
			if let blackView = self.blackView
			{
				self.view.insertSubview(markerImageView, aboveSubview: blackView)
				ProglandEngine.shared.addMarker(markerImageView)
			}
		}
	}


}

extension CodingViewController : ProglandEngineDelegate
{
	/* --------------------------------------------------------------
	 * マーカーが追加されたとき
	 -------------------------------------------------------------- */
	func markerDidAdded(engine: ProglandEngine, marker: MarkerBase)
	{
	}
	
	/* --------------------------------------------------------------
	 * マーカーが削除されたとき
	 -------------------------------------------------------------- */
	func markerDidRemoved(engine: ProglandEngine, marker: MarkerBase)
	{
		guard let markerTypeName = marker.markerTypeName else { return }
		
		marker.removeFromSuperview()
				
		if (ProglandEngine.shared.markerCount(markerTypeName: markerTypeName) < 2)
		{
			if let idx = self.markerList.firstIndex(of: "marker_\(markerTypeName)_1")
			{
				self.markerListEnabled[idx] = true
				self.tableView.reloadData()
			}
		}
	}
}

extension CodingViewController : MarkerCellImageDelegate
{
	func markerCellImageDidDragStart(markerCellImage: MarkerCellImageView, location: CGPoint)
	{
		var markerTypeName = markerCellImage.markerName.replacingOccurrences(of: "marker_", with: "")
		markerTypeName = markerTypeName.replacingOccurrences(of: "_1", with: "")
		markerTypeName = markerTypeName.replacingOccurrences(of: "_2", with: "")
		
		var markerImage: UIImage?
		var markerIndex = 1
		
		// 1が存在するかどうか
		if (ProglandEngine.shared.markerExists(markerTypeName: markerTypeName, index: 1))
		{
			markerImage = UIImage(named: "marker_\(markerTypeName)_2")
			markerIndex = 2
		}
		// 2が存在するかどうか
		else if (ProglandEngine.shared.markerExists(markerTypeName: markerTypeName, index: 2))
		{
			markerImage = UIImage(named: "marker_\(markerTypeName)_1")
			markerIndex = 1
		}
		// 初回
		else
		{
			markerImage = UIImage(named: "marker_\(markerTypeName)_1")
			markerIndex = 1
		}
		
		guard let markerImage = markerImage else { return }
		
		self.draggingImageView = MarkerBase.createMarker(markerTypeName: markerTypeName, markerImage: markerImage)
		self.draggingImageView?.markerTypeName = markerTypeName
		self.draggingImageView?.markerIndex = markerIndex
		self.draggingImageView?.frame = markerCellImage.convert(markerCellImage.bounds, to: self.view)
		self.draggingImageView?.alpha = 0.5
		self.view.addSubview(self.draggingImageView!)
	}
	
	func markerCellImageDidDragChange(markerCellImage: MarkerCellImageView, location: CGPoint)
	{
		guard let draggingImageView = self.draggingImageView else { return }
		draggingImageView.center = location
	}
	
	func markerCellImageDidDragStop(markerCellImage: MarkerCellImageView, location: CGPoint)
	{
		guard let draggingImageView = self.draggingImageView else { return }
		guard let markerTypeName = draggingImageView.markerTypeName else { return }
		
		UIView.animate(withDuration: 0.2) {
			draggingImageView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
			draggingImageView.alpha = 1.0
		}
		
		ProglandEngine.shared.addMarker(draggingImageView)
		
		// 場に展開しているマーカーが最大数を超えた場合
		let maxNum = 2
//		print(ProglandEngine.shared.markerCount(markerTypeName: markerTypeName))

		if (ProglandEngine.shared.markerCount(markerTypeName: markerTypeName) >= maxNum)
		{
			if let idx = self.markerList.firstIndex(of: "marker_\(markerTypeName)_1")
			{
				self.markerListEnabled[idx] = false
				self.tableView.reloadData()
			}
			if let idx = self.markerList.firstIndex(of: "marker_\(markerTypeName)")
			{
				self.markerListEnabled[idx] = false
				self.tableView.reloadData()
			}
		}

		self.draggingImageView = nil
	}
}
