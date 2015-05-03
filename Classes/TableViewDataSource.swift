//
//  TableViewDataSource.swift
//  eponyms-2
//
//  Created by Pascal Pfiffner on 5/3/15.
//  Copyright (c) 2015 Ossus. All rights reserved.
//

import UIKit


protocol TableViewDataSourceDelegate: class
{
	/**
		The delegate can return the cell in this method.
	 */
	func dataSource(source: TableViewDataSource, tableViewCellForRowAt indexPath: NSIndexPath) -> UITableViewCell
	
	/**
		Called by the search data source when a search produces no results.
	 */
	func dataSource(source: TableViewDataSource, hasNoSearchResultsForSearchString searchString: String)
}


class TableViewDataSource: NSObject, UITableViewDataSource
{
	weak var delegate: TableViewDataSourceDelegate?
	
	weak var tableView: UITableView? {
		didSet {
			tableView?.dataSource = self
		}
	}
	
	/// Will be called before reloading the table data.
	var onWillReloadTable: ((numRows: Int) -> ())?
	
	/// Will be called after reloading the table data.
	var onDidReloadTable: ((numRows: Int) -> ())?
	
	var isSearching: Bool { return false }
	
	init(delegate: TableViewDataSourceDelegate) {
		self.delegate = delegate
	}
	
	
	// MARK: - Items
	
	/** Return the item at the given index path. */
	func itemAtIndexPath(indexPath: NSIndexPath) -> AnyObject? {
		return nil;
	}
	
	/** Get an index path for the given item, or nil if it's not in the source. */
	func indexPathForItem(item: AnyObject) -> NSIndexPath? {
		return nil
	}
	
	/**
		Might be called when the receiver's data should be reloaded.
	
		Default implementation does nothing.
	 */
	func reload() {
	}
	
	
	// MARK: - Search
	
	/**
		Give the data source the chance to prepare for search operations.
	
		Default implementation does nothing.
	 */
	func prepareForSearch() {
	}
	
	/**
		Ask the data source to update the table after searching for the given string.
	
		Default implementation does nothing.
	 */
	func performSearchWithString(searchString: String) {
	}
	
	
	// MARK: - Convenience
	
	func numberOfSections() -> Int {
		return 0
	}
	
	func numberOfRowsInSection(section: Int) -> Int {
		return 0
	}
	
	func numberOfTotalRows() -> Int {
		return 0
	}
	
	
	// MARK: - Table View Data Source
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return numberOfSections()
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return numberOfRowsInSection(section)
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		if let controller = delegate {
			return controller.dataSource(self, tableViewCellForRowAt: indexPath)
		}
		println("TableViewDataSource warning: cell requested but tableController is gone")
		return UITableViewCell()
	}
}

