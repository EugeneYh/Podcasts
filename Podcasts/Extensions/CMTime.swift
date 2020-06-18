 //
//  CMTime.swift
//  Podcasts
//
//  Created by Eugene on 08.06.2020.
//  Copyright © 2020 Eugene. All rights reserved.
//

import AVKit

extension CMTime {
    
    func toDisplayString() -> String {
        if CMTimeGetSeconds(self).isNaN {
            return "--:--"
        }
        let totalSeconds = Int(CMTimeGetSeconds(self))
        let seconds = totalSeconds % 60
        let minutes = totalSeconds / 60
        let hours = minutes / 60
        let timeFormatString = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        return timeFormatString
    }
}
