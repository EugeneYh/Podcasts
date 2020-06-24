//
//  UserDefaults.swift
//  Podcasts
//
//  Created by Eugene on 24.06.2020.
//  Copyright © 2020 Eugene. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    static let favoritesPodcastKey = "favoritesPodcastKey"
    
    func fetchSavedPodcasts() -> [Podcast] {
        guard let savedPodcastsData = UserDefaults.standard.data(forKey: UserDefaults.favoritesPodcastKey) else {return []}
        do {
            guard let savedPodcastsList = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(savedPodcastsData) as? [Podcast] else {return []}
            return savedPodcastsList
        } catch let unarchiveError {
            print(unarchiveError)
            return []
        }
    }
}
