//
//  SearchResultModel.swift
//  Podcasts
//
//  Created by Eugene on 28.05.2020.
//  Copyright © 2020 Eugene. All rights reserved.
//

import Foundation

struct SearchResults: Decodable {
    let resultCount: Int
    let results: [Podcast]
}
