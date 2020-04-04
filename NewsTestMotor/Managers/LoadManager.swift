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
	
	private let urlScheme = "https"
	private let urlHost = "hacker-news.firebaseio.com"
	
	let queue = DispatchQueue(label: "DownloadQueue", qos: .userInitiated, attributes: .concurrent)
	
	var dataTasks = [URLSessionDataTask]()
	
	private init() { }
	
	func fetchIdsStories(type: StoryType, completion: @escaping ((StoryType, [Int])) -> Void) {
		var components = URLComponents()
		components.scheme = urlScheme
		components.host = urlHost
		components.path = "/\(type.pathComponent).json"
		
		let queryItems = [URLQueryItem(name: "orderBy", value: "\"$key\""),
						  URLQueryItem(name: "limitToFirst", value: "200")]
		components.queryItems = queryItems
		
		guard let url = components.url else {
			completion((type, []))
			return
		}
		//print(url)
		
		queue.async { [type] in
			var result = [Int]()
			do {
				let data = try Data(contentsOf: url, options: .uncached)
				let ids = try JSONDecoder().decode([Int].self, from: data)
				result = ids
			} catch {
				
			}
			DispatchQueue.main.async {
				completion((type, result))
			}
		}
	}
	
	func createPathForItem(id: Int) -> String {
		return "\(urlScheme)://\(urlHost)/v0/item/\(id).json"
	}
	
	func fetchStory(for id: Int, completion: @escaping (Story?) -> Void) {
		let path = createPathForItem(id: id)
		guard let url = URL(string: path) else {
			assert(false)
			completion(nil)
			return
		}
		
		if dataTasks.contains(where: { $0.originalRequest?.url == url }) {
			return
		}
		
		queue.async {
			let dataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
				guard error == nil
					, let data = data else {
						//assert(false)
						if let index = self.dataTasks.firstIndex(where: { $0.originalRequest?.url == response?.url }) {
							self.dataTasks.remove(at: index)
						}
						completion(nil)
						return
				}
				var result: Story?
				do {
					let story = try JSONDecoder().decode(Story.self, from: data)
					result = story
				} catch {
					result = nil
					assert(false)
				}
				if let index = self.dataTasks.firstIndex(where: { $0.originalRequest?.url == response?.url }) {
					self.dataTasks.remove(at: index)
				}
				DispatchQueue.main.async {
					completion(result)
				}
			}
			dataTask.resume()
			self.dataTasks.append(dataTask)
		}
	}
	
	func cancelLoadOfStory(id: Int) {
		let path = createPathForItem(id: id)
		guard let url = URL(string: path) else { return }
		
		if let index = dataTasks.firstIndex(where: { $0.originalRequest?.url == url }) {
			dataTasks[index].cancel()
			dataTasks.remove(at: index)
		}
	}
}
