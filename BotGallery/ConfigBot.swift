//
//  ConfigBot.swift
//  BotGallery
//
//  Created by Dan Murrell on 10/17/16.
//  Copyright © 2016 Mutant Soup. All rights reserved.
//

import Foundation


class ConfigBot: PullStringBot {
    
    init(webAPIKey: String, projectID: String) {
        let name = "ConfigBot"

        super.init(name: name, projectID: projectID, webAPIKey: webAPIKey)
    }
}
