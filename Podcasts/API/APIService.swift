//
//  APIService.swift
//  Podcasts
//
//  Created by Eugene on 27.05.2020.
//  Copyright © 2020 Eugene. All rights reserved.
//

import Foundation
import Alamofire
import FeedKit


class APIService {
    static let shared = APIService()
    
    func fetchEpisodes(from feedUrl: String, completionHandler: @escaping ([Episode]) -> ()) {
        
        guard let url = URL(string: feedUrl) else {return}
        var episodes = [Episode]()
        let parser = FeedParser(URL: url)
            parser.parseAsync(result: { (result) in
                switch result {
                case .success(let feed):
                    switch feed {
                        case let .rss(feed):
                            episodes = feed.toEpisodes()
                            completionHandler(episodes)
                        break
                    default:
                        print("Found a feed...")
                    }
                case .failure(let error):
                       print(error)
                }
            })
    }
    
    func fetchPodcasts(searchText: String, completionHandler: @escaping ([Podcast]) -> ()) {
        let url = "https://itunes.apple.com/search?"
        let parameters = ["term": searchText, "media": "podcast"]
        
        DispatchQueue.global(qos: .background).async {
            AF.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default).response { (dataResponse) in
                if let error = dataResponse.error {
                    print("Failed to connect iTunes", error)
                    return
                }
                guard let data = dataResponse.data else { return }
                do {
                    let searchResults = try JSONDecoder().decode(SearchResults.self, from: data)
                    completionHandler(searchResults.results)
                } catch let decodeError {
                    print("Failed to decode: ", decodeError)
                }
            }
        }
    }
}
