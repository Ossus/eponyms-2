//
//  SyncController.swift
//  eponyms-2
//
//  Created by Pascal Pfiffner on 4/25/15.
//  Copyright (c) 2015 Ossus. All rights reserved.
//

import Foundation

let kSyncGatewayUrl = NSURL(string: "http://192.168.10.22:4999/eponyms")!


class SyncController
{
	deinit {
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	
	
	/// Handle to our database.
	let database: CBLDatabase
	
	/// The pull replicator.
	let pull: CBLReplication
	
	/// The push replicator.
	let push: CBLReplication
	
	init(databaseName name: String) throws {
		let manager = CBLManager.sharedInstance()
		database = try manager.databaseNamed(name)
		
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
	
	func sync() {
		push.start()
		pull.start()
	}
	
	func isSyncing() -> Bool {
		return (pull.status == CBLReplicationStatus.Active) || (push.status == CBLReplicationStatus.Active)
	}
	
	@objc func replicationChanged(notification: NSNotification) {
		if isSyncing() {
			var progress = 0.0
			let total = push.changesCount + pull.changesCount
			let completed = push.completedChangesCount + pull.completedChangesCount
			if total > 0 {
				progress = Double(completed) / Double(total);
			}
			if let err = push.lastError {
				logIfVerbose("Sync: error pushing [1]: \(err)")
			}
			else if let err = pull.lastError {
				logIfVerbose("Sync: error pulling [1]: \(err)")
			}
			else {
				logIfVerbose("Sync: progress \(progress * 100)%")
			}
		}
		else if let err = push.lastError {
			logIfVerbose("Sync: error pushing [2]: \(err)")
		}
		else if let err = pull.lastError {
			logIfVerbose("Sync: error pulling [2]: \(err)")
		}
	}
	
	
	// MARK: - Credentials
	
	/** Check if a user with given name has credentials in the keychain, if not and a password is given, create and
		store one.
	 */
	func authorizeUser(username: String, password: String? = nil) -> Bool {
		let space = protectionSpace()
		if let found = existingCredentialsForUser(username, space: space) {
			logIfVerbose("Sync: user «\(username)» was already logged in")
			pull.credential = found
			push.credential = found
			return true
		}
		
		// log in if we have a password
		if let pass = password {
			logIfVerbose("Sync: user «\(username)» logged in")
			let cred = logInUser(username, password: pass, space: space)
			pull.credential = cred
			push.credential = cred
			return true
		}
		return false
	}
	
	/** Returns a list of usernames that have credentials for our Sync Gateway. */
	func loggedInUsers() -> [String]? {
		let space = protectionSpace()
		let store = NSURLCredentialStorage.sharedCredentialStorage()
		if let found = store.credentialsForProtectionSpace(space) {
			var usernames = [String]()
			for (usr, cred) in found {
				if let u = usr as? String {
					usernames.append(u)
				}
			}
			return usernames
		}
		return nil
	}
	
	func existingCredentialsForUser(username: String, space: NSURLProtectionSpace) -> NSURLCredential? {
		let store = NSURLCredentialStorage.sharedCredentialStorage()
		if let found = store.credentialsForProtectionSpace(space) {
			for (usr, cred) in found {
				if let u = usr as? String where u == username {
					return (cred )
				}
			}
		}
		return nil
	}
	
	func logInUser(username: String, password: String, space: NSURLProtectionSpace) -> NSURLCredential {
		let store = NSURLCredentialStorage.sharedCredentialStorage()
		let credentials = NSURLCredential(user: username, password: password, persistence: .Permanent)
		store.setCredential(credentials, forProtectionSpace: space)
		
		return credentials
	}
	
	func logOutUser(username: String) {
		let space = protectionSpace()
		if let found = existingCredentialsForUser(username, space: space) {
			let store = NSURLCredentialStorage.sharedCredentialStorage()
			store.removeCredential(found, forProtectionSpace: space)
		}
	}
	
	/** The URL protection space for our Sync Gateway. */
	func protectionSpace() -> NSURLProtectionSpace {
		return NSURLProtectionSpace(
			host: kSyncGatewayUrl.host!,
			port: kSyncGatewayUrl.port as! Int,
			`protocol`: kSyncGatewayUrl.scheme,
			realm: nil,
			authenticationMethod: NSURLAuthenticationMethodHTTPBasic
		)
	}
}

