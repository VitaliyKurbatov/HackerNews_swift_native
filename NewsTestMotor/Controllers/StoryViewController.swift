//
//  StoryViewController.swift
//  NewsTestMotor
//
//  Created by Vitaliy on 31.03.2020.
//  Copyright © 2020 Vitaliy. All rights reserved.
//

import UIKit
import FirebaseDatabase

class StoryViewController: UIViewController {
	@IBOutlet weak var segmentControl: UISegmentedControl!
	
	var storyTypes = [StoryType]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupSegmentControl()
		//FirebaseDbManager.shared.download()
	}

	@IBAction func switchedStory(_ sender: UISegmentedControl) {
		print(sender.selectedSegmentIndex)
	}
	
	func setupSegmentControl() {
		for i in 1...3 {
			if let storyType = StoryType(rawValue: i) {
				storyTypes.append(storyType)
				segmentControl.setTitle(storyType.description, forSegmentAt: i - 1)
			}
		}
	}
}
