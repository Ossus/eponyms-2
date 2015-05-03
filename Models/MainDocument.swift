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
	
	/// A dictionary of sub-documents localizing localizable parts of the main document.
	@NSManaged var localizations: JSONDoc
	
	/// A list of tags this main element belongs to.
	@NSManaged var tags: [String]
	
	override class func type() -> String {
		return "main"
	}
	
	
	// MARK: - Views
	
	class func mainDocumentsByTitle(database: CBLDatabase, category: String?) -> CBLQuery {
		let view = mainDocumentTitlesByTag(database)
		let query = view.createQuery()
		query.descending = false
		query.keys = [category ?? "*"]
		
		return query
	}
	
	/**
		For all "main" documents that have localizations, emits a one-item array where the array item as the array of
		tags, and a mini-document with the document's "_id" and a "titles" dictionary, like:
	
		`{"_id": "abc", "titles": {"en": "English Title", "de": "Deutscher Titel"}}`
	 */
	class func mainDocumentTitlesByTag(database: CBLDatabase) -> CBLView {
		let view = database.viewNamed("mainDocumentsByTitle")
		if nil == view.mapBlock {
			view.setMapBlock("1") { doc, emit in
				if "main" == doc["type"] as? String {
					var tags = doc["tags"] as? [String] ?? []
					tags.insert("*", atIndex: 0)
					let titles = (doc["localizations"] as? JSONDoc)?.map() { (key, val) in (key, val["title"] as? String ?? "Unnamed") }
					emit(tags, ["_id": doc["_id"] ?? NSNull(), "titles": titles ?? NSNull()])
				}
			}
		}
		return view
	}
}

