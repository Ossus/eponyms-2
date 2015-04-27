//
//  AuthoredDocument.swift
//  eponyms-2
//
//  Created by Pascal Pfiffner on 4/26/15.
//  Copyright (c) 2015 Ossus. All rights reserved.
//

import Foundation


/**
	Abstract superclass for all our models which need an author, a name in the "author" property.

	This class also has "date" and "dateUpdated", which are handled at save time automatically.
 */
class AuthoredDocument: CBLModel
{
	/// The name of the original author of the document.
	@NSManaged var author: String
	
	/// When the document was first created.
	@NSManaged var date: NSDate?
	
	/// When the document was last updated.
	@NSManaged var dateUpdated: NSDate?
	
	override init(document: CBLDocument) {
		super.init(document: document)
	}
	
	init(author athr: String) {
		super.init(document: nil)
		author = athr
	}
	
	
	// MARK: - Saving
	
	override func willSave(changedPropertyNames: Set<NSObject>!) {
		type = self.dynamicType.type()
		if nil == date {
			date = NSDate()
		}
		else {
			dateUpdated = NSDate()
		}
	}
	
	
	// MARK: - Type & Factory
	
	class func type() -> String {
		return "authored"
	}
	
	class func registerInFactory(factory: CBLModelFactory) {
		logIfVerbose("Registering \(self) for «\(type())»")
		factory.registerClass(self, forDocumentType: type())
	}
}

