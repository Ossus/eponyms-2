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
class MainDocumentListViewController: UITableViewController, CBLUITableDelegate {
	
	var sync: SyncController?
	
	var dataSource: CBLUITableSource?
	
	
	// MARK: - View Tasks
	
	override func viewDidLoad() {
		super.viewDidLoad()
		assert(nil != sync, "Should have a Sync Controller before loading the view")
		
		dataSource = CBLUITableSource()
		dataSource!.tableView = self.tableView
		dataSource!.query = MainDocument.mainDocumentsByTitle(sync!.database, category: nil).asLive()
		tableView.dataSource = dataSource
		
		let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(MainDocumentListViewController.suggestNewMainDocument(_:)))
		navigationItem.rightBarButtonItem = addButton
	}
	
	override func viewWillAppear(_ animated: Bool) {
		clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
		super.viewWillAppear(animated)
	}
	
	
	// MARK: - Documents
	
	func suggestNewMainDocument(_ sender: AnyObject) {
		// TODO: implement
		print("suggestNewMainDocument()")
	}
	
	
	// MARK: - CBLUITableDelegate
	
	func couchTableSource(_ source: CBLUITableSource, cellForRowAt indexPath: IndexPath) -> UITableViewCell? {
		let cell = tableView.dequeueReusableCell(withIdentifier: "MainDocCell", for: indexPath)
		if let row = dataSource?.row(at: indexPath) {
			cell.textLabel?.text = MainDocument.titleFromMainDocumentsByTitleQuery(row)
		}
		return cell
	}
	
	
	// MARK: - Navigation
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "showDetail" {
			guard let mainDocController = segue.destination as? MainDocumentViewController else {
				preconditionFailure("A valid segue from here must point to a MainDocumentViewController, but points to \(segue.destination)")
			}
			guard let selection = tableView.indexPathForSelectedRow else {
				NSLog("No selected row")
				return
			}
			let document = dataSource?.document(at: selection)
			guard let model = document?.modelObject as? MainDocument else {
				NSLog("Cannot represent document \(document) as MainDocument model")
				return
			}
			mainDocController.object = model
		}
	}
}

