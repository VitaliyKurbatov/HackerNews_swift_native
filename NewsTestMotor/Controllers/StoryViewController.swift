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
	
	var currentStoryType: StoryType = .new {
		didSet {
			fetchStories(currentStoryType)
		}
	}
	
	var stories = [Story]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		initialSetupSegmentControl()
	}

	@IBAction func switchedStory(_ sender: UISegmentedControl) {
		if let storyType = StoryType(rawValue: sender.selectedSegmentIndex) {
			currentStoryType = storyType
		}
	}
	
	func initialSetupSegmentControl() {
		for i in 0...2 {
			let storyType = StoryType(rawValue: i)
			segmentControl.setTitle(storyType?.description, forSegmentAt: i)
			if storyType == .new {
				currentStoryType = .new
				segmentControl.selectedSegmentIndex = i
			}
		}
	}
	
	func fetchStories(_ type: StoryType) {
		FirebaseDbManager.shared.fetchStories(type: currentStoryType) { stories in
			self.stories = stories
			print("Fetched", stories.count)
		}
	}
}
