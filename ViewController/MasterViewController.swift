//
//  MasterViewController.swift
//  eponyms-2
//
//  Created by Pascal Pfiffner on 3/2/15.
//  Copyright (c) 2015 Ossus. All rights reserved.
//

import UIKit


class MasterViewController: UITableViewController {
	
	var tags = [AnyObject]()
	
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
				if 0 == indexPath.section {
					if 1 == indexPath.row  {
						
					}
					else if 2 == indexPath.row {
						
					}
				}
				else {
//					let object = objects[indexPath.row]
				}
		        let controller = (segue.destination as! UINavigationController).topViewController as! MainDocumentListViewController
		        controller.sync = sync
		        controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
		        controller.navigationItem.leftItemsSupplementBackButton = true
		    }
		}
	}
	
	
	// MARK: - Table View
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if 1 == section {
			return "Categories"
		}
		return nil
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if 0 == section {
			return 3
		}
		return tags.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) 
		if 0 == indexPath.section {
			if 0 == indexPath.row {
				cell.textLabel?.text = "All Eponyms"
			}
			else if 1 == indexPath.row {
				cell.textLabel?.text = "Starred Eponyms"
			}
			else if 2 == indexPath.row {
				cell.textLabel?.text = "Recent Eponyms"
			}
		}
		else {
//			let object = tags[indexPath.row]
			cell.textLabel?.text = "Category"
		}
		return cell
	}
}

