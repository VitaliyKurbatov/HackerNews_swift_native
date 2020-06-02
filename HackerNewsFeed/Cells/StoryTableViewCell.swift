//
//  StoryTableViewCell.swift
//  HackerNewsFeed
//
//  Created by Vitaliy on 02.04.2020.
//  Copyright © 2020 Vitaliy. All rights reserved.
//

import UIKit

class StoryTableViewCell: UITableViewCell {
	static let reuseId = "StoryTableViewCell"
	
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var stackView: UIStackView!
	@IBOutlet weak var scoreLabel: UILabel!
	@IBOutlet weak var dateLabel: UILabel!
	@IBOutlet weak var authorLabel: UILabel!
	
	var story: Story?
	
	func setDefaultUI() {
		titleLabel.isHidden = true
		stackView.isHidden = true
		activityIndicator.isHidden = false
		activityIndicator.startAnimating()
		story = nil
	}
	
	func configure(story: Story) {
		activityIndicator.stopAnimating()
		titleLabel.isHidden = false
		stackView.isHidden = false
		titleLabel.text = "     \(story.title)"
		scoreLabel.text = String(story.score)
		dateLabel.text = convertDate(story.time)
		authorLabel.text = story.author
		
		self.story = story
	}
	
	func convertDate(_ timestamp: Int) -> String {
		let date = Date(timeIntervalSince1970: Double(timestamp))
		let dateFormatter = DateFormatter()
		dateFormatter.locale = .current
		dateFormatter.dateStyle = .medium
		dateFormatter.timeStyle = .short
		return dateFormatter.string(from: date)
	}
}
