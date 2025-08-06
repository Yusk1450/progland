//
//  SaveViewController.swift
//  progland
//
//  Created by ISHIGO Yusuke on 2025/06/20.
//

import UIKit

class SaveViewController: UIViewController
{

    override func viewDidLoad()
	{
		super.viewDidLoad()
		
		self.view.backgroundColor = UIColor(hexString: "4B4B4B", alpha: 0.7)
		
	}
	
	override func viewDidAppear(_ animated: Bool)
	{
		super.viewDidAppear(animated)
		
	}
	
	@IBAction func noSaveBtnAction(_ sender: Any)
	{
		self.dismiss(animated: true, completion: nil)
	}
	
	@IBAction func yesSaveBtnAction(_ sender: Any)
	{
	}
	
}
