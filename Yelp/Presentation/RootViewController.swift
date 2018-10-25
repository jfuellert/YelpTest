//
//  RootViewController.swift
//  Yelp
//
//  Created by Jeremy Fuellert on 2018-10-23.
//  Copyright © 2018 Jeremy Fuellert. All rights reserved.
//

import UIKit

class RootViewController: UISplitViewController {
    
    // MARK: - Properties
    fileprivate var result: RestaurantResultsModel?
    fileprivate lazy var viewController: UISplitViewController = {

        let viewController                  = UISplitViewController()
        viewController.preferredDisplayMode = .allVisible
        viewController.viewControllers      = [listViewController, restaurantViewController]
        viewController.delegate             = self

        return viewController
    }()
    
    fileprivate lazy var listViewController: ListViewController = {
        
        let viewController      = ListViewController()
        viewController.delegate = self
        
        return viewController
    }()
    
    fileprivate let restaurantViewController: RestaurantViewController = {
        
        let viewController = RestaurantViewController()
        
        return viewController
    }()
    
    fileprivate var request: URLSessionDataTask?

    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()

        viewController.willMove(toParent: self)
        view.addSubview(viewController.view)
        addChild(viewController)
        viewController.didMove(toParent: self)
    }
}

// MARK: - Networking
extension RootViewController {

    func search(_ term: String?) {
        
        listViewController.activityIndicator.startAnimating()
        request?.cancel()
        request = RestaurantModelFactory.fetchRestaurantsWithTerm("s") { [weak self] (model, error) in
            
            guard let `self` = self else {
                return
            }
            
            self.listViewController.activityIndicator.stopAnimating()
            self.result = model
            self.result?.restaurants.sort(by: { (model1, model2) -> Bool in
                let name1 = model1.name ?? ""
                let name2 = model2.name ?? ""

                return name1 > name2
            })
            
            self.listViewController.reloadData()
        }
    }
}

// MARK: - ListViewControllerDelegate
extension RootViewController: ListViewControllerDelegate {
    
    func listViewControllerRestaurants(_ viewController: ListViewController) -> RestaurantResultsModel? {
        return result
    }
    
    func listViewControllerDidSelect(_ viewController: ListViewController, term: String?) {
        search(term)
    }
    
    func listViewControllerDidSelect(_ viewController: ListViewController, index: Int) {
        
        guard let item = result?.restaurants[index] else {
            return
        }
        
        //show on details
        if UIDevice.current.userInterfaceIdiom == .pad {
            restaurantViewController.update(item)
            return
        }
        
//        viewController.showDetailViewController(restaurantViewController(item), sender: self)
    }
}


// MARK: - UISplitViewControllerDelegate
extension RootViewController: UISplitViewControllerDelegate {


}
