//
//  ViewController.swift
//  Podcasts
//
//  Created by Eugene on 03.05.2020.
//  Copyright © 2020 Eugene. All rights reserved.
//

import UIKit
import Alamofire

class PodcastsSearchController: UIViewController {
    
    let cellId = "cellId"
    var timer: Timer?
    var podcasts = [Podcast]()
    let tableView = UITableView(frame: .zero, style: .plain)
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupTableView()
        setupSearchBar()
        setupView()
        
        searchBar(searchController.searchBar, textDidChange: "Voong")
    }
    
    fileprivate func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        let cellNib = UINib(nibName: "PodcastCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: cellId)
    }
    
    fileprivate func setupSearchBar() {
        self.definesPresentationContext = true
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
    }
    
    fileprivate func setupView() {
        view.addSubview(tableView)
        tableView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
    }
}

extension PodcastsSearchController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.podcasts.count > 0 ? 0 : 250
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 125
    }
}

extension PodcastsSearchController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let episedeController = EpisodeViewController()
        episedeController.modalPresentationStyle = .fullScreen
        let podcast = podcasts[indexPath.row]
        episedeController.podcast = podcast
        navigationController?.pushViewController(episedeController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return podcasts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! PodcastCell
        cell.podcast = podcasts[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "Please enter a search term"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .purple
        return label
    }
}


extension PodcastsSearchController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { (false) in
            APIService.shared.fetchPodcasts(searchText: searchText) {[weak self] (podcasts) in
                self?.podcasts = podcasts
                self?.tableView.reloadData()
            }
        })
    }
}
