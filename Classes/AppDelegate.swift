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


	func application(application: UIApplication, willFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
		sync = try! SyncController(databaseName: "eponyms")
		
		NSNotificationCenter.defaultCenter().addObserverForName(UserDidLoginNotification, object: nil, queue: nil, usingBlock: userStatusChanged)
		NSNotificationCenter.defaultCenter().addObserverForName(UserDidLogoutNotification, object: nil, queue: nil, usingBlock: userStatusChanged)
		
		return true
	}
	
	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		
		// setup UI
		let splitViewController = self.window!.rootViewController as! UISplitViewController
		
		let masterNavi = splitViewController.viewControllers.first as! UINavigationController
		let master = masterNavi.viewControllers.first as! MasterViewController
		master.sync = sync
		
		let detailNavi = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
		detailNavi.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem()
		splitViewController.delegate = self
		
		return true
	}
	
	func applicationDidBecomeActive(application: UIApplication) {
		if let sync = sync {
//			if !sync.authorizeUser(user) {
//				logIfVerbose("Sync: no user logged in, using anonymous GUEST user")
//			}
			sync.sync()
		}
	}
	
	
	// MARK: - Sync Controller Tasks
	
	func userStatusChanged(notification: NSNotification) {
		print("\(notification)")
		if let sync = sync {
			if let user = notification.object as? User {
				logIfVerbose("LOGIN \(user)")
				do {
					try sync.authorizeUser(user)
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
	
	func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController:UIViewController, ontoPrimaryViewController primaryViewController:UIViewController) -> Bool {
	    if let secondaryAsNavController = secondaryViewController as? UINavigationController {
	        if let topAsDetailController = secondaryAsNavController.topViewController as? DetailViewController {
	            if topAsDetailController.detailItem == nil {
	                // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
	                return true
	            }
	        }
	    }
	    return false
	}
}


func logIfVerbose(@autoclosure message: () -> String, function: String = #function, file: String = #file, line: Int = #line) {
	print("[\((file as NSString).lastPathComponent):\(line)] \(function)  \(message())")
}

