//
//  Category.swift
//  eponyms-2
//
//  Created by Pascal Pfiffner on 3/19/17.
//  Copyright © 2017 Ossus. All rights reserved.
//


/**
Special categories for main documents
*/
public enum Category: String {
	case all = "All Eponyms"
	case starred = "Starred Eponyms"
	case recent = "Recent Eponyms"
	
	/// The localized name for the category.
	public var name: String {
		return rawValue.app_loc
	}
}

