//
//  MainDocument.swift
//  eponyms-2
//
//  Created by Pascal Pfiffner on 4/26/15.
//  Copyright (c) 2015 Ossus. All rights reserved.
//

import Foundation
import CouchbaseLite

let kMainDocumentFallbackLocale = "en"


/**
The class for the main document type in the database, e.g. an Eponym.
*/
open class MainDocument: AuthoredDocument {
	
	/// The document identifier.
	@NSManaged var _id: String
	
	/// A dictionary of sub-documents localizing localizable parts of the main document.
	@NSManaged var localizations: JSONDoc
	
	/// A list of tags this main element belongs to.
	@NSManaged var tags: [String]
	
	/**
	Feed a row coming from a `mainDocumentsByTitle()` query row to receive the title in the preferred locale.
	
	- parameter row: A query result row from the "mainDocumentsByTitle" query
	- parameter locale: The preferred locale, will fall back to `kMainDocumentFallbackLocale`
	- returns: The document title or nil
	*/
	open class func titleFromMainDocumentsByTitleQuery(_ row: CBLQueryRow, locale: String? = nil) -> String? {
		guard let titles = row.value as? [String: String] else {
			return "Unnamed"
		}
		if let locale = locale, let title = titles[locale] {
			return title
		}
		return titles[kMainDocumentFallbackLocale]
	}
	
	
	// MARK: - Views
	
	open class func mainDocumentsByTitle(_ database: CBLDatabase, category: String?) -> CBLQuery {
		let view = mainDocumentTitlesByTag(database)
		let query = view.createQuery()
		query.descending = false
		query.keys = [category ?? "*"]
		
		return query
	}
	
	/**
	For all "main" documents that have localizations, emits a mini-document with the document's "titles" dictionary once for every tag and
	the universal "*" tag, like:
	
	    "*", {"en": "English Title", "de": "Deutscher Titel"}
	    "neuro", {"en": "English Title", "de": "Deutscher Titel"}
	*/
	class func mainDocumentTitlesByTag(_ database: CBLDatabase) -> CBLView {
		let view = database.viewNamed("mainDocumentsByTitle")
		if nil == view.mapBlock {
			view.setMapBlock("3") { doc, emit in
				if "main" == doc["type"] as? String {
					let tags = doc["tags"] as? [String] ?? []
					var titles = [String: String]()
					if let localized = doc["localized"] as? [String: JSONDoc] {
						for (lang, data) in localized {
							titles[lang] = data["title"] as? String ?? "Unnamed"
						}
					}
					emit("*", titles)
					for tag in tags {
						emit(tag, titles)
					}
				}
			}
		}
		return view
	}
	
	
	// MARK: - Type & Factory
	
	override public class var documentType: String {
		return "main"
	}
}

