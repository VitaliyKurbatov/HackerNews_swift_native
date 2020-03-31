//
//  Stories.swift
//  NewsTestMotor
//
//  Created by Vitaliy on 01.04.2020.
//  Copyright © 2020 Vitaliy. All rights reserved.
//

enum StoryType: Int {
	case new = 1
	case top
	case best
	
	var description: String {
		switch self {
		case .new:
			return "New"
		case .top:
			return "Top"
		case .best:
			return "Best"
		}
	}
}

struct Story {
	var type: StoryType
	var id: Int
	var title: String
	var time: Int64
	var author: String
	var urlPath: String
}
