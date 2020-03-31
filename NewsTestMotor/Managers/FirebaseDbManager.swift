//
//  FirebaseDbManager.swift
//  NewsTestMotor
//
//  Created by Vitaliy on 01.04.2020.
//  Copyright © 2020 Vitaliy. All rights reserved.
//

import FirebaseDatabase

class FirebaseDbManager {
	static let shared = FirebaseDbManager()
	
	let baseUrl = "https://hacker-news.firebaseio.com/"
	let dbRef: DatabaseReference!
	
	private init() {
		dbRef = Database.database(url: baseUrl).reference()
	}
	
	func download() {
		dbRef.child("v0/topstories").observeSingleEvent(of: .value) { (snapshot) in
			let storyIds = snapshot.value as? [Int]
			if let firstStoryId = storyIds?.first {
				self.dbRef.child("v0/item/\(firstStoryId)").observeSingleEvent(of: .value) { (snapshot) in
					let story = snapshot.value as? [String: Any]
					print(story)
				}
			}
		}
	}
}
