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
	@IBOutlet weak var tableView: UITableView!
	
	var currentStoryType: StoryType = .new {
		didSet {
			fetchStories(currentStoryType)
		}
	}
	
	var stories = [Story]() {
		didSet {
			tableView.reloadData()
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupTableView()
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
		}
	}
}

extension StoryViewController: UITableViewDataSource, UITableViewDelegate {
	func setupTableView() {
		tableView.register(UINib(nibName: "StoryTableViewCell", bundle: nil),
						   forCellReuseIdentifier: "\(StoryTableViewCell.self)")
		tableView.tableFooterView = UIView()
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return stories.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "\(StoryTableViewCell.self)", for: indexPath) as! StoryTableViewCell
		cell.configure(stories[indexPath.row])
		return cell
	}
}
