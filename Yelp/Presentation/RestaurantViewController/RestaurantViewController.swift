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
    
    // MARK: - Properties
    fileprivate let scrollView: UIScrollView = {
        
        let scrollView                                       = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        return scrollView
    }()
    fileprivate let imageView: UIImageView = {
        
        let imageView                                       = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    fileprivate let titleLabel: UILabel = {
        
        let label                                          = UILabel()
        label.translatesAutoresizingMaskIntoConstraints    = false
        label.numberOfLines                                = 0
        
        return label
    }()
    
    fileprivate let subTitleLabel: UILabel = {
        
        let label                                          = UILabel()
        label.translatesAutoresizingMaskIntoConstraints    = false
        label.numberOfLines                                = 0
        
        return label
    }()
    
    fileprivate let mapView: MKMapView = {
        
        let mapView                                       = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        return mapView
    }()
    
    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(titleLabel)
        scrollView.addSubview(subTitleLabel)
        scrollView.addSubview(mapView)
        createConstraints()
    }
    
    // MARK: - Updates
    func update(_ restaurantModel: RestaurantModel) {
        
        if let imageURL = restaurantModel.imageUrlString, let url = URL(string: imageURL) {
            imageView.sd_setImage(with: url, completed: nil)
        }
        
        if let coordinates = restaurantModel.coordinates, let latitude = coordinates.latitude, let longitude = coordinates.longitude {
            mapView.setCenter(CLLocationCoordinate2D(latitude: latitude, longitude: longitude), animated: false)
        }
        
        titleLabel.text = restaurantModel.name
        updateAddress(restaurantModel)
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
        
        subTitleLabel.text = address
    }
    
    // MARK: - Layout subviews
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateContentSize()
    }
    
    fileprivate func updateContentSize() {
        scrollView.contentSize = CGSize(width: view.frame.width, height: mapView.frame.maxY)
    }
    
    
    // MARK: - Constraints
    fileprivate func createConstraints() {
        
        NSLayoutConstraint.activate([scrollView.topAnchor.constraint(equalTo: view.topAnchor),
                                    scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                                    scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                                    scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                                    
                                    imageView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: RestaurantViewController.contentVerticalPadding),
                                    imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: RestaurantViewController.contentHorizontalPadding),
                                    imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -RestaurantViewController.contentHorizontalPadding),
                                    imageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.3),
                                    
                                    titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: RestaurantViewController.contentVerticalPadding),
                                    titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: RestaurantViewController.contentHorizontalPadding),
                                    titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -RestaurantViewController.contentHorizontalPadding),
                                    
                                    subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: RestaurantViewController.contentVerticalPadding),
                                    subTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: RestaurantViewController.contentHorizontalPadding),
                                    subTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -RestaurantViewController.contentHorizontalPadding),
                                    
                                    mapView.topAnchor.constraint(equalTo: subTitleLabel.bottomAnchor, constant: RestaurantViewController.contentVerticalPadding),
                                    mapView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.3),
                                    mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: RestaurantViewController.contentHorizontalPadding),
                                    mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -RestaurantViewController.contentHorizontalPadding),
                                     ])
    }
}
