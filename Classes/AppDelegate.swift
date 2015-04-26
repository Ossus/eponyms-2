//
//  AppDelegate.swift
//  eponyms-2
//
//  Created by Pascal Pfiffner on 3/2/15.
//  Copyright (c) 2015 Ossus. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate
{
	var window: UIWindow?
	
	var sync: SyncController?


	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		sync = SyncController(databaseName: "eponyms")
		
		// setup UI
		let splitViewController = self.window!.rootViewController as! UISplitViewController
		let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
		navigationController.topViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem()
		splitViewController.delegate = self
		return true
	}
	
	func applicationDidBecomeActive(application: UIApplication) {
		if let sync = sync {
			if !sync.authorizeUser("admin") {
				logIfVerbose("Sync: no user logged in, using anonymous GUEST user")
			}
			sync.sync()
		}
	}
	
	
	// MARK: - Split view
	
	func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController:UIViewController!, ontoPrimaryViewController primaryViewController:UIViewController!) -> Bool {
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


func logIfVerbose(message: String) {
	println("\(message)")
}

