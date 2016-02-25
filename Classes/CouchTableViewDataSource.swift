//
//  CouchTableViewDataSource.swift
//  eponyms-2
//
//  Created by Pascal Pfiffner on 5/3/15.
//  Copyright (c) 2015 Ossus. All rights reserved.
//

import Foundation
import CouchbaseLite


/**
Manages the rows in one table view section.
*/
public class CouchTableSection {
	
	var rows = [CBLQueryRow]()
	
	public init(rows: [CBLQueryRow]) {
		self.rows = rows
	}
	
	subscript(index: Int) -> CBLQueryRow? {
		if rows.count > index {
			return rows[index]
		}
		return nil
	}
	
	
	// MARK: - Rows
	
	public func numberOfRows() -> Int {
		return (rows).count
	}
	
	public func indexForDocument(document: CBLDocument) -> Int? {
		let docId = document.documentID
		var rowIdx = 0
		for row in rows {
			if row.documentID == docId {
				return rowIdx
			}
			rowIdx++
		}
		return nil
	}
	
	public func addObject(row: CBLQueryRow) {
		rows.append(row)
	}
}


/**
A table view data source that hooks into a Couchbase live query.
*/
public class CouchTableViewDataSource: TableViewDataSource {
	
	deinit {
		stopObservingQuery()
	}
	
	var sections = [CouchTableSection]()
	
	private var totalRows: Int = 0
	
	var query: CBLLiveQuery? {
		willSet {
			stopObservingQuery()
		}
		didSet {
			startObservingQuery()
			reloadFromQuery()
		}
	}
	
	/// We need this because on deleting rows, our observer would call "reloadTable" before the animation takes place.
	var ignoreNextObservedRowChange = false
	
	
	public init(delegate: TableViewDataSourceDelegate, query: CBLLiveQuery) {
		self.query = query
		super.init(delegate: delegate)
		startObservingQuery()
	}
	
	
	// MARK: - Query
	
	func startObservingQuery() {
		if let qry = query {
			qry.addObserver(self, forKeyPath: "rows", options: [], context: nil)
		}
	}
	
	func stopObservingQuery() {
		if let qry = query {
			qry.removeObserver(self, forKeyPath: "rows")
		}
	}
	
	func reloadFromQuery() {
		if let rows = query?.rows {
			var oldSections = sections
			var allRows = rows.allObjects as? [CBLQueryRow] ?? []
			totalRows = allRows.count
			
			// TODO: allow delegate to sectionize rows
			let section = CouchTableSection(rows: allRows)
			sections = [section]
			
			// call will-reload block, let delegate reload (or do it ourselves, as currently implemented), then call did-reload block
			onWillReloadTable?(numRows: totalRows)
			tableView?.reloadData()
			onDidReloadTable?(numRows: totalRows)
		}
		else {
			totalRows = 0
		}
	}
	
	public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
		if nil != query && object === query! {
			if !ignoreNextObservedRowChange {
				reloadFromQuery()
			}
			else {
				totalRows = query?.rows?.allObjects.count ?? 0
				onDidReloadTable?(numRows: totalRows)
			}
			ignoreNextObservedRowChange = false
		}
	}
	
	
	// MARK: - Accessors
	
	subscript(sectionIdx: Int) -> CouchTableSection? {
		if sectionIdx < sections.count {
			return sections[sectionIdx]
		}
		return nil
	}
	
	func rowAtIndexPath(indexPath: NSIndexPath) -> CBLQueryRow? {
		return self[indexPath.section]?[indexPath.row]
	}
	
	func documentAtIndexPath(indexPath: NSIndexPath) -> CBLDocument? {
		return rowAtIndexPath(indexPath)?.document
	}
	
	func indexPathForDocument(document: CBLDocument) -> NSIndexPath? {
		var sectionIdx = 0
		for section in sections {
			if let rowIdx = section.indexForDocument(document) {
				return NSIndexPath(forRow: Int(rowIdx), inSection: sectionIdx)
			}
			sectionIdx++
		}
		return nil
	}
	
	
	// MARK: - Editing
	
	
	// MARK: - Integrate Couch into Table Data Source
	
	override func numberOfSections() -> Int {
		return sections.count
	}
	
	override func numberOfRowsInSection(sectionIdx: Int) -> Int {
		if let section = self[sectionIdx] {
			return section.numberOfRows()
		}
		return 0
	}
	
	
//	override func sectionIndexTitlesForTableView(tableView: UITableView) -> [AnyObject]! {
//	}

//	override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
//	}

//	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//	}
}

