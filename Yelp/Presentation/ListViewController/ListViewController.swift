//
//  ListViewController.swift
//  Yelp
//
//  Created by Jeremy Fuellert on 2018-10-24.
//  Copyright © 2018 Jeremy Fuellert. All rights reserved.
//

import UIKit

enum ListViewControllerMessage {
    case none
    case coachMark
    case locationServicesDisabled
    case noResultsFound
    
    fileprivate func string() -> String? {
        switch self {
            case .coachMark:
                return NSLocalizedString("Start typing to begin your search", comment: "")
            case .locationServicesDisabled:
                return NSLocalizedString("Location services are disabled, please enable to search", comment: "")
            case .noResultsFound:
                return NSLocalizedString("No results found", comment: "")
            default:
                return nil
        }
    }
}

protocol ListViewControllerDelegate: class {
    func listViewControllerRestaurants(_ viewController: ListViewController) -> RestaurantResultsModel?
    func listViewControllerDidSelect(_ viewController: ListViewController, term: String?)
    func listViewControllerDidSelect(_ viewController: ListViewController, index: Int)
}

class ListViewController: UIViewController {
    
    // MARK: - Constants
    private let kCollectionViewCellPadding: CGFloat    = 20
    private let kCollectionViewSectionPadding: CGFloat = 20

    // MARK: - Properties
    weak var delegate: ListViewControllerDelegate?
    fileprivate lazy var searchBar: UISearchBar = {
        
        let searchBar                                       = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.searchBarStyle                            = .minimal
        searchBar.tintColor                                 = .red
        searchBar.delegate                                  = self
        searchBar.placeholder                               = NSLocalizedString("Search for restaurants", comment: "")
        
        return searchBar
    }()
    
    lazy var collectionView: UICollectionView = {
        
        let layout          = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: kCollectionViewSectionPadding, left: kCollectionViewSectionPadding, bottom: kCollectionViewSectionPadding, right: kCollectionViewSectionPadding)
        
        let collectionView                                       = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor                           = .white
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource                                = self
        collectionView.delegate                                  = self
        collectionView.register(ListViewCollectionViewCell.self, forCellWithReuseIdentifier: ListViewCollectionViewCell.reuseIdentifier)

        return collectionView
    }()
    
    fileprivate let messageLabel: UILabel = {
        
        let label                                       = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font                                      = UIFontMetrics.default.scaledFont(for: UIFont.preferredFont(forTextStyle: .body))
        label.textAlignment                             = .center
        label.numberOfLines                             = 0
        
        return label
    }()
    
    let activityIndicator: UIActivityIndicatorView = {
        
        let activityIndicator                                       = UIActivityIndicatorView(style: .gray)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        return activityIndicator
    }()

    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        view.addSubview(searchBar)
        view.addSubview(collectionView)
        view.addSubview(messageLabel)
        view.addSubview(activityIndicator)
        createConstraints()
    }
    
    // MARK: - Updates
    func reloadDataWithMessage(_ messageType: ListViewControllerMessage = .none) {
        
        //Configure message
        let message       = messageType.string()
        messageLabel.text = message
        
        let displayMessage      = message != nil && !message!.isEmpty
        collectionView.isHidden = displayMessage
        
        guard !displayMessage else {
            return
        }
        
        //Reload data if no message to display
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
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
            
            messageLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30),
            messageLabel.rightAnchor .constraint(equalTo: view.rightAnchor, constant: -30),
            messageLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
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
        return delegate?.listViewControllerRestaurants(self)?.restaurants.count ?? 0
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

// MARK: - UICollectionViewDelegateFlowLayout
extension ListViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        guard let collectionViewLayout = collectionViewLayout as? UICollectionViewFlowLayout else {
            return .zero
        }
        
        let collectionViewSize = collectionView.frame.width - collectionViewLayout.sectionInset.left - collectionViewLayout.sectionInset.right - kCollectionViewCellPadding
        let cellSize           = collectionViewSize * 0.5
        
        return CGSize(width: cellSize, height: cellSize)
    }
}
