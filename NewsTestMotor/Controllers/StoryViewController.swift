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
	let countOfStoriesForFirstLoad = 20
	
	var currentStoryType: StoryType = .new {
		didSet {
			fetchIdsStories(currentStoryType)
		}
	}
	
	var idsStories = [Int]()
	var stories = [Story?]()
	var loadableRows = [Int]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupTableView()
		createEmptyArrayStories()
		initialSetupSegmentControl()
	}
	
	func createEmptyArrayStories() {
		stories = Array(repeating: nil, count: countOfStoriesForFirstLoad)
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
		LoadManager.shared.cancelAllTasks()
		LoadManager.shared.loadIdsStories(type: type) { (storyType, ids) in
			if storyType == self.currentStoryType {
				self.idsStories = ids
				self.fetchFirstPacketOfStories()
			}
		}
	}
	
	func fetchFirstPacketOfStories() {
		guard !idsStories.isEmpty else { return }
		let count = idsStories.count > countOfStoriesForFirstLoad ? countOfStoriesForFirstLoad : idsStories.count
		
		var i = 0
		while i < count {
			loadableRows.append(i)
			i += 1
		}
		
		let firstPacketIds = idsStories.prefix(count).map({ $0 })
		
		LoadManager.shared.loadStories(for: firstPacketIds, type: currentStoryType) { (type, stories) in
			guard self.currentStoryType == type && !self.idsStories.isEmpty else { return }
			let tail: [Story?] = Array(repeating: nil,
									   count: self.idsStories.count - self.countOfStoriesForFirstLoad)
			self.stories = stories + tail
			self.tableView.isScrollEnabled = true
			self.tableView.reloadData()
		}
	}

	@IBAction func switchedStory(_ sender: UISegmentedControl) {
		guard let storyType = StoryType(rawValue: sender.selectedSegmentIndex) else { return }
		LoadManager.shared.cancelAllTasks()
		idsStories.removeAll()
		createEmptyArrayStories()
		loadableRows.removeAll()
		tableView.reloadData()
		tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
		tableView.isScrollEnabled = false
		currentStoryType = storyType
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
		tableView.isScrollEnabled = false
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
			fetchStoryAndUpdate(indexPath: indexPath)
		}
		return cell
	}
	
	func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
		for indexPath in indexPaths {
			fetchStoryAndUpdate(indexPath: indexPath)
		}
	}
	
	// MARK: - load story, add it into array of stories and update UI if needed
	func fetchStoryAndUpdate(indexPath: IndexPath) {
		// row is like index of id in array idsStories
		let row = indexPath.row
		guard idsStories.indices.contains(row) else { return }
		guard stories[row] == nil
			&& !loadableRows.contains(row) else { return }
		
		loadableRows.append(row)
		let id = idsStories[row]
		
		LoadManager.shared.loadStory(for: id, type: currentStoryType) { [indexPath, id] (storyType, story) in
			guard storyType == self.currentStoryType else { return }
			guard let story = story, story.id == id else { return }
			self.stories[indexPath.row] = story
			guard self.tableView.indexPathsForVisibleRows?.contains(indexPath) ?? false else { return }
			self.tableView.beginUpdates()
			self.tableView.reloadRows(at: [indexPath], with: .automatic)
			self.tableView.endUpdates()
		}
	}
}
