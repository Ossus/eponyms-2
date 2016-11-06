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
open class CouchTableSection {
	
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
	
	open func numberOfRows() -> Int {
		return (rows).count
	}
	
	open func indexForDocument(_ document: CBLDocument) -> Int? {
		let docId = document.documentID
		var rowIdx = 0
		for row in rows {
			if row.documentID == docId {
				return rowIdx
			}
			rowIdx += 1
		}
		return nil
	}
	
	open func addObject(_ row: CBLQueryRow) {
		rows.append(row)
	}
}


/**
A table view data source that hooks into a Couchbase live query.
*/
open class CouchTableViewDataSource: TableViewDataSource {
	
	deinit {
		stopObservingQuery()
	}
	
	var sections = [CouchTableSection]()
	
	fileprivate var totalRows: Int = 0
	
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
			onWillReloadTable?(totalRows)
			tableView?.reloadData()
			onDidReloadTable?(totalRows)
		}
		else {
			totalRows = 0
		}
	}
	
	open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
		if let query = query {
			if !ignoreNextObservedRowChange {
				reloadFromQuery()
			}
			else {
				totalRows = query.rows?.allObjects.count ?? 0
				onDidReloadTable?(totalRows)
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
	
	func rowAtIndexPath(_ indexPath: NSIndexPath) -> CBLQueryRow? {
		return self[indexPath.section]?[indexPath.row]
	}
	
	func documentAtIndexPath(_ indexPath: NSIndexPath) -> CBLDocument? {
		return rowAtIndexPath(indexPath)?.document
	}
	
	func indexPathForDocument(_ document: CBLDocument) -> IndexPath? {
		var sectionIdx = 0
		for section in sections {
			if let rowIdx = section.indexForDocument(document) {
				return IndexPath(row: rowIdx, section: sectionIdx)
			}
			sectionIdx += 1
		}
		return nil
	}
	
	
	// MARK: - Editing
	
	
	// MARK: - Integrate Couch into Table Data Source
	
	override func numberOfSections() -> Int {
		return sections.count
	}
	
	override func numberOfRowsInSection(_ sectionIdx: Int) -> Int {
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

