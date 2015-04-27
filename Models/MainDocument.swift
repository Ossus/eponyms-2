//
//  MainDocument.swift
//  eponyms-2
//
//  Created by Pascal Pfiffner on 4/26/15.
//  Copyright (c) 2015 Ossus. All rights reserved.
//

import Foundation

let kMainDocumentFallbackLocale = "en"


/**
	The class for the main document type in the database, e.g. an Eponym.
 */
class MainDocument: AuthoredDocument
{
	/// The key identifying the main document.
	@NSManaged var key: String
	
	/// A dictionary of documents localizing localizable parts of the main document.
	@NSManaged var localizations: JSONDoc
	
	/// A list of tags this main element belongs to.
	@NSManaged var tags: [String]
	
	override class func type() -> String {
		return "main"
	}
	
	
	// MARK: - Views
	
	class func mainDocumentsByTitle(category: String?, locale: String, database: CBLDatabase) -> CBLQuery {
		let view = mainDocumentTitlesByCategory(database)
		let query = view.createQuery()
		query.descending = false
		
		if let cat = category {
			query.keys = [cat]
		}
		
		return query
	}
	
	/**
		For all "main" documents that have localizations, emits a one-item array where the array item as the array of
		tags, and a mini-document with the document's "_id" and a "titles" dictionary, like:
	
		`{"_id": "abc", "titles": {"en": "English Title", "de": "Deutscher Titel"}}`
	 */
	class func mainDocumentTitlesByCategory(database: CBLDatabase) -> CBLView {
		let view = database.viewNamed("mainDocumentsByTitle")
		if nil == view.mapBlock {
			view.setMapBlock("1") { doc, emit in
				if "main" == doc["type"] as? String {
					if let loc = doc["localizations"] as? JSONDoc {
						let titles = loc.map() { (key, val) in (key, val["title"] as? String ?? "Unnamed") }
						emit([loc.keys.array], ["_id": doc["_id"] ?? NSNull(), "titles": titles])
					}
				}
			}
		}
		return view
	}
}

