//
//  PullStringBot.swift
//  BotGallery
//
//  Created by Dan Murrell on 10/21/16.
//  Copyright © 2016 Mutant Soup. All rights reserved.
//

import Foundation


typealias PullStringBots = [PullStringBot]


class PullStringBot: PullStringBotConversation {
    
    var active: Bool = false
    var name: String
    let projectID: String
    var webAPIKey: String
    var conversation: String? = nil
    
    
    init(name: String, projectID: String, webAPIKey: String) {
        self.name = name
        self.projectID = projectID
        self.webAPIKey = webAPIKey
    }
    
    
    func startConversation(completion: APICallCompletion?) {

        start(project: projectID) { [weak self](json, error) in
            
            self?.active = (error == nil)
            
            if let completion = completion {
                completion(json, error)
            }
        }
    }
}
