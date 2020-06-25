//
//  FavoritesController.swift
//  Podcasts
//
//  Created by Eugene on 22.06.2020.
//  Copyright © 2020 Eugene. All rights reserved.
//

import UIKit

class FavoritesController: UICollectionViewController {
    var podcasts = UserDefaults.standard.fetchSavedPodcasts()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        podcasts = UserDefaults.standard.fetchSavedPodcasts()
        let tabBarController = UIApplication.shared.windows.filter({$0.isKeyWindow}).first
        guard let mainTabBarController = tabBarController?.rootViewController as? MainTabBarController else {return}
        mainTabBarController.viewControllers?[1].tabBarItem.badgeValue = nil
        collectionView.reloadData()
    }
    
    fileprivate func setupCollectionView() {
        collectionView.backgroundColor = .white
        collectionView.register(FavoriteCell.self, forCellWithReuseIdentifier: FavoriteCell.cellId)
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGestureRecognizer))
        collectionView.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    @objc fileprivate func handleLongPressGestureRecognizer(gesture: UILongPressGestureRecognizer) {
        let coordinates = gesture.location(in: collectionView.self)
        guard let selectedCellIndex = collectionView.indexPathForItem(at: coordinates) else {return}
        
        let alertController = UIAlertController(title: "Remove Podcast?", message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (_) in
            self.podcasts.remove(at: selectedCellIndex.item)
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: self.podcasts, requiringSecureCoding: false)
                UserDefaults.standard.set(data, forKey: UserDefaults.favoritesPodcastKey)
            } catch let error {
                print(error)
            }
            self.collectionView.deleteItems(at: [selectedCellIndex])
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alertController, animated: true)
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let episodesController = EpisodeViewController()
        episodesController.podcast = podcasts[indexPath.item]
        navigationController?.pushViewController(episodesController, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return podcasts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FavoriteCell.cellId, for: indexPath) as! FavoriteCell
        cell.podcast = podcasts[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 16, left: 16, bottom: 16, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
}

extension FavoritesController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 3*16) / 2
        return .init(width: width, height: width + 48)
    }
}
