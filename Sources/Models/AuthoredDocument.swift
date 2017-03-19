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
Abstract superclass for all our models which are audited and have authors.
*/
open class AuthoredDocument: TypedDocument {
	
	/// An array of actions that were done to the document.
	@NSManaged var audits: [[String: String]]?
	
	/// This method is called after it's been initialized internally.
	override open func awakeFromInitializer() {
		super.awakeFromInitializer()
	}
	
	
	// MARK: - Type & Factory
	
	override public class var documentType: String {
		return "authored"
	}
}

