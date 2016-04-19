//
//  User.swift
//  eponyms-2
//
//  Created by Pascal Pfiffner on 4/1/16.
//  Copyright © 2016 Ossus. All rights reserved.
//

import Foundation


/// Sent when a user logs in.
public let UserDidLoginNotification = "UserDidLoginNotification"

/// Sent when a user logs out.
public let UserDidLogoutNotification = "UserDidLogoutNotification" 


public class User {
	
	var name: String?
	
	var email: String?
	
	var password: String?
	
	
	// MARK: - Login/Logout
	
	public func login() {
		NSNotificationCenter.defaultCenter().postNotificationName(UserDidLoginNotification, object: self)
	}
	
	
	public func logout() {
		NSNotificationCenter.defaultCenter().postNotificationName(UserDidLogoutNotification, object: self)
	}
}