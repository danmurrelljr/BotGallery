//
//  BotGalleryViewController.swift
//  BotGallery
//
//  Created by Dan Murrell on 10/16/16.
//  Copyright © 2016 Mutant Soup. All rights reserved.
//

import UIKit

class BotGalleryViewController: UIViewController {
    
    let appNavigationController: AppNavigationController
    let tableView = UITableView()
    let configBot: ConfigBot!
    var botList: PullStringBots = []
    let webAPIKey = "WEB_API_KEY"
    let configBotProjectID = "CONFIG_BOT_PROJECT_ID"

    
    init(appNavigationController: AppNavigationController) {
        self.appNavigationController = appNavigationController
        self.configBot = ConfigBot(webAPIKey: webAPIKey, projectID: configBotProjectID)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupViewHierarchy()
        
        askConfigBotForListOfBots()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


extension BotGalleryViewController {
    
    func setupView() {
        
        view.backgroundColor = UIColor.white
        title = NSLocalizedString("Bot Gallery", comment: "")
    }
    
    
    func setupViewHierarchy() {
        setupTableView()
    }
    
    
    func setupTableView() {
        view.addSubview(tableView)
        tableView.align(toView: view)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        
        registerTableViewCells()
        
    }
    
    
    func refreshTableView() {
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    
    private func registerTableViewCells() {
        tableView.registerCell(UITableViewCell.self)
    }
}


extension BotGalleryViewController {
    func askConfigBotForListOfBots() {
        
        configBot.startConversation { [weak self](response, error) in
            
            print("Response: \(response)")
            
            guard let strongSelf = self else { return }
            
            if let uuid = response?["conversation"] as? String {
                strongSelf.configBot.say(text: "bots", uuid: uuid) { (response, error) in
                    
                    print("Response: \(response)")
                    
                    if let response = response {
                        strongSelf.processBots(json: response)
                        strongSelf.refreshTableView()
                    }
                }
            }
            
            print("ConfigBot is active? \(strongSelf.configBot.active)")
        }
    }
    
    
    func processBots(json: JSONDictionary) {
        
        if let outputs = json["outputs"] as? [JSONDictionary] {
            
            botList = []
            
            for line in outputs {
                
                if let text = line["text"] {
                    let components = text.components(separatedBy: ",")
                    if components.count >= 2 {
                        
                        let name = components[0].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                        let projectID = components[1].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                        let bot = PullStringBot(name: name, projectID: projectID, webAPIKey: webAPIKey)
                        botList.append(bot)
                    }
                }
            }
        }
    }
}


extension BotGalleryViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return botList.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.identifier, for: indexPath)
        cell.textLabel?.text = botList[indexPath.row].name
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let bot = botList[indexPath.row]
        appNavigationController.showBot(bot: bot)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
