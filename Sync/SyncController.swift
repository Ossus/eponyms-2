//
//  SyncController.swift
//  eponyms-2
//
//  Created by Pascal Pfiffner on 4/25/15.
//  Copyright (c) 2015 Ossus. All rights reserved.
//

import Foundation
import CouchbaseLite


let kSyncGatewayUrl = URL(string: "http://192.168.10.22:4999/eponyms")!


open class SyncController {
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	
	/// Handle to our database.
	open let database: CBLDatabase
	
	/// The pull replicator.
	let pull: CBLReplication
	
	/// The push replicator.
	let push: CBLReplication
	
	/// The URL protection space for our Sync Gateway.
	lazy var protectionSpace: URLProtectionSpace = {
		return URLProtectionSpace(
			host: kSyncGatewayUrl.host!,
			port: (kSyncGatewayUrl as NSURL).port as! Int,
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
		database = try manager.databaseNamed(name)
		
		// register model classes
		if let factory = database.modelFactory {
			MainDocument.register(in: factory)
		}
		
		// setup replication
		pull = database.createPullReplication(kSyncGatewayUrl)
		pull.continuous = false
		push = database.createPushReplication(kSyncGatewayUrl)
		push.continuous = true
		
		NotificationCenter.default.addObserver(forName: NSNotification.Name.cblReplicationChange, object: push, queue: nil, using: replicationChanged)
		NotificationCenter.default.addObserver(forName: NSNotification.Name.cblReplicationChange, object: pull, queue: nil, using: replicationChanged)
		
		logIfVerbose("-->  Initialized SyncController with database at \(manager.directory)/\(database), \(database.documentCount) documents")
	}
	
	
	// MARK: - Local Import
	
	/**
	Import all documents found in a JSON document. The JSON document must have a top level "documents" key that is an array of documents.
	
	- parameter file: The filename WITHOUT "json" extension
	- parameter deleteExisting: If true, will drop the whole DB first!
	*/
	public func importLocalDocuments(from file: String, deleteExisting: Bool = false) throws {
		guard let url = Bundle.main.url(forResource: file, withExtension: "json") else {
			throw NSError(domain: "ch.ossus.eponyms.Sync", code: 389, userInfo: [NSLocalizedDescriptionKey: "There does not seem to exist a file “\(file).json” in the main Bundle"])
		}
		let data = try Data(contentsOf: url)
		let json = try JSONSerialization.jsonObject(with: data, options: []) as! JSONDoc
		guard let all = json["documents"] as? [JSONDoc] else {
			throw NSError(domain: "ch.ossus.eponyms.Sync", code: 786, userInfo: [NSLocalizedDescriptionKey: "There must be an array of dictionaries under the top-level “documents” key in \(file).json, but there isn't"])
		}
		
		// delete existing?
		if deleteExisting {
//			try database.delete()
			// TODO: doesn't work
		}
		
		// import all documents
		database.inTransaction {
			for epo in all {
				let document = self.database.createDocument()
				do {
					try document.putProperties(epo)
				}
				catch let error {
					print("xxxx>  ERROR IMPORTING, ROLLING BACK. Error was: \(error)")
					return false
				}
			}
			print("====>  Imported \(self.database.documentCount) documents")
			return true
		}
	}
	
	
	// MARK: - Sync Gateway
	
	/**
	Start push and pull replication. Will automatically suspend when the app goes into background.
	*/
	open func sync() {
		push.start()
		pull.start()
	}
	
	public var isSyncing: Bool {
		return (pull.status == CBLReplicationStatus.active) || (push.status == CBLReplicationStatus.active)
	}
	
	open var syncStatus: String {
		switch pull.status {
		case .active:
			return "active"
		case .idle:
			return "idle"
		case .stopped:
			return "stopped"
		case .offline:
			return "offline"
		}
	}
	
	func replicationChanged(_ notification: Notification) {
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
	func authorize(user: User) throws {
		guard let username = user.name else {
			throw SyncError.noUsername
		}
		
		if let found = existingCredentials(for: username, space: protectionSpace) {
			logIfVerbose("Sync: found password for “\(username)”")
			pull.credential = found
			push.credential = found
			return
		}
		
		// log in if we have a password
		if let pass = user.password {
			logIfVerbose("Sync: logging in as “\(username)”")
			let cred = logIn(user: username, password: pass, space: protectionSpace)
			pull.credential = cred
			push.credential = cred
		}
		throw SyncError.noPassword
	}
	
	open func deAuthorize(_ user: User) throws {
		guard let username = user.name else {
			throw SyncError.noUsername
		}
		logOut(user: username, space: protectionSpace)
	}
	
	/** Returns a list of usernames that have credentials for our Sync Gateway. */
	func loggedInUsers(_ space: URLProtectionSpace) -> [String]? {
		let store = URLCredentialStorage.shared
		guard let found = store.credentials(for: space) else {
			return nil
		}
		var usernames = [String]()
		for (usr, _) in found {
			usernames.append(usr)
		}
		return usernames
	}
	
	func existingCredentials(for user: String, space: URLProtectionSpace) -> URLCredential? {
		let store = URLCredentialStorage.shared
		if let found = store.credentials(for: space) {
			for (usr, cred) in found {
				if usr == user {
					return cred
				}
			}
		}
		return nil
	}
	
	open func logIn(user: String, password: String, space: URLProtectionSpace) -> URLCredential {
		let store = URLCredentialStorage.shared
		let credentials = URLCredential(user: user, password: password, persistence: .permanent)
		store.set(credentials, for: space)
		return credentials
	}
	
	open func logOut(user: String, space: URLProtectionSpace) {
		if let found = existingCredentials(for: user, space: space) {
			let store = URLCredentialStorage.shared
			store.remove(found, for: space)
		}
	}
}

