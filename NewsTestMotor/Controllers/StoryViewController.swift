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
	
	var selectedStoryType: StoryType = .new {
		didSet {
			FirebaseDbManager.shared.fetchStory(type: selectedStoryType) { stories in
				self.stories = stories
				print("Fetched", stories.count)
			}
		}
	}
	
	var stories = [Story]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		initialSetupSegmentControl()
	}

	@IBAction func switchedStory(_ sender: UISegmentedControl) {
		if let storyType = StoryType(rawValue: sender.selectedSegmentIndex) {
			selectedStoryType = storyType
		}
	}
	
	func initialSetupSegmentControl() {
		for i in 0...2 {
			let storyType = StoryType(rawValue: i)
			segmentControl.setTitle(storyType?.description, forSegmentAt: i)
			if storyType == .new {
				selectedStoryType = .new
				segmentControl.selectedSegmentIndex = i
			}
		}
	}
}
