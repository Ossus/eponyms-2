//
//  MainDocumentListViewController.swift
//  eponyms-2
//
//  Created by Pascal Pfiffner on 5/3/15.
//  Copyright (c) 2015 Ossus. All rights reserved.
//

import UIKit


/**
	Class to display a list of the titles of main documents.
 */
class MainDocumentListViewController: UITableViewController, TableViewDataSourceDelegate
{
	var sync: SyncController?
	
	var dataSource: CouchTableViewDataSource?
	
	override func awakeFromNib() {
		super.awakeFromNib()
		if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
			self.clearsSelectionOnViewWillAppear = false
			self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		assert(nil != sync, "Should have a Sync Controller before loading the view")
		let query = MainDocument.mainDocumentsByTitle(sync!.database, category: nil).asLiveQuery()!
		dataSource = CouchTableViewDataSource(delegate: self, query: query)
		dataSource!.tableView = self.tableView
		dataSource!.onWillReloadTable = { numRows in
			logIfVerbose("Will display \(numRows)")
		}
		dataSource!.onDidReloadTable = { numRows in
			logIfVerbose("Did display \(numRows)")
		}
		
		let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
		self.navigationItem.rightBarButtonItem = addButton
		
		// table view
		self.tableView?.registerClass(UITableViewCell.self, forCellReuseIdentifier: "mainCell")
		self.tableView?.reloadData()
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
	}
	
	
	// MARK: - Documents
	
	func insertNewObject(sender: AnyObject) {
		if let s = sync {
			let epo = MainDocument(newDocumentInDatabase: s.database)
			epo.key = "arnoldsnerve"
			epo.author = "pp"
			epo.localizations = ["en": ["title:": "Arnold's Nerve", "text": "Auricular branch of vagus nerve supplying posterior and inferior meatal skin of ear; stimulation can elicit cough reflex."]]
			epo.tags = ["neuro", "ent", "anat"]
			
			var error: NSError?
			if !epo.save(&error) {
				logIfVerbose("Failed to save: \(error)")
			}
			else {
				logIfVerbose("SAVED!")
			}
		}
		else {
			println("xx>  No SyncController")
		}
	}
	
	
	// MARK: - Data Source
	
	func dataSource(source: TableViewDataSource, hasNoSearchResultsForSearchString searchString: String) {
	}
	
	func dataSource(source: TableViewDataSource, tableViewCellForRowAt indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("mainCell", forIndexPath: indexPath) as! UITableViewCell
		return cell
	}
	
	
	// MARK: - Navigation
	
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		// Get the new view controller using [segue destinationViewController].
		// Pass the selected object to the new view controller.
	}
}
