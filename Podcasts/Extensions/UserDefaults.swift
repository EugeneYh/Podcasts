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
    static let downloadEpisodeKey = "downloadPodcast"
    
    func downloadEpisode(episode: Episode) {
        do {
            var downloadedEpisodes = UserDefaults.standard.downloadedEpisodes()
            downloadedEpisodes.append(episode)
            let downloadData = try JSONEncoder().encode(downloadedEpisodes)
            UserDefaults.standard.set(downloadData, forKey: UserDefaults.downloadEpisodeKey)
        } catch let downloadErr {
            print("Failed to download episode", downloadErr)
        }
    }
    
    func downloadedEpisodes() -> [Episode] {
        guard let episodesData = UserDefaults.standard.data(forKey: UserDefaults.downloadEpisodeKey) else {return []}
        do {
            let downloadedEpisodes = try JSONDecoder().decode([Episode].self, from: episodesData)
            return downloadedEpisodes
        } catch let downloadingError {
            print("Failed to download episodes", downloadingError)
            return []
        }
    }
    
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
