//
//  MasterViewController.swift
//  eponyms-2
//
//  Created by Pascal Pfiffner on 3/2/15.
//  Copyright (c) 2015 Ossus. All rights reserved.
//

import UIKit


class MasterViewController: UITableViewController {
	
	var objects = [AnyObject]()
	
	var sync: SyncController?
	
	
	// MARK: - View Tasks
	
	override func viewWillAppear(_ animated: Bool) {
		self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
		super.viewWillAppear(animated)
	}
	
	
	// MARK: - Segues
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "showList" {
		    if let indexPath = self.tableView.indexPathForSelectedRow {
//		        let object = objects[indexPath.row]
		        let controller = (segue.destination as! UINavigationController).topViewController as! MainDocumentListViewController
		        controller.sync = sync
		        controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
		        controller.navigationItem.leftItemsSupplementBackButton = true
		    }
		}
	}
	
	
	// MARK: - Table View
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
		return objects.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) 
		
//		let object = objects[indexPath.row]
		cell.textLabel!.text = "All Eponyms"
		return cell
	}
}

