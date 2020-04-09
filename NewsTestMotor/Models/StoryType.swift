//
//  StoryType.swift
//  NewsTestMotor
//
//  Created by Vitaliy on 08.04.2020.
//  Copyright © 2020 Vitaliy. All rights reserved.
//

enum StoryType: Int {
	case new = 0
	case top
	case best
	
	var description: String {
		switch self {
		case .new:
			return "New stories"
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
