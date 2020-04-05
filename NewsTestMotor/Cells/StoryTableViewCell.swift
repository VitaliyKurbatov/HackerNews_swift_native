//
//  StoryTableViewCell.swift
//  NewsTestMotor
//
//  Created by Vitaliy on 02.04.2020.
//  Copyright © 2020 Vitaliy. All rights reserved.
//

import UIKit

class StoryTableViewCell: UITableViewCell {
	static let reuseId = "StoryTableViewCell"
	
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var scoreLabel: UILabel!
	@IBOutlet weak var dateLabel: UILabel!
	@IBOutlet weak var authorLabel: UILabel!
	
	var urlPath: String?
	
	func setDefaultUI() {
		titleLabel.text = nil
		scoreLabel.text = nil
		dateLabel.text = nil
		authorLabel.text = nil
		urlPath = String()
	}
	
	func configure(story: Story) {
		titleLabel.text = "     \(story.title)"
		scoreLabel.text = String(story.score)
		dateLabel.text = convertDate(story.time)
		authorLabel.text = story.author
		urlPath = story.urlPath
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
