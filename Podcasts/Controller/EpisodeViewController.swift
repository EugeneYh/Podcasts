//
//   EpisodesTableViewController.swift
//  Podcasts
//
//  Created by Eugene on 30.05.2020.
//  Copyright © 2020 Eugene. All rights reserved.
//

import UIKit
import FeedKit

class EpisodeViewController: UIViewController {
    
    let tableView = UITableView(frame: .zero, style: .plain)
    let cellId = "cellId"
    var episodes = [Episode]()
    var podcast: Podcast? {
        didSet {
            navigationItem.title = podcast?.trackName
            fetchEpisodes()
        }
    }
    
    fileprivate func fetchEpisodes() {
        guard let urlString = podcast?.feedUrl else {return}
        APIService.shared.fetchEpisodes(from: urlString) { (episodes) in
            self.episodes = episodes
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupTableView()
        setupView()
        setupNavigationBarButtons()
    }
    
    fileprivate func setupNavigationBarButtons() {
        let savedPodcasts = UserDefaults.standard.fetchSavedPodcasts()
        let hasFavorited = savedPodcasts.contains { (p) -> Bool in
            if p.artistName == self.podcast?.artistName && p.trackName == self.podcast?.trackName {
                return true
            } else {
                return false
            }
        }
        if hasFavorited {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "heart").withTintColor(.purple, renderingMode: .alwaysOriginal), style: .plain, target: nil, action: nil)
        } else {
            navigationItem.rightBarButtonItems = [
                UIBarButtonItem(title: "Favorites", style: .plain, target: self, action: #selector(handleSaveFavorites)),
            ]
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .normal, title: "Dowload") { (_, _, success) in
            print("Download podcast")
            let episode = self.episodes[indexPath.row]
            UserDefaults.standard.downloadEpisode(episode: episode)
            APIService.shared.downloadEpisode(episode: episode)
            success(true)
        }
        return UISwipeActionsConfiguration.init(actions: [action])
    }
    
    @objc fileprivate func handleSaveFavorites() {
        print("Add to Favorites")
        guard let podcast = self.podcast else {return}
        var podcastsList = [Podcast]()
        
        // Fetsh already saved podcasts
        podcastsList = UserDefaults.standard.fetchSavedPodcasts()
        
        // Save podcast to Favorites
        do {
            podcastsList.append(podcast)
            let data = try NSKeyedArchiver.archivedData(withRootObject: podcastsList, requiringSecureCoding: false)
            UserDefaults.standard.set(data, forKey: UserDefaults.favoritesPodcastKey)
            showBadgeHighlight()
        } catch let encodingError {
            print("Failed to encode data, ", encodingError)
        } 
    }
    
    fileprivate func showBadgeHighlight() {
        let tabBarController = UIApplication.shared.windows.filter({$0.isKeyWindow}).first
        guard let mainTabBarController = tabBarController?.rootViewController as? MainTabBarController else {return}
        mainTabBarController.viewControllers?[1].tabBarItem.badgeValue = "New"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "heart").withTintColor(.purple, renderingMode: .alwaysOriginal), style: .plain, target: nil, action: nil)

    }
    
    @objc fileprivate func handleFetchSavedFavorites() {
        print("Fetch Favorites")
        guard let data = UserDefaults.standard.data(forKey: UserDefaults.favoritesPodcastKey) else {return}
        do {
            let podcastsList = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [Podcast]
            podcastsList?.forEach({ (p) in
                print(p.artistName ?? "")
            })
        } catch let decodingError {
            print("Failed to decode data, ", decodingError)
        }
    }
    
    fileprivate func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: "EpisodeCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellId)
        tableView.tableFooterView = UIView()
    }
    
    fileprivate func setupView() {
        view.addSubview(tableView)
        tableView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
    }
}

extension EpisodeViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 132
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .darkGray
        episodes.count == 0 ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
        return activityIndicator
    }
}

extension EpisodeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let episode = self.episodes[indexPath.row]
        let mainTabBarController = UIApplication.shared.windows.filter{$0.isKeyWindow}.first?.rootViewController as! MainTabBarController
        mainTabBarController.maximizePlayerDetailsView(episode: episode, playlistEpisodes: self.episodes)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! EpisodeCell
        let episode = episodes[indexPath.row]
        cell.episode = episode
        return cell
    }
}



