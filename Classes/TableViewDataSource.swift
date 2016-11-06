//
//  TableViewDataSource.swift
//  eponyms-2
//
//  Created by Pascal Pfiffner on 5/3/15.
//  Copyright (c) 2015 Ossus. All rights reserved.
//

import UIKit


public protocol TableViewDataSourceDelegate: class {
	
	/**
	The delegate can return the cell in this method.
	*/
	func dataSource(_ source: TableViewDataSource, tableViewCellForRowAt indexPath: IndexPath) -> UITableViewCell
	
	/**
	Called by the search data source when a search produces no results.
	*/
	func dataSource(_ source: TableViewDataSource, hasNoSearchResultsForSearchString searchString: String)
}


open class TableViewDataSource: NSObject, UITableViewDataSource {
	
	weak var delegate: TableViewDataSourceDelegate?
	
	weak var tableView: UITableView? {
		didSet {
			tableView?.dataSource = self
		}
	}
	
	/// Will be called before reloading the table data.
	var onWillReloadTable: ((_ numRows: Int) -> ())?
	
	/// Will be called after reloading the table data.
	var onDidReloadTable: ((_ numRows: Int) -> ())?
	
	var isSearching: Bool { return false }
	
	init(delegate: TableViewDataSourceDelegate) {
		self.delegate = delegate
	}
	
	
	// MARK: - Items
	
	/** Return the item at the given index path. */
	func itemAtIndexPath(_ indexPath: IndexPath) -> AnyObject? {
		return nil;
	}
	
	/** Get an index path for the given item, or nil if it's not in the source. */
	func indexPathForItem(_ item: AnyObject) -> IndexPath? {
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
	func performSearchWithString(_ searchString: String) {
	}
	
	
	// MARK: - Convenience
	
	func numberOfSections() -> Int {
		return 0
	}
	
	func numberOfRowsInSection(_ section: Int) -> Int {
		return 0
	}
	
	func numberOfTotalRows() -> Int {
		return 0
	}
	
	
	// MARK: - Table View Data Source
	
	open func numberOfSections(in tableView: UITableView) -> Int {
		return numberOfSections()
	}
	
	open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return numberOfRowsInSection(section)
	}
	
	open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if let controller = delegate {
			return controller.dataSource(self, tableViewCellForRowAt: indexPath)
		}
		print("TableViewDataSource warning: cell requested but tableController is gone")
		return UITableViewCell()
	}
}

