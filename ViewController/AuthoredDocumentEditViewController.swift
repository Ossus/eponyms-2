//
//  AuthoredDocumentEditViewController.swift
//  eponyms-2
//
//  Created by Pascal Pfiffner on 5/3/15.
//  Copyright (c) 2015 Ossus. All rights reserved.
//

import UIKit


class AuthoredDocumentEditViewController: UIViewController
{
	var document: AuthoredDocument? {
		didSet {
			if isViewLoaded() {
				updateView()
			}
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		updateView()
    }
	
	
	// MARK: - View Update
	
	func updateView() {
		if let doc = document {
			
		}
	}
}
