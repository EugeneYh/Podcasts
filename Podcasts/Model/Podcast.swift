//
//  Podcasts.swift
//  Podcasts
//
//  Created by Eugene on 08.05.2020.
//  Copyright © 2020 Eugene. All rights reserved.
//

import Foundation

class Podcast: NSObject, Decodable, NSCoding {
    
    func encode(with coder: NSCoder) {
        print("Trying to transform podcast into data")
        coder.encode(trackName ?? "", forKey: "trackNameKey")
        coder.encode(artistName ?? "", forKey: "artistNameKey")
        coder.encode(artworkUrl60 ?? "", forKey: "artworkUrl60Key")
    }
    
    required init?(coder: NSCoder) {
        print("Tryiing to fetch data into podcast")
        self.trackName = coder.decodeObject(forKey: "trackNameKey") as? String ?? ""
        self.artistName = coder.decodeObject(forKey: "artistNameKey") as? String ?? ""
        self.artworkUrl60 = coder.decodeObject(forKey: "artworkUrl60Key") as? String ?? ""
    }
    
    var trackName: String?
    var artistName: String?
    var artworkUrl60: String?
    var trackCount: Int?
    var feedUrl: String?
    
}
