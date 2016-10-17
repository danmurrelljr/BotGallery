//
//  PullStringBotConversation.swift
//  BotGallery
//
//  Created by Dan Murrell on 10/17/16.
//  Copyright © 2016 Mutant Soup. All rights reserved.
//

import Foundation


typealias JSONDictionary = [String: AnyObject]
typealias Activity = String
typealias Event = (String, JSONDictionary)
typealias SetEntities = JSONDictionary
typealias GetEntities = [String]
typealias APICallCompletion = (JSONDictionary?, Error?) -> ()


protocol PullStringBotConversation {
    
    var webAPIKey: String { get }
    
    func start(project: String, timeZoneOffset: Int?, participant: String?, buildType: String?, completion: APICallCompletion?)
    func say(text: String?, uuid: String, language: String?, locale: String?, restartIfModified: Bool?, completion: APICallCompletion?)
    func change(activity: Activity, uuid: String, completion: APICallCompletion?)
    func fire(event: Event, uuid: String, completion: APICallCompletion?)
    func get(entities: GetEntities, uuid: String, completion: APICallCompletion?)
    func set(entities: SetEntities, uuid: String, completion: APICallCompletion?)
}


extension PullStringBotConversation {
    
    var baseURL: String {
        return "https://conversation.pullstring.ai/v1"
    }
    
    
    func start(project: String,
               timeZoneOffset: Int? = nil,
               participant: String? = nil,
               buildType: String? = nil,
               completion: APICallCompletion? = nil) {
        var parameters: JSONDictionary = ["project": project as AnyObject]
        
        if let timeZoneOffset = timeZoneOffset {
            parameters["time_zone_offset"] = timeZoneOffset as AnyObject
        }
        
        if let participant = participant {
            parameters["participant"] = participant as AnyObject
        }
        
        if let buildType = buildType {
            parameters["build_type"] = buildType as AnyObject
        }
        
        let session = URLSession.shared
        let request = dataRequest(withEndpoint: "conversation", method: "POST", parameters: parameters)
        let task = session.dataTask(with: request) { (data, response, error) in
            print("Response: \(response)")
            
            var json: JSONDictionary? = nil
            
            if let data = data {
                if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? JSONDictionary {
                    json = jsonObject
                }
            }
            
            if let completion = completion {
                completion(json, error)
            }
        }
        
        task.resume()
    }
    
    
    func converse(uuid: String,
                  text: String? = nil,
                  activity: String? = nil,
                  event: Event? = nil,
                  setEntities: SetEntities? = nil,
                  getEntities: GetEntities? = nil,
                  language: String? = nil,
                  locale: String? = nil,
                  restartIfModified: Bool? = nil,
                  completion: APICallCompletion? = nil) {
        var parameters: JSONDictionary = [:]
        
        if let text = text {
            parameters["text"] = text as AnyObject
        }
        
        if let activity = activity {
            parameters["activity"] = activity as AnyObject
        }
        
        if let event = event {
            parameters["event"] = event as AnyObject
        }
        
        if let setEntities = setEntities {
            parameters["set_entities"] = setEntities as AnyObject
        }
        
        if let getEntities = getEntities {
            parameters["get_entities"] = getEntities as AnyObject
        }
        
        if let language = language {
            parameters["language"] = language as AnyObject
        }
        
        if let locale = locale {
            parameters["locale"] = locale as AnyObject
        }
        
        if let restartIfModified = restartIfModified {
            parameters["restartIfModified"] = restartIfModified as AnyObject
        }
        
        let session = URLSession.shared
        let request = dataRequest(withEndpoint: "conversation/\(uuid)", method: "POST", parameters: parameters)
        let task = session.dataTask(with: request) { (data, response, error) in
            print("Response: \(response)")
            
            var json: JSONDictionary? = nil
            
            if let data = data {
                if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? JSONDictionary {
                    json = jsonObject
                }
            }
            
            if let completion = completion {
                completion(json, error)
            }
        }
        
        task.resume()
    }
    
    
    func say(text: String?, uuid: String, language: String? = nil, locale: String? = nil, restartIfModified: Bool? = nil, completion: APICallCompletion?) {
        converse(uuid: uuid, text: text, language: language, locale: locale, restartIfModified: restartIfModified, completion: completion)
    }

    
    func change(activity: Activity, uuid: String, completion: APICallCompletion?) {
        converse(uuid: uuid, activity: activity, completion: completion)
    }
    
    
    func fire(event: Event, uuid: String, completion: APICallCompletion?) {
        converse(uuid: uuid, event: event, completion: completion)
    }
    
    
    func get(entities: GetEntities, uuid: String, completion: APICallCompletion?) {
        converse(uuid: uuid, getEntities: entities, completion: completion)
    }
    
    
    func set(entities: SetEntities, uuid: String, completion: APICallCompletion?) {
        converse(uuid: uuid, setEntities: entities, completion: completion)
    }
    
    
    private func dataRequest(withEndpoint endpoint: String,
                             method: String,
                             parameters: JSONDictionary?) -> URLRequest {
        let urlString = "\(baseURL)/\(endpoint)"
        let url = URL(string: urlString)!
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        request.addValue("Bearer \(webAPIKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        if let parameters = parameters, let data = try? JSONSerialization.data(withJSONObject: parameters, options: []) {
            request.httpBody = data
        }
        
        return request
    }
}
