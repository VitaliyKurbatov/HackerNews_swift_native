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
	
	let segueIdentifier = "show_WebViewController"
	let availableStoriesTypes: [StoryType] = [.new, .top, .best]
	let countOfStoriesForFirstLoad = 20
	
	var currentStoryType: StoryType = .new
	
	var idsStories = [Int]()
	var stories = [Story?]()
	var loadableRows = [Int]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupTableView()
		setupRefreshControl()
		setupSegmentControl()
		createEmptyArrayStories()
		fetchIdsStories(for: currentStoryType)
	}
	
	// MARK: - Configurations
	
	func setupTableView() {
		tableView.delegate = self
		tableView.dataSource = self
		tableView.prefetchDataSource = self
		
		let nib = UINib(nibName: "\(StoryTableViewCell.self)", bundle: nil)
		tableView.register(nib, forCellReuseIdentifier: StoryTableViewCell.reuseId)
		
		tableView.tableFooterView = UIView()
		tableView.isUserInteractionEnabled = false
	}
	
	func setupRefreshControl () {
		tableView.refreshControl = UIRefreshControl()
		tableView.refreshControl?.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
	}
	
	func setupSegmentControl() {
		for (index, type) in availableStoriesTypes.enumerated() {
			segmentControl.setTitle(type.description, forSegmentAt: index)
			if type == currentStoryType {
				segmentControl.selectedSegmentIndex = index
			}
		}
	}
	
	func createEmptyArrayStories() {
		stories = Array(repeating: nil, count: countOfStoriesForFirstLoad)
	}
	
	// MARK: - Filling dataSource
	
	func fetchIdsStories(for type: StoryType) {
		LoadManager.shared.cancelAllOperations()
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
			self.tableView.isUserInteractionEnabled = true
			self.tableView.allowsSelection = true
			self.tableView.reloadData()
			self.tableView.refreshControl?.endRefreshing()
		}
	}
	
	// reset data into properties
	func resetData() {
		LoadManager.shared.cancelAllOperations()
		idsStories.removeAll()
		createEmptyArrayStories()
		loadableRows.removeAll()
	}
	
	// MARK: - Actions
	
	@objc func handleRefreshControl() {
		resetData()
		tableView.allowsSelection = false
		fetchIdsStories(for: currentStoryType)
	}

	@IBAction func switchedStory(_ sender: UISegmentedControl) {
		guard let storyType = StoryType(rawValue: sender.selectedSegmentIndex) else { return }
		resetData()
		tableView.reloadData()
		tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
		tableView.isUserInteractionEnabled = false
		currentStoryType = storyType
		fetchIdsStories(for: currentStoryType)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == segueIdentifier {
			guard let vc = segue.destination as? WebViewController else { return }
			if let url = sender as? URL {
				vc.url = url
			}
		}
	}
}

extension StoryViewController: UITableViewDataSource, UITableViewDelegate, UITableViewDataSourcePrefetching {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return stories.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: StoryTableViewCell.reuseId, for: indexPath) as! StoryTableViewCell
		let row = indexPath.row
		
		if stories.indices.contains(row), let story = stories[row] {
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
		guard idsStories.indices.contains(row) && stories.indices.contains(row) else { return }
		guard stories[row] == nil
			&& !loadableRows.contains(row) else { return }
		
		loadableRows.append(row)
		let id = idsStories[row]
		
		LoadManager.shared.loadStory(for: id, type: currentStoryType) { [indexPath, id] (storyType, story) in
			guard storyType == self.currentStoryType
				&& self.stories.indices.contains(indexPath.row) else { return }
			guard let story = story, story.id == id else { return }
			
			self.stories[indexPath.row] = story
			
			guard self.tableView.indexPathsForVisibleRows?.contains(indexPath) ?? false else { return }
			self.tableView.beginUpdates()
			self.tableView.reloadRows(at: [indexPath], with: .automatic)
			self.tableView.endUpdates()
		}
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let cell = tableView.cellForRow(at: indexPath) as? StoryTableViewCell
			, let story = cell.story else { return }
		if let urlPath = story.urlPath, let url = URL(string: urlPath) {
			performSegue(withIdentifier: segueIdentifier, sender: url)
		} else {
			showAlert()
		}
	}
	
	func showAlert() {
		let alertController = UIAlertController(title: "Sorry",
												message: "No data to display",
												preferredStyle: .alert)
		let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
		alertController.addAction(cancelAction)
		
		if let popoverController = alertController.popoverPresentationController {
			// settings for iPad
			popoverController.sourceView = self.view
			popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
			popoverController.permittedArrowDirections = []
		}
		
		present(alertController, animated: true) {
			DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
				alertController.dismiss(animated: true, completion: nil)
			}
		}
	}
}
