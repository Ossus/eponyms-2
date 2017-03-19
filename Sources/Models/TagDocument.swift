//
//  TagDocument.swift
//  eponyms-2
//
//  Created by Pascal Pfiffner on 3/19/17.
//  Copyright © 2017 Ossus. All rights reserved.
//

import Foundation
import CouchbaseLite


/**
The class for a document describing a tag.
*/
open class TagDocument: TypedDocument {
	
	/// The tag name in all locales.
	@NSManaged var content: [String: String]?
	
	/// Shortcut to get the tag name in the current locale
	public var name: String {
		if let content = content {
			if let locale = Locale.current.languageCode, let localized = content[locale] {
				return localized
			}
			if let fallback = content[kLocaleFallback] {
				return fallback
			}
		}
		return "Unnamed Tag".app_loc
	}
	
	
	// MARK: - Views
	
	/**
	Returns the "mainDocumentsByTitle[Tag]" view as a Couchbase query that supports `fullTextQuery`.
	*/
	open class func tagDocumentsByTitle(_ database: CBLDatabase, in locale: String = kLocaleFallback) -> CBLQuery {
		let view = tagDocumentTitles(database, in: locale)
		let query = view.createQuery()
		query.descending = false
		let sort = NSSortDescriptor(key: "value", ascending: true, selector:#selector(NSString.caseInsensitiveCompare(_:)))
		query.sortDescriptors = [sort]
		
		return query
	}
	
	/**
	For all "tag" documents, emits the document's _id and the "title" as value in the given locale, like:
	
	"tag1", "What a Tag"
	"tag2", "Second Tag"
	*/
	class func tagDocumentTitles(_ database: CBLDatabase, in locale: String = kLocaleFallback) -> CBLView {
		let view = database.viewNamed("tagDocumentTitles")
		if nil == view.mapBlock {
			view.setMapBlock("2") { doc, emit in
				if "tag" == doc["type"] as? String {
					var name: String?
					if let content = doc["content"] as? [String: String] {
						if let localized = content[locale] {
							name = localized
						}
						else if let fallback = content[kLocaleFallback] {
							name = fallback
						}
					}
					emit(doc["_id"] ?? "{id}", name ?? "Unknown Tag")
				}
			}
		}
		return view
	}
	
	
	// MARK: - Type & Factory
	
	override public class var documentType: String {
		return "tag"
	}
}

