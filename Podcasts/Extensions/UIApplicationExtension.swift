//
//  UIApplicationExtension.swift
//  Podcasts
//
//  Created by Eugene on 30.06.2020.
//  Copyright © 2020 Eugene. All rights reserved.
//

import UIKit

extension UIApplication {
    func mainTabBarController() -> MainTabBarController? {
        let mainTabBarController = UIApplication.shared.windows.filter({$0.isKeyWindow}).first?.rootViewController as? MainTabBarController
        return mainTabBarController
    }
}
