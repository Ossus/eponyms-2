//
//  UserPrefsDocument.swift
//  eponyms-2
//
//  Created by Pascal Pfiffner on 3/20/17.
//  Copyright © 2017 Ossus. All rights reserved.
//

import Foundation
import CouchbaseLite


/**
One such document should be present on the device with the user's data preferences.
*/
open class UserPrefsDocument: TypedDocument {
	
	/// Array of tiny docs of starred/favorite main documents.
	@NSManaged var starred: [JSONDoc]?
	
	/// Array of tiny docs of most recent main documents.
	@NSManaged var recent: [JSONDoc]?
	
	
	// MARK: - Views
	
	/**
	Returns the "starredDocumentsByTitle" view as a Couchbase query that supports `fullTextQuery`.
	*/
	open class func starredDocumentsByTitle(_ database: CBLDatabase, locale: String = kLocaleFallback) -> CBLQuery {
		let view = starredDocumentTitles(database, in: locale)
		let query = view.createQuery()
		query.descending = false
		let sort = NSSortDescriptor(key: "value", ascending: true, selector:#selector(NSString.caseInsensitiveCompare(_:)))
		query.sortDescriptors = [sort]
		
		return query
	}
	
	/**
	Returns the "recentDocuments" view as a Couchbase query that supports `fullTextQuery`.
	*/
	open class func recentDocuments(_ database: CBLDatabase, locale: String = kLocaleFallback) -> CBLQuery {
		let view = recentDocumentTitles(database, in: locale)
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
	class func starredDocumentTitles(_ database: CBLDatabase, in locale: String = kLocaleFallback) -> CBLView {
		let view = database.viewNamed("starredDocumentTitles")
		if nil == view.mapBlock {
			view.setMapBlock("1") { doc, emit in
				if "userprefs" == doc["type"] as? String, let starred = doc["starred"] as? [JSONDoc] {
					for doc in starred {
						let (name, text) = MainDocument.nameAndText(in: doc, in: locale)
						emit(CBLTextKey("\(name ?? "")\n\n\(text ?? "")"), name)
					}
				}
			}
		}
		return view
	}
	
	/**
	For all "main" documents, emits the document's searchable text as a `CBLTextKey` and the "title" as value, in the given locale, like:
	
	CBLTextKey(title + text), "The One Eponym"
	CBLTextKey(title + text), "The Other Eponym"
	*/
	class func recentDocumentTitles(_ database: CBLDatabase, in locale: String = kLocaleFallback) -> CBLView {
		let view = database.viewNamed("recentDocumentTitles")
		if nil == view.mapBlock {
			view.setMapBlock("1") { doc, emit in
				if "userprefs" == doc["type"] as? String, let recent = doc["recent"] as? [JSONDoc] {
					var i = 0
					let nf = NumberFormatter()
					nf.paddingCharacter = "0"
					nf.paddingPosition = .beforeSuffix
					nf.minimumIntegerDigits = 4
					for doc in recent {
						let (name, text) = MainDocument.nameAndText(in: doc, in: locale)
						emit(CBLTextKey("\(nf.string(for: i)): \(name ?? "")\n\n\(text ?? "")"), name)
						i += 1
					}
				}
			}
		}
		return view
	}
	
	
	// MARK: - Type & Factory
	
	override public class var documentType: String {
		return "userprefs"
	}
}

