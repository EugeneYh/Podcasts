//
//  FavoritesCell.swift
//  Podcasts
//
//  Created by Eugene on 22.06.2020.
//  Copyright © 2020 Eugene. All rights reserved.
//

import UIKit

class FavoriteCell: UICollectionViewCell {
    static let cellId = String.init(describing: self)
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "appicon")
        iv.clipsToBounds = true
        return iv
    }()
    
    let nameLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Podcasts name"
        lb.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        return lb
    }()
    
    let artistNameLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Artist name"
        lb.font = UIFont.systemFont(ofSize: 14)
        lb.textColor = .lightGray
        return lb
       }()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    fileprivate func setupView() {
        
        let stackView = UIStackView(arrangedSubviews: [imageView, nameLabel, artistNameLabel])
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
