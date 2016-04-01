//
//  SyncController.swift
//  eponyms-2
//
//  Created by Pascal Pfiffner on 4/25/15.
//  Copyright (c) 2015 Ossus. All rights reserved.
//

import Foundation
import CouchbaseLite


let kSyncGatewayUrl = NSURL(string: "http://192.168.10.22:4999/eponyms")!


public class SyncController {
	
	deinit {
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	
	
	/// Handle to our database.
	public let database: CBLDatabase
	
	/// The pull replicator.
	let pull: CBLReplication
	
	/// The push replicator.
	let push: CBLReplication
	
	/// The URL protection space for our Sync Gateway.
	lazy var protectionSpace: NSURLProtectionSpace = {
		return NSURLProtectionSpace(
			host: kSyncGatewayUrl.host!,
			port: kSyncGatewayUrl.port as! Int,
			protocol: kSyncGatewayUrl.scheme,
			realm: nil,
			authenticationMethod: NSURLAuthenticationMethodHTTPBasic
		)
	}()
	
	
	/**
	Designated initializer.
	*/
	public init(databaseName name: String) throws {
		let manager = CBLManager.sharedInstance()
		database = try! manager.databaseNamed(name)
		
		// register model classes
		if let factory = database.modelFactory {
			MainDocument.registerInFactory(factory)
		}
		
		// setup replication
		pull = database.createPullReplication(kSyncGatewayUrl)
		pull.continuous = false
		push = database.createPushReplication(kSyncGatewayUrl)
		push.continuous = true
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "replicationChanged:", name: kCBLReplicationChangeNotification, object: push)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "replicationChanged:", name: kCBLReplicationChangeNotification, object: pull)
	}
	
	
	// MARK: - Sync Gateway
	
	/**
	Start push and pull replication. Will automatically suspend when the app goes into background.
	*/
	public func sync() {
		push.start()
		pull.start()
	}
	
	public var isSyncing: Bool {
		return (pull.status == CBLReplicationStatus.Active) || (push.status == CBLReplicationStatus.Active)
	}
	
	public var syncStatus: String {
		switch pull.status {
		case .Active:
			return "active"
		case .Idle:
			return "idle"
		case .Stopped:
			return "stopped"
		case .Offline:
			return "offline"
		}
	}
	
	@objc func replicationChanged(notification: NSNotification) {
		guard let replicator = notification.object as? CBLReplication else {
			logIfVerbose("Sync: unexpected notification.object \(notification.object)")
			return
		}
		let repl = (pull == replicator) ? "pulling" : "pushing"
		if isSyncing {
			var progress = 1.0
			let total = push.changesCount + pull.changesCount
			let completed = push.completedChangesCount + pull.completedChangesCount
			if total > 0 {
				progress = Double(completed) / Double(total);
			}
			
			if let err = replicator.lastError {
				logIfVerbose("Sync: error \(repl) [\(syncStatus)]: \(err), progress \(progress * 100)%")
			}
			else {
				logIfVerbose("Sync: progress \(repl) \(progress * 100)% [\(syncStatus)]")
			}
		}
		else if let err = replicator.lastError {
			logIfVerbose("Sync: error \(repl) [\(syncStatus)]: \(err)")
		}
	}
	
	
	// MARK: - Credentials
	
	/**
	Check if a user with given name has credentials in the keychain, if not and a password is given, create and store one.
	*/
	func authorizeUser(username: String, password: String? = nil) -> Bool {
		if let found = existingCredentialsForUser(username, space: protectionSpace) {
			logIfVerbose("Sync: user “\(username)” was already logged in")
			pull.credential = found
			push.credential = found
			return true
		}
		
		// log in if we have a password
		if let pass = password {
			logIfVerbose("Sync: logged in as “\(username)”")
			let cred = logInUser(username, password: pass, space: protectionSpace)
			pull.credential = cred
			push.credential = cred
			return true
		}
		return false
	}
	
	public func deAuthorizeUser(username: String) {
		logOutUser(username, space: protectionSpace)
	}
	
	/** Returns a list of usernames that have credentials for our Sync Gateway. */
	func loggedInUsers(space: NSURLProtectionSpace) -> [String]? {
		let store = NSURLCredentialStorage.sharedCredentialStorage()
		guard let found = store.credentialsForProtectionSpace(space) else {
			return nil
		}
		var usernames = [String]()
		for (usr, _) in found {
			usernames.append(usr)
		}
		return usernames
	}
	
	func existingCredentialsForUser(username: String, space: NSURLProtectionSpace) -> NSURLCredential? {
		let store = NSURLCredentialStorage.sharedCredentialStorage()
		if let found = store.credentialsForProtectionSpace(space) {
			for (usr, cred) in found {
				if usr == username {
					return cred
				}
			}
		}
		return nil
	}
	
	public func logInUser(username: String, password: String, space: NSURLProtectionSpace) -> NSURLCredential {
		let store = NSURLCredentialStorage.sharedCredentialStorage()
		let credentials = NSURLCredential(user: username, password: password, persistence: .Permanent)
		store.setCredential(credentials, forProtectionSpace: space)
		
		return credentials
	}
	
	public func logOutUser(username: String, space: NSURLProtectionSpace) {
		if let found = existingCredentialsForUser(username, space: space) {
			let store = NSURLCredentialStorage.sharedCredentialStorage()
			store.removeCredential(found, forProtectionSpace: space)
		}
	}
}

