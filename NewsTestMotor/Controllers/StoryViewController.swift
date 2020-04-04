//
//  StoryViewController.swift
//  NewsTestMotor
//
//  Created by Vitaliy on 31.03.2020.
//  Copyright © 2020 Vitaliy. All rights reserved.
//

import UIKit

class StoryViewController: UIViewController {
	@IBOutlet weak var segmentControl: UISegmentedControl!
	@IBOutlet weak var tableView: UITableView!
	
	let availableStoriesTypes: [StoryType] = [.new, .top, .best]
	
	var currentStoryType: StoryType = .new {
		didSet {
			fetchIdsStories(currentStoryType)
		}
	}
	
	var ids = [Int]() {
		didSet {
			tableView.reloadData()
		}
	}
	var stories: [Story?] = Array(repeating: nil, count: 200)
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupTableView()
		initialSetupSegmentControl()
	}

	@IBAction func switchedStory(_ sender: UISegmentedControl) {
		if let storyType = StoryType(rawValue: sender.selectedSegmentIndex) {
			stories = Array(repeating: nil, count: 200)
			ids.removeAll()
			tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
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
	
	func fetchIdsStories(_ type: StoryType) {
		LoadManager.shared.fetchIdsStories(type: type) { (storyType, ids) in
			if storyType == self.currentStoryType {
				self.ids = ids
			}
		}
	}
}

extension StoryViewController: UITableViewDataSource, UITableViewDelegate, UITableViewDataSourcePrefetching {
	func setupTableView() {
		tableView.delegate = self
		tableView.dataSource = self
		tableView.prefetchDataSource = self
		let nib = UINib(nibName: "\(StoryTableViewCell.self)", bundle: nil)
		tableView.register(nib, forCellReuseIdentifier: StoryTableViewCell.reuseId)
		tableView.tableFooterView = UIView()
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return stories.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: StoryTableViewCell.reuseId, for: indexPath) as! StoryTableViewCell
		let row = indexPath.row
		
		if let story = stories[row] {
			cell.configure(story: story)
		} else {
			cell.setDefaultUI()
			if ids.indices.contains(row) {
				let id = ids[row]
				LoadManager.shared.fetchStory(for: id) { [indexPath, id] story in
					guard let story = story, story.id == id else { return }
					self.stories[indexPath.row] = story
					guard tableView.indexPathsForVisibleRows?.contains(indexPath) ?? false else { return }
					tableView.reloadRows(at: [indexPath], with: .fade)
				}
			}
		}
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
		for indexPath in indexPaths {
			let row = indexPath.row
			if ids.indices.contains(row) {
				let id = ids[row]
				LoadManager.shared.fetchStory(for: id) { [indexPath, id] story in
					guard let story = story, story.id == id else { return }
					self.stories[indexPath.row] = story
					guard tableView.indexPathsForVisibleRows?.contains(indexPath) ?? false else { return }
					tableView.reloadRows(at: [indexPath], with: .fade)
				}
			}
		}
	}
	
	func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
		for indexPath in indexPaths {
			let row = indexPath.row
			if ids.indices.contains(row) {
				//let id = ids[row]
				//LoadManager.shared.cancelLoadOfStory(id: id)
			}
		}
	}
}
