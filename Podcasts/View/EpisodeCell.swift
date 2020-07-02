//
//  EpisodeCell.swift
//  Podcasts
//
//  Created by Eugene on 01.06.2020.
//  Copyright © 2020 Eugene. All rights reserved.
//

import UIKit
import SDWebImage

class EpisodeCell: UITableViewCell {
    
    var episode: Episode? {
        didSet {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy"
            dateLabel.text = dateFormatter.string(from: episode?.pubDate ?? Date())
            titleLabel.text = episode?.title
            descriptionLabel.text = episode?.description
            guard let imageUrl = episode?.imageUrl  else { return }
            guard let url = URL(string: imageUrl) else {return}
            episodeImageView.sd_setImage(with: url, completed: nil)
        }
    }
    
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var episodeImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel! {
        didSet {
            descriptionLabel.numberOfLines = 2
        }
    }
    
    
    
}
