//
//  Podcasts.swift
//  Podcasts
//
//  Created by Eugene on 08.05.2020.
//  Copyright © 2020 Eugene. All rights reserved.
//

import Foundation

struct Podcast: Decodable {
    var trackName: String?
    var artistName: String?
    var artworkUrl60: String?
    var trackCount: Int?
    var feedUrl: String?
    
}
