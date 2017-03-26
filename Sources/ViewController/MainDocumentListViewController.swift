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
class MainDocumentListViewController: UITableViewController, CBLUITableDelegate, UISearchBarDelegate {
	
	/// If set, will only show documents that have this tag. Also look at `category`.
	var tag: TagDocument? {
		didSet {
			title = tag?.name
		}
	}
	
	/// The category to show; only used if `tag` is nil.
	var category: Category? {
		didSet {
			if nil == tag {
				title = category?.name
			}
		}
	}
	
	var sync: SyncController!
	
	var dataSource: CBLUITableSource?
	
	@IBOutlet var searchBar: UISearchBar?
	
	
	// MARK: - View Tasks
	
	override func viewDidLoad() {
		super.viewDidLoad()
		assert(nil != sync, "Should have a Sync Controller before loading the view")
		
		dataSource = CBLUITableSource()
		dataSource!.tableView = self.tableView
		dataSource!.query = liveQuery()
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
	
	func couchTableSource(_ source: CBLUITableSource, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "MainDocCell", for: indexPath)
		if let row = dataSource?.row(at: indexPath) {
			cell.textLabel?.text = (row.value as? String) ?? "Unnamed"
			#if false
			if let row = row as? CBLFullTextQueryRow {
				let snippets = row.snippet(withWordStart: ">", wordEnd: "<").components(separatedBy: CharacterSet.newlines)
				let snippet = snippets.filter() { return snippets[0] != $0 }.joined(separator: " ")
			}
			else {
				cell.detailTextLabel?.text = nil
			}
			#endif
		}
		return cell
	}
	
	
	// MARK: - Search
	
	private func documentQuery() -> CBLQuery {
		if let tag = tag?.document?.documentID {
			return MainDocument.mainDocumentsByTitle(sync.database, tag: tag)
		}
		if let query = category?.query(in: sync.database) {
			return query
		}
		return MainDocument.mainDocumentsByTitle(sync.database, tag: nil)
	}
	
	func liveQuery(searchingFor: String? = nil) -> CBLLiveQuery {
		let query = documentQuery().asLive()
		if let searchText = searchingFor, searchText.characters.count > 0 {
			let parts = searchText.components(separatedBy: CharacterSet.whitespaces)
			query.fullTextQuery = parts.map() {
				if 0 == $0.characters.count || "AND" == $0 || "OR" == $0 || "NEAR" == $0 || $0.hasSuffix(")") || $0.hasSuffix("*") {
					return $0
				}
				return $0+"*"
			}.joined(separator: " ")
			logIfVerbose("Performing full text query: \(query.fullTextQuery)")
			//query.fullTextSnippets = true
			query.fullTextRanking = false
		}
		return query
	}
	
	func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
		searchBar.setShowsCancelButton(true, animated: true)
	}
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		dataSource!.query = liveQuery(searchingFor: searchText)
	}
	
	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		searchBar.text = nil
		searchBar.setShowsCancelButton(false, animated: true)
		searchBar.resignFirstResponder()
		dataSource!.query = liveQuery()
	}
	
	
	// MARK: - Navigation
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "showDetail" {
			guard let target = (segue.destination as? UINavigationController)?.topViewController as? MainDocumentPageViewController else {
				preconditionFailure("A valid segue from here must point to a MainDocumentPageViewController, but points to \(segue.destination)")
			}
			guard let selection = tableView.indexPathForSelectedRow else {
				NSLog("No selected row")
				return
			}
			guard let document = dataSource?.document(at: selection), let model = MainDocument(for: document) else {
				NSLog("Cannot represent document at \(selection) as MainDocument model")
				return
			}
			target.element = model
		}
	}
}

