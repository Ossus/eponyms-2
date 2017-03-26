//
//  MainDocumentViewController.swift
//  eponyms-2
//
//  Created by Pascal Pfiffner on 06.11.16.
//  Copyright © 2016 Ossus. All rights reserved.
//

import UIKit


public enum MainDocumentDisplayMode: Int {
	case normal
	case hiddenTitle
	case hiddenText
}


class MainDocumentViewController: UIViewController {
	
	var element: MainDocument?
	
	var displayMode = MainDocumentDisplayMode.normal
	
	@IBOutlet var titleLabel: UILabel!
	
	@IBOutlet var textLabel: UILabel!
	
	@IBOutlet var tagLabel: UILabel!
	
	
	// MARK: - View Tasks
	
	override func viewDidLoad() {
		super.viewDidLoad()
		if let element = element {
			updateDisplay(for: element)
		}
	}
	
	
	// MARK: - Main Display
	
	func updateDisplay(for main: MainDocument) {
		// TODO: show
		
		// apply display mode
		switch displayMode {
		case .hiddenText:
			textLabel.textColor = textLabel.superview?.backgroundColor
			solverButton(inPlaceOf: textLabel)
		case .hiddenTitle:
			titleLabel.textColor = titleLabel.superview?.backgroundColor
			solverButton(inPlaceOf: titleLabel)
		default:
			break
		}
	}
	
	func solveDisplay(_ sender: AnyObject?) {
		UIView.animate(withDuration: 0.25) {
			self.titleLabel?.textColor = UIColor.black
			self.titleLabel?.subviews.forEach() { $0.removeFromSuperview() }
			self.textLabel?.textColor = UIColor.black
			self.textLabel?.subviews.forEach() { $0.removeFromSuperview() }
		}
	}
	
	func solverButton(inPlaceOf view: UIView) {
		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setTitle("🤔", for: .normal)
		button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title2)
		button.titleLabel?.textAlignment = .center
		button.titleLabel?.tintColor = UIColor.black
		button.addTarget(self, action: #selector(MainDocumentViewController.solveDisplay(_:)), for: .touchUpInside)
		
		view.addSubview(button)
		view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[button]|", options: [], metrics: nil, views: ["button": button]))
		view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[button]|", options: [], metrics: nil, views: ["button": button]))
	}
}

