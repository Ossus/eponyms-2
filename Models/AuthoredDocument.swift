//
//  AuthoredDocument.swift
//  eponyms-2
//
//  Created by Pascal Pfiffner on 4/26/15.
//  Copyright (c) 2015 Ossus. All rights reserved.
//

import Foundation
import CouchbaseLite


/**
Abstract superclass for all our models which need an author, a name in the "author" property.

This class also has "date" and "dateUpdated", which are handled at save time automatically.
*/
open class AuthoredDocument: CBLModel {
	
	/// The name of the original author of the document.
	@NSManaged var author: String
	
	/// When the document was first created.
	@NSManaged var date: Date?
	
	/// When the document was last updated.
	@NSManaged var dateUpdated: Date?
	
	/// This method is called after it's been initialized internally.
	open override func awakeFromInitializer() {
		super.awakeFromInitializer()
	}
	
	
	// MARK: - Saving
	
	open override func willSave(_ changedPropertyNames: Set<AnyHashable>?) {
		type = type(of: self).type()
		if nil == date {
			date = Date()
		}
		else {
			dateUpdated = Date()
		}
	}
	
	
	// MARK: - Type & Factory
	
	class func type() -> String {
		return "authored"
	}
	
	class func register(in factory: CBLModelFactory) {
		logIfVerbose("Registering \(self) for «\(type())»")
		factory.registerClass(self, forDocumentType: type())
	}
}

