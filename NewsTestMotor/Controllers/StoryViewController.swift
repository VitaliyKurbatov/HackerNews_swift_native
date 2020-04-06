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
	let countOfFirstStories = 20
	
	var currentStoryType: StoryType = .new {
		didSet {
			fetchIdsStories(currentStoryType)
		}
	}
	
	var idsStories = [Int]()
	var stories = [Story?]()
	
	var prefetchIndeces = [Int]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupTableView()
		createEmptyArrayStories()
		initialSetupSegmentControl()
	}
	
	func createEmptyArrayStories() {
		stories = Array(repeating: nil, count: countOfFirstStories)
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
		let firstPacketIds = idsStories.prefix(countOfFirstStories).map({ $0 })
		
		LoadManager.shared.loadStories(for: firstPacketIds, type: currentStoryType) { (type, stories) in
			guard self.currentStoryType == type else { return }
			let tail: [Story?] = Array(repeating: nil,
									   count: self.idsStories.count - self.countOfFirstStories)
			self.stories = stories + tail
			self.tableView.isScrollEnabled = true
			self.tableView.reloadData()
		}
	}

	@IBAction func switchedStory(_ sender: UISegmentedControl) {
		if let storyType = StoryType(rawValue: sender.selectedSegmentIndex) {
			LoadManager.shared.cancelAllTasks()
			idsStories.removeAll()
			createEmptyArrayStories()
			prefetchIndeces.removeAll()
			tableView.reloadData()
			tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
			tableView.isScrollEnabled = false
			currentStoryType = storyType
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
			fetchStoryAndUpdate(indexOfIdInArrayIds: row, indexPath: indexPath)
		}
		return cell
	}
	
	func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
		for indexPath in indexPaths {
			fetchStoryAndUpdate(indexOfIdInArrayIds: indexPath.row, indexPath: indexPath)
		}
	}
	
	func fetchStoryAndUpdate(indexOfIdInArrayIds: Int, indexPath: IndexPath) {
		guard stories[indexOfIdInArrayIds] == nil
			&& !prefetchIndeces.contains(indexOfIdInArrayIds) else { return }
		
		prefetchIndeces.append(indexOfIdInArrayIds)
		//print(prefetchIndeces)
		
		guard idsStories.indices.contains(indexOfIdInArrayIds) else { return }
		let id = idsStories[indexOfIdInArrayIds]
		
		LoadManager.shared.loadStory(for: id) { [indexPath, id] story in
			guard let story = story, story.id == id else { return }
			self.stories[indexPath.row] = story
			guard self.tableView.indexPathsForVisibleRows?.contains(indexPath) ?? false else { return }
			self.tableView.beginUpdates()
			self.tableView.reloadRows(at: [indexPath], with: .automatic)
			self.tableView.endUpdates()
		}
	}
}
