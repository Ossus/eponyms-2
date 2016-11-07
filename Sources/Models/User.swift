//
//  User.swift
//  eponyms-2
//
//  Created by Pascal Pfiffner on 4/1/16.
//  Copyright © 2016 Ossus. All rights reserved.
//

import Foundation


/// Sent when a user logs in.
public let UserDidLoginNotification = Notification.Name(rawValue: "UserDidLoginNotification")

/// Sent when a user logs out.
public let UserDidLogoutNotification = Notification.Name(rawValue: "UserDidLogoutNotification")


open class User {
	
	var name: String?
	
	var email: String?
	
	var password: String?
	
	
	// MARK: - Login/Logout
	
	open func login() {
		NotificationCenter.default.post(name: UserDidLoginNotification, object: self)
	}
	
	
	open func logout() {
		NotificationCenter.default.post(name: UserDidLogoutNotification, object: self)
	}
}
