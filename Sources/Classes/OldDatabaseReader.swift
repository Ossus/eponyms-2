//
//  OldDatabaseReader.swift
//  eponyms-2
//
//  Created by Pascal Pfiffner on 3/20/17.
//  Copyright © 2017 Ossus. All rights reserved.
//

import Foundation
import SQLite


/**
Capable of reading the SQL database for favorites present in v 1.x. Relies on stephencelis/SQLite.swift.
*/
public class OldDatabaseReader {
	
	public static var databaseLocation: URL? {
		let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
		if let dir = paths.first {
			return URL(fileURLWithPath: dir, isDirectory: true).appendingPathComponent("eponyms.sqlite")
		}
		return nil
	}
	
	/**
	Attempts to read the database file at the old location and returns a tuple with id-arrays.
	
	- returns: nil or a tuple with (starred, recent) eponym identifiers
	*/
	public func starredAndRecentIds() throws -> ([String], [String])? {
		guard let path = type(of: self).databaseLocation?.path else {
			return nil
		}
		
		var starred = [String]()
		var recent = [String]()
		
		let db = try Connection(path, readonly: true)
		let eponyms = Table("eponyms")
		let id = Expression<String>("identifier")
		
		// find starred
		let star = Expression<Int64>("starred")
		let query1 = eponyms.select(id).filter(star == 1)
		for row in try db.prepare(query1) {
			starred.append(row[id].lowercased())
		}
		
		// find recent
		let lastaccess = Expression<Int64>("lastaccess")
		let query2 = eponyms.select(id).filter(lastaccess > 0).order(lastaccess.desc).limit(25)
		for row in try db.prepare(query2) {
			recent.append(row[id].lowercased())
		}
		
		return (starred, recent)
	}
}

