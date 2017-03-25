//
//  AppDelegate.swift
//  eponyms-2
//
//  Created by Pascal Pfiffner on 3/2/15.
//  Copyright (c) 2015 Ossus. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {
	
	var window: UIWindow?
	
	var sync: SyncController?


	func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		sync = try! SyncController(databaseName: "eponyms")
		
		NotificationCenter.default.addObserver(forName: UserDidLoginNotification, object: nil, queue: nil, using: userStatusChanged)
		NotificationCenter.default.addObserver(forName: UserDidLogoutNotification, object: nil, queue: nil, using: userStatusChanged)
		
		return true
	}
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		
		// setup UI
		let splitViewController = self.window!.rootViewController as! UISplitViewController
		let masterNavi = splitViewController.viewControllers.first as! UINavigationController
		let master = masterNavi.viewControllers.first as! MasterViewController
		master.sync = sync
		
		let detailNavi = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
		detailNavi.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
		
		splitViewController.preferredDisplayMode = .allVisible
		splitViewController.delegate = self
		
		return true
	}
	
	func applicationDidBecomeActive(_ application: UIApplication) {
		if let sync = sync {
#if false
			do {
				try sync.importLocalDocuments(from: "eponyms-2", deleteExisting: true)
			}
			catch let error {
				fatalError("\(error)")
			}
#endif
//			if !sync.authorizeUser(user) {
//				logIfVerbose("Sync: no user logged in, using anonymous GUEST user")
//			}
			sync.sync()
		}
	}
	
	
	// MARK: - Sync Controller Tasks
	
	func userStatusChanged(_ notification: Notification) {
		print("\(notification)")
		if let sync = sync {
			if let user = notification.object as? User {
				logIfVerbose("LOGIN \(user)")
				do {
					try sync.authorize(user: user)
				}
				catch let error {
					logIfVerbose("Login failed: \(error)")
				}
			}
				
			// logout
			else {
				logIfVerbose("LOGOUT")
			}
		}
	}
	
	
	// MARK: - Split view
	
	func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
	    if let secondaryAsNavController = secondaryViewController as? UINavigationController {
	        if let topAsDetailController = secondaryAsNavController.topViewController as? MainDocumentViewController {
	            if nil == topAsDetailController.element {
	                return true
	            }
	        }
	    }
	    return false
	}
}


func logIfVerbose(_ message: @autoclosure () -> String, function: String = #function, file: String = #file, line: Int = #line) {
	#if DEBUG
	print("[\((file as NSString).lastPathComponent):\(line)] \(function)  \(message())")
	#endif
}

