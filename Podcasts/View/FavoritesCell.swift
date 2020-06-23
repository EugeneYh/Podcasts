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
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .yellow
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
