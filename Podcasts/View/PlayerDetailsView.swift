//
//  PlayerDetailsView.swift
//  Podcasts
//
//  Created by Eugene on 03.06.2020.
//  Copyright © 2020 Eugene. All rights reserved.
//

import UIKit
import AVKit
import MediaPlayer

class PlayerDetailsView: UIView {
    
    var episode: Episode? {
        didSet {
            titleLabel.text = episode?.title
            miniPlayerTitleLable.text = episode?.title
            authorLabel.text = episode?.author
            setupAudioSession()
            playEpisode()
            setupNowPlayingInfo()
            guard let url = URL(string: episode?.imageUrl ?? "") else {return}
            episodeImageView.sd_setImage(with: url)
            miniPlayerImageView.sd_setImage(with: url) { (image, _, _, _) in
                guard let image = image else {return}
                var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo
                nowPlayingInfo?[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size, requestHandler: { (_) -> UIImage in
                    return image
                })
                MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
            }
        }
    }
    
    let player: AVPlayer = {
        let avPlayer = AVPlayer()
        avPlayer.automaticallyWaitsToMinimizeStalling = false
        return avPlayer
    }()
    
    fileprivate let shrankenTransform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    lazy var mainTabBarController = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController as? MainTabBarController
    var panGesture: UIPanGestureRecognizer?
    var playlistEpisodes = [Episode]()
    
    fileprivate func setupNowPlayingInfo() {
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = episode?.title ?? ""
        nowPlayingInfo[MPMediaItemPropertyArtist] = episode?.author ?? ""
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    //MARK: - labels and actions
    
    @IBOutlet weak var miniPlayerView: UIView!
    @IBOutlet weak var bigPlayerView: UIStackView!
    @IBOutlet weak var miniPlayerPlayPauseButtonLabel: UIButton! {
        didSet {
            miniPlayerPlayPauseButtonLabel.imageEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
        }
    }
    @IBOutlet weak var miniPlayerImageView: UIImageView!
    @IBOutlet weak var miniPlayerTitleLable: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var currentTImeSlider: UISlider!
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.numberOfLines = 2
        }
    }
    @IBOutlet weak var playePauseButtonLabel: UIButton!
    @IBOutlet weak var episodeImageView: UIImageView! {
        didSet {
            episodeImageView.clipsToBounds = true
            episodeImageView.layer.cornerRadius = 8
            episodeImageView.transform = shrankenTransform
        }
    }
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var VolumeChangeSlider: UISlider!
    
    // MARK: - AwakeFromNib
    override func awakeFromNib() {
        super.awakeFromNib()
        setupInterruptionObserver()
        setupRemoteControl()
        setupGestureRecognizer()
        observePlayerCurrentTime()
        observeBoundaryTime()
    }
    
    fileprivate func setupInterruptionObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption), name: .AVCaptureSessionWasInterrupted, object: nil)
    }
    
    @objc fileprivate func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo else {return}
        guard let type = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt else {return}
        
        if type == AVAudioSession.InterruptionType.began.rawValue {
            playePauseButtonLabel.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            miniPlayerPlayPauseButtonLabel.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        } else {
            guard let options = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else {return}
            if options == AVAudioSession.InterruptionOptions.shouldResume.rawValue {
                player.play()
                playePauseButtonLabel.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
                miniPlayerPlayPauseButtonLabel.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            }
        }
    }
    
    fileprivate func setupRemoteControl() {
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.player.play()
            self.playePauseButtonLabel.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            self.miniPlayerPlayPauseButtonLabel.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            self.setupLockScreenElapsedTime(playbackRate: 1)
            return .success
        }
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.player.pause()
            self.playePauseButtonLabel.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            self.miniPlayerPlayPauseButtonLabel.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            self.setupLockScreenElapsedTime(playbackRate: 0)
            return .success
        }
        commandCenter.togglePlayPauseCommand.isEnabled = true
        commandCenter.togglePlayPauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.playPauseAction()
            return .success
        }
        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.nextTrackCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.handleNextTrack()
            return .success
        }
        commandCenter.previousTrackCommand.isEnabled = true
        commandCenter.previousTrackCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.handlePreviousTrack()
            return .success
        }
    }
    
    fileprivate func handlePreviousTrack() {
        let previousEpisode: Episode
        if playlistEpisodes.count == 0 {
            return
        }
        let currentIndex = playlistEpisodes.firstIndex { (ep) -> Bool in
            return self.episode?.author == ep.author && episode?.title == ep.title
        }
        guard let index = currentIndex else { return }
        if index == 0 {
            previousEpisode = playlistEpisodes[0]
        } else {
            previousEpisode = playlistEpisodes[index - 1]
        }
        self.episode = previousEpisode
    }
    
    fileprivate func handleNextTrack() {
        let nextEpisode: Episode
        if playlistEpisodes.count == 0 {
            return
        }
        let currentIndex = playlistEpisodes.lastIndex { (ep) -> Bool in
            return self.episode?.title == ep.title && self.episode?.author == ep.author
        }
        guard let index = currentIndex else {return}
        if index == self.playlistEpisodes.count - 1 {
            nextEpisode = playlistEpisodes[0]
        } else {
            nextEpisode = playlistEpisodes[index + 1]
        }
        self.episode = nextEpisode
    }
    
    fileprivate func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let sessionError {
            print("Failed to activate session: ", sessionError)
        }
        //AVAudioSession.sharedInstance().setActive(true, options: .)
    }
    
    //MARK: - IBActions
    
    @IBAction func miniPlayerPlayPauseButton(_ sender: Any) {
        playPauseAction()
    }
    
    @IBAction func miniPlayerFastForwardButton(_ sender: Any) {
        seekToCurrentTime(delta: 15)
    }
    
    @IBAction func handleCurrentTimeSliderChange(_ sender: Any) {
        let percentage = currentTImeSlider.value
        guard let duration = player.currentItem?.duration else {return}
        let durationInSeconds = CMTimeGetSeconds(duration)
        let seekTimeInSeconds = Float64(percentage) * durationInSeconds
        let seekTime = CMTimeMakeWithSeconds(seekTimeInSeconds, preferredTimescale: 1)
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = seekTimeInSeconds
        player.seek(to: seekTime)
    }
    
    @IBAction func handleRewind(_ sender: Any) {
        seekToCurrentTime(delta: -15)
    }
    
    @IBAction func handleFastForward(_ sender: Any) {
        seekToCurrentTime(delta: 15)
    }
    
    @IBAction func handleVolumeChange(_ sender:  UISlider) {
        player.volume = sender.value
    }
    
    @IBAction func handleDissmiss(_ sender: Any) {
        mainTabBarController?.minimizePlayerDetailsView()
    }
    
    @IBAction func playPauseButton(_ sender: Any) {
        playPauseAction()
    }
    
    //MARK: - Custom functions
    
    static func initFromNib() -> PlayerDetailsView {
          return Bundle.main.loadNibNamed("PlayerDetailsView", owner: self, options: nil)?.first as! PlayerDetailsView
    }
    
    fileprivate func setupGestureRecognizer() {
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapMaximize)))
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        if let panGesture = panGesture {
            miniPlayerView.addGestureRecognizer(panGesture)
        }
        bigPlayerView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePanGestureDismis)))
    }
    
    @objc fileprivate func handlePanGestureDismis(gesture:  UIPanGestureRecognizer) {
        let translationY = gesture.translation(in: superview).y
        let velocityY = gesture.velocity(in: superview).y
        if gesture.state == .changed {
            bigPlayerView.transform = CGAffineTransform(translationX: 0, y: translationY)
        } else if gesture.state == .ended {
            if translationY > 100 || velocityY > 300 {
                mainTabBarController?.minimizePlayerDetailsView()
            }
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: .curveEaseOut, animations: {
                self.bigPlayerView.transform = .identity
            })
        }
    }
    
    fileprivate func observeBoundaryTime() {
        let time = CMTimeMake(value: 1, timescale: 3)
        let times = [NSValue(time: time)]
        player.addBoundaryTimeObserver(forTimes: times, queue: .main) {
            [weak self] in
            self?.enlargeEpisodeImageView()
            self?.setupLockScreenDuration()
        }
    }
    
    fileprivate func setupLockScreenDuration() {
        var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo
        guard let duration = player.currentItem?.duration else {return}
        let durationInSeconds = CMTimeGetSeconds(duration)
        nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] = durationInSeconds
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    fileprivate func playPauseAction() {
        if player.timeControlStatus == .paused {
            player.play()
            playePauseButtonLabel.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            miniPlayerPlayPauseButtonLabel.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            enlargeEpisodeImageView()
            setupLockScreenElapsedTime(playbackRate: 1)
        } else {
            player.pause()
            playePauseButtonLabel.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            miniPlayerPlayPauseButtonLabel.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            shrinkEpisodeImageView(for: episodeImageView)
            shrinkEpisodeImageView(for: miniPlayerPlayPauseButtonLabel.imageView!)
            setupLockScreenElapsedTime(playbackRate: 0)
        }
    }
    
    fileprivate func setupLockScreenElapsedTime(playbackRate: Float) {
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(player.currentTime())
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = playbackRate
    }
    
    fileprivate func seekToCurrentTime(delta: Int64) {
          let rewindSeconds = CMTimeMake(value: delta, timescale: 1)
          let seekTime = CMTimeAdd(player.currentTime(), rewindSeconds)
          player.seek(to: seekTime)
    }
    
    fileprivate func observePlayerCurrentTime() {
        let interval = CMTimeMake(value: 1, timescale: 2)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] (time) in
            self?.currentTimeLabel.text = time.toDisplayString()
            let durationTime = self?.player.currentItem?.duration
            self?.durationLabel.text = durationTime?.toDisplayString()
            self?.updateCurrentTimeSlider()
        }
    }
    
    fileprivate func setupLockScreenPlayerTime() {
        var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo
        guard let duration = player.currentItem?.duration else {return}
        let durationInSeconds = CMTimeGetSeconds(duration)
        let elapsedTime = CMTimeGetSeconds(player.currentTime())
        nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] = durationInSeconds
        nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsedTime
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        
    }
    
    fileprivate func updateCurrentTimeSlider() {
        let currentTimeLabel = CMTimeGetSeconds(player.currentTime())
        let durationSeconds = CMTimeGetSeconds(player.currentItem?.duration ?? CMTimeMake(value: 1, timescale: 1))
        let percentage = currentTimeLabel / durationSeconds
        self.currentTImeSlider.value = Float(percentage)
    }
    
    fileprivate func playEpisode() {
        guard let stringUrl = episode?.streamUrl else {return}
        guard let url = URL(string: stringUrl) else {return}
        let playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
        player.play()
    }
    
    fileprivate func enlargeEpisodeImageView() {
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.episodeImageView.transform = .identity
        })
    }
    
    fileprivate func shrinkEpisodeImageView(for image: UIImageView) {
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            image.transform = self.shrankenTransform
        })
    }
}
