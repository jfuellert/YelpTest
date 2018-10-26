//
//  RestaurantViewController.swift
//  Yelp
//
//  Created by Jeremy Fuellert on 2018-10-24.
//  Copyright © 2018 Jeremy Fuellert. All rights reserved.
//

import MapKit
import SDWebImage

class RestaurantViewController: UIViewController {

    // MARK: - Constants
    private static var contentVerticalPadding: CGFloat   = 10
    private static var contentHorizontalPadding: CGFloat = 10
    private static var mapSpanInMeters                   = 50.0

    // MARK: - Properties
    fileprivate let scrollView: UIScrollView = {
        
        let scrollView                                       = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        return scrollView
    }()
    
    fileprivate let contentView: UIView = {
        
        let contentView                                       = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        return contentView
    }()
    
    fileprivate let imageView: UIImageView = {
        
        let imageView                                       = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    fileprivate let titleLabel: UILabel = {
        
        let label                                       = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font                                      = UIFontMetrics.default.scaledFont(for: UIFont.preferredFont(forTextStyle: .body))
        label.numberOfLines                             = 0
        
        return label
    }()
    
    fileprivate let subTitleLabel: UITextView = {
        
        let label                                       = UITextView()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font                                      = UIFontMetrics.default.scaledFont(for: UIFont.preferredFont(forTextStyle: .body))
        label.dataDetectorTypes                         = [.link]
        label.tintColor                                 = .red
        label.isEditable                                = false
        label.isScrollEnabled                           = false
        
        return label
    }()
    
    fileprivate let mapView: MKMapView = {
        
        let mapView                                       = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.isHidden                                  = true
        
        return mapView
    }()
    
    fileprivate let reviewTitleLabel: UILabel = {
        
        let label                                       = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font                                      = UIFontMetrics.default.scaledFont(for: UIFont.preferredFont(forTextStyle: .headline))
        label.text                                      = NSLocalizedString("Most recent review:", comment: "")
        
        return label
    }()
    
    fileprivate let reviewLabel: UILabel = {
        
        let label                                       = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font                                      = UIFontMetrics.default.scaledFont(for: UIFont.preferredFont(forTextStyle: .body))
        label.numberOfLines                             = 0

        return label
    }()
    
    fileprivate let activityIndicator: UIActivityIndicatorView = {
        
        let activityIndicator                                       = UIActivityIndicatorView(style: .gray)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        return activityIndicator
    }()
    
    fileprivate var identifier: String?
    fileprivate var request: URLSessionDataTask?
    
    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subTitleLabel)
        contentView.addSubview(mapView)
        contentView.addSubview(reviewTitleLabel)
        contentView.addSubview(reviewLabel)
        reviewLabel.addSubview(activityIndicator)
        createFavouriteButton()
        createConstraints()
        updateFavourite()
    }
    
    private func createFavouriteButton() {
        navigationItem.rightBarButtonItem            = UIBarButtonItem(image: nil, style: .plain, target: self, action: #selector(onFavouriteButton))
        navigationItem.rightBarButtonItem?.tintColor = .red
    }
    
    fileprivate func updateFavourite() {
        
        guard let identifier = identifier else {
            return
        }
        
        navigationItem.rightBarButtonItem?.image = PersistentStore.favourites.contains(identifier) ? UIImage(named: "favourite_active") : UIImage(named: "favourite_inactive")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    // MARK: - Updates
    func update(_ restaurantModel: RestaurantModel) {
        
        mapView.isHidden = false
        
        //Set data
        identifier = restaurantModel.identifier
        
        if let imageURL = restaurantModel.imageUrlString, let url = URL(string: imageURL) {
            imageView.sd_setImage(with: url, completed: nil)
        }
        
        if let coordinates = restaurantModel.coordinates, let latitude = coordinates.latitude, let longitude = coordinates.longitude {
            mapView.setCenter(CLLocationCoordinate2D(latitude: latitude, longitude: longitude), animated: false)
        }
        
        title              = restaurantModel.name
        subTitleLabel.text = restaurantModel.URLString
        updateAddress(restaurantModel)
        updateLocation(restaurantModel.coordinates)
        
        //Load review
        reviewLabel.text = nil
        fetchReview()
    }
    
    private func updateAddress(_ model: RestaurantModel) {
        
        var address = ""
        if let value = model.location?.address1 {
            address = value
        }
        
        if let value = model.location?.address2 {
            if address.count > 0 {
                address += ", "
            }
            address += value
        }
        
        if let value = model.location?.city {
            if address.count > 0 {
                address += ", "
            }
            address += value
        }
        
        if let value = model.location?.country {
            if address.count > 0 {
                address += ", "
            }
            address += value
        }
        
        titleLabel.text = address
    }
    
    private func updateLocation(_ model: CoordinatesModel?) {
        
        guard let latitude = model?.latitude, let longitude = model?.longitude else {
            return
        }
        
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), latitudinalMeters: RestaurantViewController.mapSpanInMeters, longitudinalMeters: RestaurantViewController.mapSpanInMeters)
        mapView.setRegion(region, animated: false)
    }
    
    // MARK: - Layout subviews
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateContentSize()
    }
    
    fileprivate func updateContentSize() {
        scrollView.contentSize = CGSize(width: view.frame.width, height: reviewLabel.frame.maxY + RestaurantViewController.contentVerticalPadding)
    }
    
    // MARK: - Constraints
    fileprivate func createConstraints() {
        
        NSLayoutConstraint.activate([scrollView.topAnchor.constraint(equalTo: view.topAnchor),
                                    scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                                    scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                                    scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                                    
                                    contentView.topAnchor.constraint(equalTo: view.topAnchor),
                                    contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                                    contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                                    contentView.bottomAnchor.constraint(equalTo: reviewLabel.bottomAnchor, constant: RestaurantViewController.contentVerticalPadding),
                                    
                                    imageView.topAnchor.constraint(equalTo: scrollView.topAnchor),
                                    imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                                    imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                                    imageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.3),
                                    
                                    titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: RestaurantViewController.contentVerticalPadding),
                                    titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: RestaurantViewController.contentHorizontalPadding),
                                    titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -RestaurantViewController.contentHorizontalPadding),
                                    
                                    subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: RestaurantViewController.contentVerticalPadding),
                                    subTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: RestaurantViewController.contentHorizontalPadding),
                                    subTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -RestaurantViewController.contentHorizontalPadding),
                                    subTitleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: subTitleLabel.font?.lineHeight ?? 20),

                                    mapView.topAnchor.constraint(equalTo: subTitleLabel.bottomAnchor, constant: RestaurantViewController.contentVerticalPadding),
                                    mapView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.3),
                                    mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: RestaurantViewController.contentHorizontalPadding),
                                    mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -RestaurantViewController.contentHorizontalPadding),
                                    
                                    reviewTitleLabel.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: RestaurantViewController.contentVerticalPadding),
                                    reviewTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: RestaurantViewController.contentHorizontalPadding),
                                    reviewTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -RestaurantViewController.contentHorizontalPadding),
                                    
                                    reviewLabel.topAnchor.constraint(equalTo: reviewTitleLabel.bottomAnchor, constant: RestaurantViewController.contentVerticalPadding),
                                    reviewLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: RestaurantViewController.contentHorizontalPadding),
                                    reviewLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -RestaurantViewController.contentHorizontalPadding),
                                    
                                    activityIndicator.centerXAnchor.constraint(equalTo: reviewLabel.centerXAnchor),
                                    activityIndicator.centerYAnchor.constraint(equalTo: reviewLabel.centerYAnchor)
                                     ])
    }
}

// MARK: - Actions
extension RestaurantViewController {
    
    @objc fileprivate func onFavouriteButton(_ item: UIBarButtonItem) {
        
        guard let identifier = identifier else {
            return
        }
        
        if PersistentStore.favourites.contains(identifier) {
            PersistentStore.favourites.remove(identifier)
        } else {
            PersistentStore.favourites.insert(identifier)
        }
        
        updateFavourite()
    }
}

// MARK: - Networking
extension RestaurantViewController {
    
    @objc fileprivate func fetchReview() {
        
        request?.cancel()
        
        guard let identifier = identifier else {
            return
        }
        
        activityIndicator.startAnimating()
        request = RestaurantModelFactory.fetchReviewsWithRestaurantIdentifier(identifier, completion: { [weak self] (model, error) in
            
            guard let `self` = self else {
                return
            }
            
            self.activityIndicator.stopAnimating()
            guard let model = model, let firstReview = model.reviews.first else {
                self.reviewLabel.text = NSLocalizedString("No reviews found", comment: "")
                return
            }
            
            self.reviewLabel.text = firstReview.text
            self.updateContentSize()
        })
    }
}
