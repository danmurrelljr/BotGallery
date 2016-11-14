# BotGallery
A simple iOS app that displays a list of PullString bots, connected through their Web API.

With its [Web API](http://docs.pullstring.com/docs/api), [PullString](http://pullstring.com) has made its chat bots available outside of the Slack and Facebook Messenger system.

You can roll your own chat bot to add to a web page, mobile app, and even an IoT device.

BotGallery is a demonstration of adding a PullString bot to your mobile app, using a protocol to wrap the Web API calls.

```
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
```

A default implementation of the protocol is provided, as well as a concrete PullStringBot object implementing it.

```
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
```

In a twist, a simple PullStringBot subclass is used to deliver the BotGallery configuration. BotGallery connects to a special ConfigBot I have setup using the PullString Web API, and asks it what bots it knows about.

```
class ConfigBot: PullStringBot {
    
    init(webAPIKey: String, projectID: String) {
        let name = "ConfigBot"

        super.init(name: name, projectID: projectID, webAPIKey: webAPIKey)
    }
}
```

From BotGalleryViewController.swift:
```
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
```

My ConfigBot built using [PullString Author](https://www.pullstring.com/features#panel-pullstring-author) returns a simple list of bots I've built, plus their Project ID. 

```
BankingBot,B6E13DCD-DE43-42E1-AFB5-BDC8417D65BB
CustomerServiceBot,39A8AA06-707B-4C86-9C02-95849BF65222
WidgetBot,E4735E7E-CA5F-4485-9C53-47511C3B86DC
```

And the Bot Gallery app will use this information to display the list of bots.

To configure this ConfigBot, you will need to have a rule, {bots} that returns a few chained replies describing the bots. (I'd planned to add additional data in the responses, but Name and Project ID were enough to get up and running.)

And in BotGalleryViewController.swift, you'd want to replace these values with your Web API Key and the ProjectID from the PullString Bots Dashboard in your account.

```
    let webAPIKey = "WEB_API_KEY"
    let configBotProjectID = "CONFIG_BOT_PROJECT_ID"
```

And that's it!

## Using PullStringBot as a framework

Of course you may just want to integrate a PullStringBot into your own app, without the rest of this project.

For that, you need:
- [PullStringBot.swift](https://github.com/danmurrelljr/BotGallery/blob/master/BotGallery/PullStringBot.swift)
- [PullStringBotConversation.swift](https://github.com/danmurrelljr/BotGallery/blob/master/BotGallery/PullStringBotConversation.swift)

Add these files to your project, instantiate a PullStringBot (or a subclass, as I did with [ConfigBot.swift](https://github.com/danmurrelljr/BotGallery/blob/master/BotGallery/ConfigBot.swift)) and you're good to go.

Bot Gallery is written for Swift 3. 
