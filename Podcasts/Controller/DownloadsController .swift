//
//  Download.swift
//  Podcasts
//
//  Created by Eugene on 25.06.2020.
//  Copyright © 2020 Eugene. All rights reserved.
//

import UIKit

class DownloadsController: UIViewController {
    
    let tableView = UITableView(frame: .zero, style: .plain)
    let cellId = "cellId"
    
    var downloadedEpisodes = UserDefaults.standard.downloadedEpisodes()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        downloadedEpisodes = UserDefaults.standard.downloadedEpisodes()
        tableView.reloadData()
    }
    
    fileprivate func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleDownloadProgress), name: .downloadProgress, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hanldeDownloadComplete), name: .downloadComplete, object: nil)
    }
    
    
    @objc fileprivate func hanldeDownloadComplete(notification: Notification) {
        guard let episodeDownloadComplete = notification.object as? APIService.EpisodeDownloadCompleteTuple else {return}
        guard let row = downloadedEpisodes.firstIndex(where: {$0.title == episodeDownloadComplete.episodeTitle}) else {return}
        self.downloadedEpisodes[row].fileUrl = episodeDownloadComplete.fileUrl
        self.tableView.reloadData()
        
    }
    
    @objc fileprivate func handleDownloadProgress(notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: Any] else {return}
        
        guard let progress = userInfo["progress"] as? Double else {return}
        guard let title = userInfo["title"] as? String else {return}
        
        guard let row = downloadedEpisodes.firstIndex(where: {$0.title == title}) else {return}
        
        guard let cell = self.tableView.cellForRow(at: IndexPath(row: row, section: 0)) as? EpisodeCell else {return}
        cell.progressLabel.isHidden = false
        cell.progressLabel.text = "\(Int(progress * 100))%"
        if progress == 1 {
            cell.progressLabel.isHidden = true
        }
        
    }
    
    
    fileprivate func setupTableView() {
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.backgroundColor = .white
        
        let nib = UINib(nibName: "EpisodeCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellId)
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
}

extension DownloadsController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 136
    }
}

extension DownloadsController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return downloadedEpisodes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! EpisodeCell
        cell.episode = downloadedEpisodes[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let episode = downloadedEpisodes[indexPath.row]
        
        if episode.fileUrl != nil {
            UIApplication.shared.mainTabBarController()?.maximizePlayerDetailsView(episode: episode, playlistEpisodes: downloadedEpisodes )
        } else {
            
            let allertController = UIAlertController(title: "File URL not found", message: "Cannot find llcal file, play using internet connection?", preferredStyle: .actionSheet)
            
            allertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (_) in
                UIApplication.shared.mainTabBarController()?.maximizePlayerDetailsView(episode: episode, playlistEpisodes: self.downloadedEpisodes )
            }))
            
            allertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            present(allertController, animated: true)
        }
        
    }

    // perform delete downloaded episode:
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (_, _, success) in
            print("Delete item")
            self.downloadedEpisodes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            UserDefaults.standard.deleteDownloadedEpisode(episodes: self.downloadedEpisodes)
            success(true)
        }
        let rightSwipeToDelete = UISwipeActionsConfiguration(actions: [deleteAction])
        return rightSwipeToDelete
    }
    
}
