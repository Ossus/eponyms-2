//
//  CBLExtensions.swift
//  eponyms-2
//
//  Created by Pascal Pfiffner on 4/26/15.
//  Copyright (c) 2015 Ossus. All rights reserved.
//

import Foundation

public typealias JSONDoc = [String: AnyObject]


extension CBLView
{
	// Just reorders the parameters to take advantage of Swift's trailing-block syntax.
	func setMapBlock(version: String, mapBlock: CBLMapBlock) -> Bool {
		return setMapBlock(mapBlock, version: version)
	}
}

extension CBLDocument
{
	// Just reorders the parameters to take advantage of Swift's trailing-block syntax.
	func update(error: NSErrorPointer, block: ((CBLUnsavedRevision!) -> Bool)) -> CBLSavedRevision? {
		return update(block, error: error)
	}
}


/**
	Write a map() function for dictionaries.
 */
extension Dictionary
{
	init(_ pairs: [Element]) {
		self.init()
		for (k, v) in pairs {
			self[k] = v
		}
	}
	
	func map<OutKey: Hashable, OutValue>(transform: Element -> (OutKey, OutValue)) -> [OutKey: OutValue] {
		return Dictionary<OutKey, OutValue>(Swift.map(self, transform))
	}
}

