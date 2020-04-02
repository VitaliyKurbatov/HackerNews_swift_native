//
//  StoryTableViewCell.swift
//  NewsTestMotor
//
//  Created by Vitaliy on 02.04.2020.
//  Copyright © 2020 Vitaliy. All rights reserved.
//

import UIKit

class StoryTableViewCell: UITableViewCell {
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var scoreLabel: UILabel!
	@IBOutlet weak var dateLabel: UILabel!
	@IBOutlet weak var authorLabel: UILabel!
	
	var urlPath = String()
	
	override func prepareForReuse() {
		titleLabel.text = nil
		titleLabel.attributedText = nil
		scoreLabel.text = nil
		dateLabel.text = nil
		authorLabel.text = nil
		urlPath = String()
	}
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//    }
//
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//        // Configure the view for the selected state
//    }
	
	func configure(_ story: Story) {
		titleLabel.text = "     \(story.title)"
		//titleLabel.attributedText = NSMutableAttributedString(string: story.title)
		scoreLabel.text = String(story.score)
		dateLabel.text = String(story.time)
		authorLabel.text = story.author
		urlPath = story.urlPath
	}
}
