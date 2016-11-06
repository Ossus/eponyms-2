//
//  MainDocument.swift
//  eponyms-2
//
//  Created by Pascal Pfiffner on 4/26/15.
//  Copyright (c) 2015 Ossus. All rights reserved.
//

import Foundation
import CouchbaseLite

let kLocaleFallback = "en"


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
	
	
	// MARK: - Views
	
	/**
	Returns the "mainDocumentsByTitle[Tag]" view as a Couchbase query that supports `fullTextQuery`.
	*/
	open class func mainDocumentsByTitle(_ database: CBLDatabase, locale: String = kLocaleFallback, tag: String? = nil) -> CBLQuery {
		let view = mainDocumentTitles(database, tag: tag, locale: locale)
		let query = view.createQuery()
		query.descending = false
		let sort = NSSortDescriptor(key: "value", ascending: true, selector:#selector(NSString.caseInsensitiveCompare(_:)))
		query.sortDescriptors = [sort]
		
		return query
	}
	
	/**
	For all "main" documents, emits the document's searchable text as a `CBLTextKey` and the "title" as value, in the given locale, like:
	
	    CBLTextKey(title + text), "The One Eponym"
	    CBLTextKey(title + text), "The Other Eponym"
	*/
	class func mainDocumentTitles(_ database: CBLDatabase, tag: String?, locale: String = kLocaleFallback) -> CBLView {
		let view = database.viewNamed("mainDocumentsByTitle\(tag ?? "")")
		if nil == view.mapBlock {
			view.setMapBlock("3") { doc, emit in
				if "main" == doc["type"] as? String {
					let tags = doc["tags"] as? [String] ?? []
					if nil == tag || tags.contains(tag!) {
						var title: String?
						var text: String?
						if let localized = doc["localized"] as? [String: JSONDoc]{
							if let inLocale = localized[locale] as? [String: String] {
								title = inLocale["title"]
								text = inLocale["text"]
							}
							else if let inFallback = localized[kLocaleFallback] as? [String: String] {
								title = title ?? inFallback["title"]
								text = text ?? inFallback["text"]
							}
						}
						emit(CBLTextKey("\(title ?? "")\n\n\(text ?? "")"), title)
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

