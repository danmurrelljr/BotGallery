//
//  AppNavigationController.swift
//  BotGallery
//
//  Created by Dan Murrell on 10/24/16.
//  Copyright © 2016 Mutant Soup. All rights reserved.
//

import UIKit


protocol AppNavigation {
    func showBotList()
    func showBot(bot: PullStringBot)
}


class AppNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let botGalleryViewController = BotGalleryViewController(appNavigationController: self)
        self.pushViewController(botGalleryViewController, animated: false)
    }
}


extension AppNavigationController: AppNavigation {
    internal func showBot(bot: PullStringBot) {
        let botViewController = BotViewController(withBot: bot)
        self.pushViewController(botViewController, animated: true)
    }

    
    internal func showBotList() {
        self.popToRootViewController(animated: true)
    }
}
