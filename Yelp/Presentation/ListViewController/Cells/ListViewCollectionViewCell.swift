//
//  ListViewCollectionViewCell.swift
//  Yelp
//
//  Created by Jeremy Fuellert on 2018-10-24.
//  Copyright © 2018 Jeremy Fuellert. All rights reserved.
//

import UIKit

class ListViewCollectionViewCell: UICollectionViewCell, Reusable {
    
    // MARK: - Constants
    private static var contentVerticalPadding: CGFloat   = 10
    private static var contentHorizontalPadding: CGFloat = 10
    private static var titleLabelTopPadding: CGFloat     = 30

    // MARK: - Properties
    fileprivate let titleLabel: UILabel = {
        
        let label                                       = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font                                      = UIFontMetrics.default.scaledFont(for: UIFont.preferredFont(forTextStyle: .headline))
        label.numberOfLines                             = 0
        label.textAlignment                             = .center

        return label
    }()
    
    fileprivate let subTitleLabel: UILabel = {
        
        let label                                       = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font                                      = UIFontMetrics.default.scaledFont(for: UIFont.preferredFont(forTextStyle: .footnote))
        label.numberOfLines                             = 0
        
        return label
    }()
    
    // MARK: - Init
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(subTitleLabel)
        
        createConstraints()
        roundCorners()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Round corners
    private func roundCorners() {
        contentView.layer.cornerRadius  = 10.0
        contentView.layer.borderWidth   = 1.0
        contentView.layer.borderColor   = UIColor.lightGray.cgColor
        contentView.layer.masksToBounds = true
    }
    
    // MARK: - Prepare for reuse
    override open func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.text    = nil
        subTitleLabel.text = nil
    }
    
    // MARK: - Updates
    func update(_ model: RestaurantModel) {
        
        titleLabel.text = model.name
        updateAddress(model)
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
    
    // MARK: - Constraints
    fileprivate func createConstraints() {
        
        NSLayoutConstraint.activate([titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: ListViewCollectionViewCell.titleLabelTopPadding),
                                     titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ListViewCollectionViewCell.contentHorizontalPadding),
                                     titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -ListViewCollectionViewCell.contentHorizontalPadding),
                                     
                                     subTitleLabel.topAnchor.constraint(greaterThanOrEqualTo: titleLabel.bottomAnchor, constant: ListViewCollectionViewCell.contentVerticalPadding),
                                     subTitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -ListViewCollectionViewCell.contentVerticalPadding),
                                     subTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ListViewCollectionViewCell.contentHorizontalPadding),
                                     subTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -ListViewCollectionViewCell.contentHorizontalPadding),
                                     ])
    }
}
