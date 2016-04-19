//
//  UserViewController.swift
//  eponyms-2
//
//  Created by Pascal Pfiffner on 4/1/16.
//  Copyright © 2016 Ossus. All rights reserved.
//

import UIKit


public class UserViewController: UITableViewController {
	
	var user: User?
	
	
	// MARK: - View Tasks
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "User")
		tableView.registerClass(LoginButtonCell.self, forCellReuseIdentifier: "Login")
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
	
	public override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 2
	}
	
	public override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if 0 == section {
			return 3
		}
		return 1
	}
	
	public override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		// user details
		if 0 == indexPath.section {
			let cell = tableView.dequeueReusableCellWithIdentifier("User", forIndexPath: indexPath)
			if nil != user {
				cell.textLabel?.textColor = UIColor.blackColor()
			}
			else {
				cell.textLabel?.textColor = UIColor.grayColor()
			}
			
			if 0 == indexPath.row {
				cell.textLabel?.text = user?.name ?? "Name"
			}
			else if 1 == indexPath.row {
				cell.textLabel?.text = user?.email ?? "Email"
			}
			else if 2 == indexPath.row {
				cell.textLabel?.text = user?.password ?? "Password"
			}
			return cell
		}
		
		// login button
		let cell = tableView.dequeueReusableCellWithIdentifier("Login", forIndexPath: indexPath) as! LoginButtonCell
		cell.textLabel?.text = (nil == user) ? "Login" : "Logout"
		
		return cell
	}
	
	
	// MARK: - Table View Delegate
	
	public override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		if 1 == indexPath.section {
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
			self.textLabel?.textColor = UIColor.redColor()
			self.textLabel?.textAlignment = .Center
		}
		
		required init?(coder: NSCoder) {
			super.init(coder: coder)
		}
	}
}


// MARK: - 

public class DismissFromModalSegue: UIStoryboardSegue {
	
	public override func perform() {
		sourceViewController.dismissViewControllerAnimated(true, completion: nil)
	}
}

