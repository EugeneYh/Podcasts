//
//  UIApplication.swift
//  Podcasts
//
//  Created by Eugene on 25.06.2020.
//  Copyright © 2020 Eugene. All rights reserved.
//

import UIKit

extension UIApplication {
    static func mainTabBarController() -> MainTabBarController? {
        let mainTabBarController = shared.windows.filter({$0.isKeyWindow}).first?.rootViewController as? MainTabBarController
        return mainTabBarController
    }
}
