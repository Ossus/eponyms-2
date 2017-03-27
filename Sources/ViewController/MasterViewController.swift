//
//  MasterViewController.swift
//  eponyms-2
//
//  Created by Pascal Pfiffner on 3/2/15.
//  Copyright (c) 2015 Ossus. All rights reserved.
//

import UIKit
import CouchbaseLite


/**
The master view controller, shown first and center.
*/
class MasterViewController: UITableViewController, CBLUITableDelegate {
	@IBOutlet var row1: UIView?
	@IBOutlet var row2: UIView?
	@IBOutlet var row3: UIView?
	
	var sync: SyncController?
	
	var dataSource: CBLUITableSource?
	
	
	// MARK: - View Tasks
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// setup fake first 3 table rows
		let scale = UIScreen.main.scale
		row1?.layer.borderColor = UIColor(red: 0.7843, green: 0.7804, blue: 0.8, alpha: 1.0).cgColor
		row2?.layer.borderColor = UIColor(red: 0.7843, green: 0.7804, blue: 0.8, alpha: 1.0).cgColor
		row3?.layer.borderColor = UIColor(red: 0.7843, green: 0.7804, blue: 0.8, alpha: 1.0).cgColor
		row1?.layer.borderWidth = 1.0 / scale
		row2?.layer.borderWidth = 1.0 / scale
		row3?.layer.borderWidth = 1.0 / scale
		
		let recognizer = UITapGestureRecognizer(target: self, action: #selector(MasterViewController.didRecognizeGesture(_:)))
		row1?.superview?.addGestureRecognizer(recognizer)
		
		dataSource = CBLUITableSource()
		dataSource!.tableView = self.tableView
		dataSource!.query = TagDocument.tagDocumentsByTitle(sync!.database).asLive()
		tableView.dataSource = dataSource
	}
	
	override func viewWillAppear(_ animated: Bool) {
		self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
		super.viewWillAppear(animated)
	}
	
	
	// MARK: - CBLUITableDelegate
	
	func couchTableSource(_ source: CBLUITableSource, cellForRowAt indexPath: IndexPath) -> UITableViewCell? {
		let cell = tableView.dequeueReusableCell(withIdentifier: "TagDocCell", for: indexPath)
		if let row = dataSource?.row(at: indexPath) {
			cell.textLabel?.text = (row.value as? String) ?? "Unnamed Tag"
		}
		return cell
	}
	
	
	// MARK: - Tag Gesture
	
	func didRecognizeGesture(_ recognizer: UITapGestureRecognizer) {
		if .recognized == recognizer.state {
			if let row = row1, row.bounds.contains(recognizer.location(in: row)) {
				self.performSegue(withIdentifier: "showList", sender: Category.all)
			}
			else if let row = row2, row.bounds.contains(recognizer.location(in: row)) {
				self.performSegue(withIdentifier: "showList", sender: Category.starred)
			}
			else if let row = row3, row.bounds.contains(recognizer.location(in: row)) {
				self.performSegue(withIdentifier: "showList", sender: Category.recent)
			}
		}
	}
	
	
	// MARK: - Segues
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "showList" {
			let controller = segue.destination as! MainDocumentListViewController
			if let indexPath = self.tableView.indexPathForSelectedRow, let document = dataSource?.document(at: indexPath) {
				controller.tag = TagDocument(for: document)
			}
			else if let sender = sender as? Category {
				controller.category = sender
			}
			controller.sync = sync
			controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
			controller.navigationItem.leftItemsSupplementBackButton = true
		}
	}
}

