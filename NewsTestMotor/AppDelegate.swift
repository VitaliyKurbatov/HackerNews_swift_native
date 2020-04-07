//
//  AppDelegate.swift
//  NewsTestMotor
//
//  Created by Vitaliy on 30.03.2020.
//  Copyright © 2020 Vitaliy. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	
	var window: UIWindow?
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		return true
	}
	
	func applicationWillResignActive(_ application: UIApplication) {
		LoadManager.shared.cancelAllTasks()
	}
	
	func applicationWillTerminate(_ application: UIApplication) {
		LoadManager.shared.cancelAllTasks()
	}
}

