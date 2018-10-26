//
//  RootViewController.swift
//  Yelp
//
//  Created by Jeremy Fuellert on 2018-10-23.
//  Copyright © 2018 Jeremy Fuellert. All rights reserved.
//

import UIKit
import CoreLocation

class RootViewController: UIViewController {
    
    // MARK: - Properties
    fileprivate var result: RestaurantResultsModel?
    fileprivate lazy var viewController: UISplitViewController = {
        
        var viewControllers: [UIViewController] = [listViewController]
        if UIDevice.current.userInterfaceIdiom == .pad {
            viewControllers.append(restaurantViewController)
        }
        
        let viewController                  = UISplitViewController()
        viewController.viewControllers      = viewControllers
        viewController.preferredDisplayMode = .allVisible
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
    
    fileprivate let locationManager: CLLocationManager = {
        
        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        return locationManager
    }()
    
    fileprivate let debounce = Debounce(0.25)
    fileprivate var request: URLSessionDataTask?

    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()

        viewController.willMove(toParent: self)
        view.addSubview(viewController.view)
        addChild(viewController)
        viewController.didMove(toParent: self)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Location services disabled
        let locationServicesEnabled = CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse
        guard locationServicesEnabled else {
            listViewController.reloadDataWithMessage(.locationServicesDisabled)
            return
        }
        
        guard result?.total ?? 0 > 0 else {
            listViewController.reloadDataWithMessage(.coachMark)
            return
        }
    }
}

// MARK: - Networking
extension RootViewController {

    func search(_ term: String?) {
        
        //Coachmark
        guard let term = term, !term.isEmpty else {
            listViewController.reloadDataWithMessage(.coachMark)
            return
        }
        
        //Location
        guard let coordinates = locationManager.location?.coordinate else {
            listViewController.reloadDataWithMessage(.locationServicesDisabled)
            return
        }
        
        listViewController.collectionView.alpha                    = 0.3
        listViewController.collectionView.isUserInteractionEnabled = false
        listViewController.activityIndicator.startAnimating()
        request?.cancel()
        request = RestaurantModelFactory.fetchRestaurantsWithTerm(term, coordinates: coordinates, completion: { [weak self] (model, error) in
            
            guard let `self` = self else {
                return
            }
            
            self.listViewController.activityIndicator.stopAnimating()
            self.listViewController.collectionView.alpha                    = 1
            self.listViewController.collectionView.isUserInteractionEnabled = true
            
            guard let model = model, model.total > 0 else {
                self.listViewController.reloadDataWithMessage(.noResultsFound)
                return
            }
            
            self.result = model
            self.result?.restaurants.sort(by: { (model1, model2) -> Bool in
                let name1 = model1.name ?? "0"
                let name2 = model2.name ?? "1"

                return name1 < name2
            })
            
            self.listViewController.reloadDataWithMessage()
        })
    }
}

// MARK: - ListViewControllerDelegate
extension RootViewController: ListViewControllerDelegate {
    
    func listViewControllerRestaurants(_ viewController: ListViewController) -> RestaurantResultsModel? {
        return result
    }
    
    func listViewControllerDidSelect(_ viewController: ListViewController, term: String?) {
        
        debounce.renewInterval()
        debounce.handler = { [weak self] in
            self?.search(term)
        }
    }
    
    func listViewControllerDidSelect(_ viewController: ListViewController, index: Int) {
        
        guard let item = result?.restaurants[index] else {
            return
        }
        
        restaurantViewController.update(item)

        guard UIDevice.current.userInterfaceIdiom == .phone else {
            return
        }
        
        navigationController?.pushViewController(restaurantViewController, animated: true)
    }
}

// MARK: - UISplitViewControllerDelegate
extension RootViewController: UISplitViewControllerDelegate {


}
