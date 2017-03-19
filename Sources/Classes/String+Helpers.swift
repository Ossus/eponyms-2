//
//  String+Helpers.swift
//  eponyms-2
//
//  Created by Pascal Pfiffner on 3/19/17.
//  Copyright © 2017 Ossus. All rights reserved.
//

import Foundation


extension String {
	
	/// Uses `NSLocalizedString` to return the receiver's localized counterpart.
	public var app_loc: String {
		return NSLocalizedString(self, comment: "")
	}
}

