//
//  ViewController.swift
//  NewsTestMotor
//
//  Created by Vitaliy on 30.03.2020.
//  Copyright © 2020 Vitaliy. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ViewController: UIViewController {
	
	var ref: DatabaseReference!
	let baseUrl = "https://hacker-news.firebaseio.com/"

	override func viewDidLoad() {
		super.viewDidLoad()
		ref = Database.database(url: baseUrl).reference()
		download()
	}

	func download() {
		ref.child("v0/topstories").observeSingleEvent(of: .value) { (snapshot) in
			let storyIds = snapshot.value as? [Int]
			if let firstStoryId = storyIds?.first {
				self.ref.child("v0/item/\(firstStoryId)").observeSingleEvent(of: .value) { (snapshot) in
					let story = snapshot.value as? [String: Any]
					print(story)
				}
			}
		}
	}
}

