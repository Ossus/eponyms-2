//
//  MainDocumentPageViewController.swift
//  eponyms-2
//
//  Created by Pascal Pfiffner on 25.03.17.
//  Copyright © 2017 Ossus. All rights reserved.
//

import UIKit


class MainDocumentPageViewController: UIPageViewController, UIPageViewControllerDataSource {
	
	var element: MainDocument?
	
	var category: MainDocument?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		dataSource = self
		if let element = element {
			let main = mainController(for: element, displayMode: .normal)
			setViewControllers([main], direction: .forward, animated: false)
		}
	}
	
	
	// MARK: - View Controllers
	
	func mainController(for element: MainDocument, displayMode: MainDocumentDisplayMode = .normal) -> UIViewController {
		guard let main = storyboard?.instantiateViewController(withIdentifier: "MainDocument") as? MainDocumentViewController else {
			fatalError("Must be able to instantiate a MainDocumentViewController from storyboard \(storyboard)")
		}
		main.element = element
		main.displayMode = displayMode
		return main
	}
	
	func randomMainElement() -> MainDocument? {
		guard let category = category else {
			NSLog("No category set, cannot show random")
			return nil
		}
		return nil
	}
	
	
	// MARK: - UIPageViewControllerDataSource
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
		guard let random = randomMainElement() else {
			return nil
		}
		return mainController(for: random, displayMode: .hiddenTitle)
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
		guard let random = randomMainElement() else {
			return nil
		}
		return mainController(for: random, displayMode: .hiddenText)
	}
}

