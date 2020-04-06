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
	
	private let loadQueue = DispatchQueue(label: "LoadQueue", qos: .userInitiated, attributes: .concurrent)
	private var dataTasks = [URLSessionDataTask]()
	
	private init() { }
	
	func loadIdsStories(type: StoryType, completion: @escaping ((type: StoryType, ids: [Int])) -> Void) {
		var components = URLComponents()
		components.scheme = https
		components.host = urlHost
		components.path = "/\(type.pathComponent).json"
		
		let queryItems = [URLQueryItem(name: "orderBy", value: "\"$key\""),
						  URLQueryItem(name: "limitToFirst", value: String(maxStoriesCount))]
		components.queryItems = queryItems
		
		guard let url = components.url else {
			completion((type, []))
			assert(false)
			return
		}
		
		loadQueue.async { [type] in
			if self.dataTasks.contains(where: { $0.originalRequest?.url == url }) {
				DispatchQueue.main.async {
					completion((type, []))
				}
				return
			}
			let dataTask = URLSession.shared.dataTask(with: url) { [type] (data, response, error) in
				var result = [Int]()
				guard error == nil
					, let data = data else {
						if let index = self.dataTasks.firstIndex(where: { $0.originalRequest?.url == response?.url }) {
							self.dataTasks.remove(at: index)
						}
						DispatchQueue.main.async {
							completion((type, result))
						}
						return
				}
				do {
					result = try JSONDecoder().decode([Int].self, from: data)
				} catch {
					assert(false)
				}
				if let index = self.dataTasks.firstIndex(where: { $0.originalRequest?.url == response?.url }) {
					self.dataTasks.remove(at: index)
				}
				DispatchQueue.main.async {
					completion((type, result))
				}
			}
			self.dataTasks.append(dataTask)
			dataTask.resume()
		}
	}
	
	func createPathToItem(id: Int) -> String {
		return "\(https)://\(urlHost)/v0/item/\(id).json"
	}
	
	func loadStory(for id: Int, completion: @escaping (Story?) -> Void) {
		let path = createPathToItem(id: id)
		guard let url = URL(string: path) else {
			assert(false)
			completion(nil)
			return
		}
		
		loadQueue.async {
			if self.dataTasks.contains(where: { $0.originalRequest?.url == url }) {
				DispatchQueue.main.async {
					completion(nil)
				}
				return
			}
			let dataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
				var result: Story?
				guard error == nil
					, let data = data else {
						if let index = self.dataTasks.firstIndex(where: { $0.originalRequest?.url == response?.url }) {
							self.dataTasks.remove(at: index)
						}
						DispatchQueue.main.async {
							completion(result)
						}
						return
				}
				do {
					result = try JSONDecoder().decode(Story.self, from: data)
				} catch {
					//assert(false)
				}
				if let index = self.dataTasks.firstIndex(where: { $0.originalRequest?.url == response?.url }) {
					self.dataTasks.remove(at: index)
				}
				DispatchQueue.main.async {
					completion(result)
				}
			}
			self.dataTasks.append(dataTask)
			dataTask.resume()
		}
	}
	
	func loadStories(for ids: [Int], type: StoryType, completion: @escaping ((type: StoryType, stories: [Story?])) -> Void) {
		var result = [Story?]()
		
		let group = DispatchGroup()
		for id in ids {
			group.enter()
			loadStory(for: id) { story in
				result.append(story)
				group.leave()
			}
		}
		
		group.notify(queue: .main) {
			var sortedResult = [Story?]()
			for id in ids {
				sortedResult.append(result.first(where: { $0?.id == id }) ?? nil)
			}
			completion((type, sortedResult))
		}
	}
	
	func cancelAllTasks() {
		loadQueue.sync {
			self.dataTasks.forEach({ $0.cancel() })
			self.dataTasks.removeAll()
		}
	}
}
