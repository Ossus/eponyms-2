//
//  CBLExtensions.swift
//  eponyms-2
//
//  Created by Pascal Pfiffner on 4/26/15.
//  Copyright (c) 2015 Ossus. All rights reserved.
//

import Foundation
import CouchbaseLite

public typealias JSONDoc = [String: Any]


extension CBLView {
	
	/**
	Just reorders the parameters to take advantage of Swift's trailing-block syntax.
	*/
	@discardableResult
	func setMapBlock(_ version: String, mapBlock: @escaping CBLMapBlock) -> Bool {
		return setMapBlock(mapBlock, version: version)
	}
}

