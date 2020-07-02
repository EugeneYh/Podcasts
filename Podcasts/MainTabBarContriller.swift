//
//  MainTabBarContriller.swift
//  Podcasts
//
//  Created by Eugene on 03.05.2020.
//  Copyright © 2020 Eugene. All rights reserved.
//

import UIKit
class MainTabBarController: UITabBarController {
    
    let playerDetailsView = PlayerDetailsView.initFromNib()
    var maximizedTopAnchorConstraint: NSLayoutConstraint!
    var minimizedTopAnchorConstraint: NSLayoutConstraint!
    var bottomAnchor: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.tintColor = .purple
        setupViewControllers()
        setupPlayerDetailsView()
    }
    
    @objc func minimizePlayerDetailsView() {
        maximizedTopAnchorConstraint.isActive = false
        bottomAnchor.constant = view.frame.height
        minimizedTopAnchorConstraint.isActive = true
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.tabBar.transform = .identity
            self.view.layoutIfNeeded()
            self.playerDetailsView.miniPlayerView.alpha = 1
            self.playerDetailsView.bigPlayerView.alpha = 0
        })
    }
    
    func maximizePlayerDetailsView(episode: Episode?, playlistEpisodes: [Episode] = [] ) {
        minimizedTopAnchorConstraint.isActive = false
        maximizedTopAnchorConstraint.isActive = true
        maximizedTopAnchorConstraint.constant = 0
        bottomAnchor.constant = 0
        
        if episode != nil {
            playerDetailsView.episode = episode
        }
        playerDetailsView.playlistEpisodes = playlistEpisodes
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
            self.tabBar.transform = CGAffineTransform(translationX: 0, y: 100)
            self.playerDetailsView.miniPlayerView.alpha = 0
            self.playerDetailsView.bigPlayerView.alpha = 1
        })
    }
    
    fileprivate func setupPlayerDetailsView() {
        playerDetailsView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(playerDetailsView, belowSubview: tabBar)
        maximizedTopAnchorConstraint = playerDetailsView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height)
        bottomAnchor =  playerDetailsView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: view.frame.height)
        bottomAnchor.isActive = true
        maximizedTopAnchorConstraint.isActive = true
        minimizedTopAnchorConstraint = playerDetailsView.topAnchor.constraint(equalTo: tabBar.topAnchor, constant: -64)
        playerDetailsView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        playerDetailsView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    fileprivate func setupViewControllers() {
        let layout = UICollectionViewFlowLayout()
        viewControllers = [
            generateNavController(for: PodcastsSearchController(), title: "Search", image: #imageLiteral(resourceName: "search")),
            generateNavController(for: FavoritesController(collectionViewLayout: layout), title: "Favorites", image: #imageLiteral(resourceName: "favorites")),
            generateNavController(for: DownloadsController(), title: "Downloads", image: #imageLiteral(resourceName: "downloads"))
        ]
    }
    
    fileprivate func generateNavController(for rootViewController: UIViewController, title: String, image: UIImage) -> UIViewController {
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.tabBarItem.title = title
        navController.tabBarItem.image = image
        rootViewController.navigationItem.title = title
        navController.navigationBar.prefersLargeTitles = true
        return navController
    }
}
