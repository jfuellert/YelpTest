//
//  ListViewController.swift
//  Yelp
//
//  Created by Jeremy Fuellert on 2018-10-24.
//  Copyright © 2018 Jeremy Fuellert. All rights reserved.
//

import UIKit

protocol ListViewControllerDelegate: class {
    func listViewControllerRestaurants(_ viewController: ListViewController) -> RestaurantResultsModel?
    func listViewControllerDidSelect(_ viewController: ListViewController, term: String?)
    func listViewControllerDidSelect(_ viewController: ListViewController, index: Int)
}

class ListViewController: UIViewController {
    
    // MARK: - Properties
    weak var delegate: ListViewControllerDelegate?
    fileprivate lazy var searchBar: UISearchBar = {
        
        let searchBar                                       = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.searchBarStyle                            = .minimal
        searchBar.delegate                                  = self
        
        return searchBar
    }()
    
    fileprivate lazy var collectionView: UICollectionView = {
        
        let layout = UICollectionViewFlowLayout()
        
        let collectionView                                       = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor                           = .white
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource                                = self
        collectionView.delegate                                  = self
        collectionView.register(ListViewCollectionViewCell.self, forCellWithReuseIdentifier: ListViewCollectionViewCell.reuseIdentifier)

        return collectionView
    }()
    
    let activityIndicator: UIActivityIndicatorView = {
        
        let activityIndicator                                       = UIActivityIndicatorView()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        return activityIndicator
    }()

    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        view.addSubview(searchBar)
        view.addSubview(collectionView)
        view.addSubview(activityIndicator)
        createConstraints()
    }
    
    // MARK: - Updates
    func reloadData() {
        collectionView.reloadData()
    }
    
    // MARK: - Constraints
    fileprivate func createConstraints() {
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leftAnchor.constraint(equalTo: view.leftAnchor),
            searchBar.rightAnchor .constraint(equalTo: view.rightAnchor),
            
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionView.rightAnchor .constraint(equalTo: view.rightAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
    }
}

// MARK: - UISearchBarDelegate
extension ListViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        delegate?.listViewControllerDidSelect(self, term: searchText)
    }
}

// MARK: - UICollectionViewDataSource
extension ListViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return delegate?.listViewControllerRestaurants(self)?.total ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ListViewCollectionViewCell.reuseIdentifier, for: indexPath) as? ListViewCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        guard let item = delegate?.listViewControllerRestaurants(self)?.restaurants[indexPath.item] else {
            return cell
        }
        
        cell.update(item)
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension ListViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.listViewControllerDidSelect(self, index: indexPath.item)
    }
}
