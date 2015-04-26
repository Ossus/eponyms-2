//
//  SyncController.swift
//  eponyms-2
//
//  Created by Pascal Pfiffner on 4/25/15.
//  Copyright (c) 2015 Ossus. All rights reserved.
//

import Foundation

let kSyncGatewayUrl = NSURL(string: "http://192.168.88.22:4999")!


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
	
	init?(databaseName name: String) {
		let manager = CBLManager.sharedInstance()
		var error: NSError?
		let db = manager.databaseNamed(name, error: &error)
		if nil == db {
			database = CBLDatabase()		// This is stupid, thanks Swift :P
			pull = CBLReplication()
			push = CBLReplication()
			return nil
		}
		database = db!
		
		// register model classes
//		database.modelFactory.registerClass(AnyObject, forDocumentType: "")
		
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
				logIfVerbose("Sync: progress \(progress)%")
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
	
	func updateUser(username: String, password: String? = nil) -> Bool {
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
	
	func protectionSpace() -> NSURLProtectionSpace {
		return NSURLProtectionSpace(
			host: kSyncGatewayUrl.host!,
			port: kSyncGatewayUrl.port as! Int,
			`protocol`: kSyncGatewayUrl.scheme,
			realm: nil,
			authenticationMethod: NSURLAuthenticationMethodHTTPBasic
		)
	}
	
	func logInUser(username: String, password: String, space: NSURLProtectionSpace) -> NSURLCredential {
		let store = NSURLCredentialStorage.sharedCredentialStorage()
		let credentials = NSURLCredential(user: username, password: password, persistence: .Permanent)
		store.setCredential(credentials, forProtectionSpace: space)
		
		return credentials
	}
	
	func existingCredentialsForUser(username: String, space: NSURLProtectionSpace) -> NSURLCredential? {
		let store = NSURLCredentialStorage.sharedCredentialStorage()
		if let found = store.credentialsForProtectionSpace(space) {
			for (usr, cred) in found {
				if let u = usr as? String where u == username {
					return (cred as! NSURLCredential)
				}
			}
		}
		return nil
	}
	
	func logOutUser(username: String) {
		let space = protectionSpace()
		if let found = existingCredentialsForUser(username, space: space) {
			let store = NSURLCredentialStorage.sharedCredentialStorage()
			store.removeCredential(found, forProtectionSpace: space)
		}
	}
}
