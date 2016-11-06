//
//  MainDocumentListViewController.swift
//  eponyms-2
//
//  Created by Pascal Pfiffner on 5/3/15.
//  Copyright (c) 2015 Ossus. All rights reserved.
//

import UIKit
import CouchbaseLite


/**
	Class to display a list of the titles of main documents.
 */
class MainDocumentListViewController: UITableViewController, TableViewDataSourceDelegate {
	
	var sync: SyncController?
	
	var dataSource: CouchTableViewDataSource?
	
	
	// MARK: - View Tasks
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		assert(nil != sync, "Should have a Sync Controller before loading the view")
		let query = MainDocument.mainDocumentsByTitle(sync!.database, category: nil).asLive()
		dataSource = CouchTableViewDataSource(delegate: self, query: query)
		dataSource!.tableView = self.tableView
		dataSource!.onWillReloadTable = { numRows in
			logIfVerbose("Will display \(numRows)")
		}
		dataSource!.onDidReloadTable = { numRows in
			logIfVerbose("Did display \(numRows)")
		}
		tableView.dataSource = dataSource
		
		let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(MainDocumentListViewController.insertNewObject(_:)))
		navigationItem.rightBarButtonItem = addButton
		
		// table view
		tableView?.register(UITableViewCell.self, forCellReuseIdentifier: "MainCell")
		tableView?.reloadData()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
		super.viewWillAppear(animated)
	}
	
	
	// MARK: - Documents
	
	func insertNewObject(_ sender: AnyObject) {
		guard let s = sync else {
			print("xx>  No SyncController")
			return
		}			
		let epo = MainDocument(forNewDocumentIn: s.database)
		epo._id = "arnoldsnerve"
		epo.author = "firstuser"
		epo.localizations = ["en": ["title": "Arnold's Nerve", "text": "Auricular branch of vagus nerve supplying posterior and inferior meatal skin of ear; stimulation can elicit cough reflex."]]
		epo.tags = ["neuro", "ent", "anat"]
		
		do {
			try epo.save()
			logIfVerbose("SAVED!")
		}
		catch let error {
			logIfVerbose("Failed to save: \(error)")
		}
	}
	
	
	// MARK: - Data Source
	
	func dataSource(_ source: TableViewDataSource, hasNoSearchResultsForSearchString searchString: String) {
	}
	
	func dataSource(_ source: TableViewDataSource, tableViewCellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "MainCell", for: indexPath)
		if let row = dataSource?.rowAtIndexPath(indexPath as NSIndexPath) {
			cell.textLabel?.text = MainDocument.mainDocumentsByTitleTitle(row)
		}
		return cell
	}
	
	
	// MARK: - Navigation
	
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		// Get the new view controller using [segue destinationViewController].
		// Pass the selected object to the new view controller.
	}
}

