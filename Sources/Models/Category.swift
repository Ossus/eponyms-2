//
//  Category.swift
//  eponyms-2
//
//  Created by Pascal Pfiffner on 3/19/17.
//  Copyright © 2017 Ossus. All rights reserved.
//

import CouchbaseLite


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
	
	/// The CouchbaseQuery to use for the category.
	public func query(in database: CBLDatabase) -> CBLQuery? {
		switch self {
		case .starred: return UserPrefsDocument.starredDocumentsByTitle(database)
		case .recent:  return UserPrefsDocument.recentDocuments(database)
		default:       return nil
		}
	}
}

