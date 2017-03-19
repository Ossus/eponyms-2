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
Abstract superclass for all our documents which have `type`, which is already handled by `CBLModel`.
*/
open class TypedDocument: CBLModel {
	
	// MARK: - Saving
	
	open override func willSave(_ changedPropertyNames: Set<AnyHashable>?) {
		type = type(of: self).documentType
	}
	
	
	// MARK: - Type & Factory
	
	public class var documentType: String {
		return "typed"
	}
	
	class func register(in factory: CBLModelFactory) {
		logIfVerbose("Registering \(self) for «\(documentType)»")
		factory.registerClass(self, forDocumentType: documentType)
	}
}

