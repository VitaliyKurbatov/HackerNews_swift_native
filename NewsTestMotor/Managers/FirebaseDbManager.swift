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
	
	private let baseUrl = "https://hacker-news.firebaseio.com/"
	
	private let dbRef: DatabaseReference!
	let queue = DispatchQueue(label: "DownloadQueue", qos: .userInitiated, attributes: .concurrent)
	
	private var allStories = [Int: [Story]]()
	
	private init() {
		dbRef = Database.database(url: baseUrl).reference()
	}
	
	func fetchStories(type: StoryType, completion: @escaping (([Story]) -> Void)) {
		if let stories = allStories[type.rawValue], !stories.isEmpty {
			completion(stories)
			return
		}
		
		downloadIdsOfStories(type) { ids in
			guard let ids = ids else { return }
			self.downloadStories(ids) { downloadedStories in
				var sortedStories = [Story]()
				for id in ids {
					if let story = downloadedStories.first(where: { $0.id == id }) {
						sortedStories.append(story)
					}
				}
				self.allStories.updateValue(sortedStories, forKey: type.rawValue)
				completion(sortedStories)
			}
		}
	}
	
	private func downloadIdsOfStories(_ type: StoryType, completion: @escaping ([Int]?) -> Void) {
		queue.async {
			self.dbRef.child(type.pathComponent).queryLimited(toFirst: 10).observeSingleEvent(of: .value) { snapshot in
				if let storyIds = snapshot.value as? [Int] {
					completion(storyIds)
				} else {
					completion(nil)
				}
			}
		}
		
	}
	
	private func downloadStories(_ storyIds: [Int], completion: @escaping (([Story]) -> Void)) {
		var stories = [Story]()
		var mistakes = 0
		
		let returnedBlock: () -> () = {
			if stories.count + mistakes == storyIds.count {
				//print("mistakes", mistakes)
				completion(stories)
			}
		}
		
		queue.async {
			for id in storyIds {
				self.dbRef.child("v0/item/\(id)").observeSingleEvent(of: .value) { snapshot in
					guard let json = snapshot.value as? [String: Any]
						else {
							mistakes += 1
							returnedBlock()
							return }
					do {
						let data = try JSONSerialization.data(withJSONObject: json, options: .sortedKeys)
						let story = try JSONDecoder().decode(Story.self, from: data)
						stories.append(story)
						returnedBlock()
					} catch {
						mistakes += 1
						returnedBlock()
					}
				}
			}
		}
	}
}
