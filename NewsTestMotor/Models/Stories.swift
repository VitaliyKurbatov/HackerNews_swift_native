//
//  Stories.swift
//  NewsTestMotor
//
//  Created by Vitaliy on 01.04.2020.
//  Copyright © 2020 Vitaliy. All rights reserved.
//

enum StoryType: Int {
	case new = 0
	case top
	case best
	
	var description: String {
		switch self {
		case .new:
			return "News stories"
		case .top:
			return "Top stories"
		case .best:
			return "Best stories"
		}
	}
	
	var pathComponent: String {
		switch self {
		case .new:
			return "v0/newstories"
		case .top:
			return "v0/topstories"
		case .best:
			return "v0/beststories"
		}
	}
}

struct Story: Codable {
	let id: Int
	var type: StoryType?
	let title: String
	let time: Int
	let author: String
	let score: Int
	let urlPath: String
	
	enum CodingKeys: String, CodingKey {
		case id
		case title
		case time
		case author = "by"
		case score
		case urlPath = "url"
	}
	
	/*
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		id = try container.decode(Int.self, forKey: .id)
		title = try container.decode(String.self, forKey: .title)
		time = try container.decode(Int64.self, forKey: .time)
		author = try container.decode(String.self, forKey: .author)
		score = try container.decode(Int.self, forKey: .score)
		urlPath = try container.decode(String.self, forKey: .urlPath)
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(id, forKey: .id)
		try container.encode(title, forKey: .title)
		try container.encode(time, forKey: .time)
		try container.encode(author, forKey: .author)
		try container.encode(score, forKey: .score)
		try container.encode(urlPath, forKey: .urlPath)
	}
	*/
}
