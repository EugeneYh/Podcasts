//
//  PlayerDetailsView+Gestures.swift
//  Podcasts
//
//  Created by Eugene on 17.06.2020.
//  Copyright © 2020 Eugene. All rights reserved.
//

import UIKit

extension PlayerDetailsView {
    
    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
        let translationY = gesture.translation(in: superview).y
        let velocity = gesture.velocity(in: superview)
        
        if gesture.state == .changed {
            self.transform = CGAffineTransform(translationX: 0, y: translationY)
            miniPlayerView.alpha = 1 + translationY / 200
            bigPlayerView.alpha = -translationY / 200
        } else if gesture.state == .ended {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: .curveEaseOut, animations: {
                self.transform = .identity
                if translationY < -300 || velocity.y < -500 {
                    self.mainTabBarController?.maximizePlayerDetailsView(episode: nil)
                } else {
                    self.miniPlayerView.alpha = 1
                    self.bigPlayerView.alpha = 0
                }
                
            })
        }
    }
    
    @objc func handleTapMaximize() {
        mainTabBarController?.maximizePlayerDetailsView(episode: nil)
    }
}
