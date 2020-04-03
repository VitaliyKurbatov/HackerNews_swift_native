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
	
	let availableStoriesTypes: [StoryType] = [.new, .top, .best]
	
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
		for (index, type) in availableStoriesTypes.enumerated() {
			segmentControl.setTitle(type.description, forSegmentAt: index)
			if type == .new {
				currentStoryType = .new
				segmentControl.selectedSegmentIndex = index
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
		let nib = UINib(nibName: "\(StoryTableViewCell.self)", bundle: nil)
		tableView.register(nib, forCellReuseIdentifier: StoryTableViewCell.reuseId)
		tableView.tableFooterView = UIView()
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return stories.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: StoryTableViewCell.reuseId, for: indexPath) as! StoryTableViewCell
		cell.configure(story: stories[indexPath.row])
		return cell
	}
}
