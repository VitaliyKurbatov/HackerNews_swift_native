//
//  Story.swift
//  NewsTestMotor
//
//  Created by Vitaliy on 08.04.2020.
//  Copyright © 2020 Vitaliy. All rights reserved.
//

struct Story: Codable {
	let id: Int
	let title: String
	let time: Int
	let author: String
	let score: Int
	let urlPath: String?
	
	enum CodingKeys: String, CodingKey {
		case id
		case title
		case time
		case author = "by"
		case score
		case urlPath = "url"
	}
}
