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
			if 0 == sync.documentCount {
				do {
					try performImport(with: sync)
				}
				catch let error {
					fatalError("\(error)")
				}
			}
//			if !sync.authorizeUser(user) {
//				logIfVerbose("Sync: no user logged in, using anonymous GUEST user")
//			}
			#if SYNC_ACTIVE
			sync.sync()
			#endif
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
	
	/**
	Imports bundled eponyms into the local Couchbase db, then looks if the SQLite database from version 1.x is still there and imports
	starred and most recent documents.
	*/
	func performImport(with sync: SyncController) throws {
		
		// import bunded eponyms
		try sync.importLocalDocuments(from: "eponyms-2", deleteExisting: true)
		
		// read starred and recent eponyms in old database, if it's there
		let reader = OldDatabaseReader()
		if let (starred, recent) = try reader.starredAndRecentIds() {
			if let dbLocation = OldDatabaseReader.databaseLocation {
				try? FileManager.default.removeItem(at: dbLocation)
			}
			
			// add to user prefs document
			let prefs = UserPrefsDocument(forNewDocumentIn: sync.database)
			var starredDocs = [JSONDoc]()
			var recentDocs = [JSONDoc]()
			for star in starred {
				if let doc = sync.database.existingDocument(withID: star)?.properties {
					starredDocs.append(doc)
				}
			}
			for rec in recent {
				if let doc = sync.database.existingDocument(withID: rec)?.properties {
					recentDocs.append(doc)
				}
			}
			prefs.starred = starredDocs
			prefs.recent = recentDocs
			try prefs.save()
		}
	}
	
	
	// MARK: - Split view
	
	func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
	    if let secondaryAsNavController = secondaryViewController as? UINavigationController {
	        if let topAsDetailController = secondaryAsNavController.topViewController as? MainDocumentViewController {
	            if nil != topAsDetailController.element {
	                return false
	            }
	        }
	    }
	    return true
	}
}


func logIfVerbose(_ message: @autoclosure () -> String, function: String = #function, file: String = #file, line: Int = #line) {
	#if DEBUG
	print("[\((file as NSString).lastPathComponent):\(line)] \(function)  \(message())")
	#endif
}

