//
//  LoadManager.swift
//  NewsTestMotor
//
//  Created by Vitaliy on 01.04.2020.
//  Copyright © 2020 Vitaliy. All rights reserved.
//

import Foundation

class LoadManager {
	static let shared = LoadManager()
	
	let maxStoriesCount = 300
	
	private let https = "https"
	private let urlHost = "hacker-news.firebaseio.com"
	
	private let operationQueue = OperationQueue()
	
	private init() {
		operationQueue.maxConcurrentOperationCount = 8
		operationQueue.qualityOfService = .userInitiated
	}
	
	// MARK: - create url to fetch ids of stories from api
	func createPathToIdsOfStories(for type: StoryType) -> URL? {
		var components = URLComponents()
		components.scheme = https
		components.host = urlHost
		components.path = "/\(type.pathComponent).json"
		
		let queryItems = [URLQueryItem(name: "orderBy", value: "\"$key\""),
						  URLQueryItem(name: "limitToFirst", value: String(maxStoriesCount))]
		components.queryItems = queryItems
		
		return components.url
	}
	
	// MARK: - create url to fetch item from api
	func createPathToItem(id: Int) -> URL? {
		let path = "\(https)://\(urlHost)/v0/item/\(id).json"
		return URL(string: path)
	}
	
	// MARK: - load ids of stories by type
	func loadIdsStories(type: StoryType, completion: @escaping ((type: StoryType, ids: [Int])) -> Void) {
		let block = BlockOperation {
			guard let url = self.createPathToIdsOfStories(for: type) else {
				completion((type, []))
				return
			}
			let dataTask = URLSession.shared.dataTask(with: url) { [type] (data, response, error) in
				var result = [Int]()
				guard error == nil
					, let data = data else {
						DispatchQueue.main.async {
							completion((type, result))
						}
						return
				}
				do {
					result = try JSONDecoder().decode([Int].self, from: data)
				} catch {
					//assert(false)
				}
				DispatchQueue.main.async {
					completion((type, result))
				}
			}
			dataTask.resume()
		}
		operationQueue.addOperation(block)
	}
	
	// MARK: - load one story by id
	func loadStory(for id: Int, type: StoryType, completion: @escaping ((type: StoryType, Story?)) -> Void) {
		let block = BlockOperation {
			guard let url = self.createPathToItem(id: id) else {
				completion((type, nil))
				return
			}
			
			let dataTask = URLSession.shared.dataTask(with: url) { [type] (data, response, error) in
				var result: Story?
				guard error == nil
					, let data = data else {
						DispatchQueue.main.async {
							completion((type, result))
						}
						return
				}
				do {
					result = try JSONDecoder().decode(Story.self, from: data)
				} catch {
					//assert(false)
				}
				DispatchQueue.main.async {
					completion((type, result))
				}
			}
			dataTask.resume()
		}
		operationQueue.addOperation(block)
	}
	
	// MARK: - load several stories by array ids
	func loadStories(for ids: [Int], type: StoryType, completion: @escaping ((type: StoryType, stories: [Story?])) -> Void) {
		var result = [Story?]()
		
		let group = DispatchGroup()
		for id in ids {
			group.enter()
			loadStory(for: id, type: type) { [type] (storyType, story) in
				if storyType == type {
					result.append(story)
				}
				group.leave()
			}
		}
		
		group.notify(queue: .main) { [type] in
			var sortedResult = [Story?]()
			for id in ids {
				sortedResult.append(result.first(where: { $0?.id == id }) ?? nil)
			}
			completion((type, sortedResult))
		}
	}
	
	// MARK: - cancel all operations
	func cancelAllOperations() {
		operationQueue.cancelAllOperations()
	}
}
