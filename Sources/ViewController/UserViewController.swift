//
//  UserViewController.swift
//  eponyms-2
//
//  Created by Pascal Pfiffner on 4/1/16.
//  Copyright © 2016 Ossus. All rights reserved.
//

import UIKit


open class UserViewController: UITableViewController {
	
	var user: User?
	
	
	// MARK: - View Tasks
	
	open override func viewDidLoad() {
		super.viewDidLoad()
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "User")
		tableView.register(LoginButtonCell.self, forCellReuseIdentifier: "Login")
	}
	
	
	// MARK: - Login / Logout
	
	func login() {
		guard nil == user else {
			return
		}
		let usr = User()
		usr.name = "firstuser"
		usr.password = "passs"
		usr.login()
		user = usr
		tableView.reloadData()
	}
	
	func logout() {
		guard let user = user else {
			return
		}
		user.logout()
		self.user = nil
		tableView.reloadData()
	}
	
	
	// MARK: - Table View Data Source
	
	open override func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}
	
	open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if 0 == section {
			return 3
		}
		return 1
	}
	
	open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		// user details
		if 0 == (indexPath as NSIndexPath).section {
			let cell = tableView.dequeueReusableCell(withIdentifier: "User", for: indexPath)
			if nil != user {
				cell.textLabel?.textColor = UIColor.black
			}
			else {
				cell.textLabel?.textColor = UIColor.gray
			}
			
			if 0 == (indexPath as NSIndexPath).row {
				cell.textLabel?.text = user?.name ?? "Name"
			}
			else if 1 == (indexPath as NSIndexPath).row {
				cell.textLabel?.text = user?.email ?? "Email"
			}
			else if 2 == (indexPath as NSIndexPath).row {
				cell.textLabel?.text = user?.password ?? "Password"
			}
			return cell
		}
		
		// login button
		let cell = tableView.dequeueReusableCell(withIdentifier: "Login", for: indexPath) as! LoginButtonCell
		cell.textLabel?.text = (nil == user) ? "Login" : "Logout"
		
		return cell
	}
	
	
	// MARK: - Table View Delegate
	
	open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if 1 == (indexPath as NSIndexPath).section {
			if nil == user {
				login()
			}
			else {
				logout()
			}
		}
	}
	
	
	// MARK: - Cells
	
	class LoginButtonCell: UITableViewCell {
		
		override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
			super.init(style: style, reuseIdentifier: reuseIdentifier)
			self.textLabel?.textColor = UIColor.red
			self.textLabel?.textAlignment = .center
		}
		
		required init?(coder: NSCoder) {
			super.init(coder: coder)
		}
	}
}


// MARK: - 

open class DismissFromModalSegue: UIStoryboardSegue {
	
	open override func perform() {
		source.dismiss(animated: true, completion: nil)
	}
}

