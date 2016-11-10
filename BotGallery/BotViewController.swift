//
//  BotViewController.swift
//  BotGallery
//
//  Created by Dan Murrell on 10/24/16.
//  Copyright © 2016 Mutant Soup. All rights reserved.
//

import Foundation
import UIKit


typealias ImageCompletion = (UIImage?) -> ()


class BotViewController: UIViewController, KeyboardObservation {
    
    let bot: PullStringBot
    let scrollView = UIScrollView()
    let stackView = UIStackView()
    let separator = UIView()
    let textInputView = UIView()
    let textField = TextField()
    let sendButton = UIButton()
    let botColor = UIColor(red:0.90, green:0.90, blue:0.92, alpha:1.00)
    let botTextColor = UIColor.black
    let humanColor = UIColor(red:0.08, green:0.49, blue:0.98, alpha:1.00)
    let humanTextColor = UIColor.white
    
    var delayedResponseTimer: Timer? = nil
    var lastChatBubble: ChatBubble? = nil
    var textInputViewBottomConstraint: NSLayoutConstraint? = nil
    
    
    init(withBot bot: PullStringBot) {
        
        self.bot = bot
        
        super.init(nibName: nil, bundle: nil)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupViewHierarchy()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let textInputViewBottomConstraint = textInputViewBottomConstraint {
            addKeyboardFrameWillChangeObserver(forView: textInputView, withBottomConstraint: textInputViewBottomConstraint)
        }
        
        resumeIfNecessary(bot: bot)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        removeKeyboardFrameWillChangeObserver()
    }
    
    
    private func resumeIfNecessary(bot: PullStringBot) {
        if bot.active {
            let title = NSLocalizedString("Resume bot?", comment: "")
            let message = String(format: NSLocalizedString("There is a currently active conversation with %@.\n\nDo you want to resume it, or start new?", comment: ""), bot.name)
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
            
            let resumeAction = UIAlertAction(title: NSLocalizedString("Resume", comment: ""), style: UIAlertActionStyle.default) { [weak self] action in
                self?.continueConversation(withBot: bot)
            }
            alert.addAction(resumeAction)
            
            let newAction = UIAlertAction(title: NSLocalizedString("New Converation", comment: ""), style: UIAlertActionStyle.default) { [weak self] action in
                self?.startConversation(withBot: bot)
            }
            alert.addAction(newAction)
            
            self.present(alert, animated: true, completion: nil)
        } else {
            startConversation(withBot: bot)
        }
    }
    
    
    private func startConversation(withBot bot: PullStringBot) {
        
        bot.startConversation { [weak self](json, error) in
            
            print("json: \(json)")
            
            if let json = json {
                self?.process(json: json)
            }
        }
    }
    
    
    private func continueConversation(withBot bot: PullStringBot) {
        
        guard let uuid = bot.conversation else {
            print("Unable to resume the conversation")
            startConversation(withBot: bot)
            return
        }
        
        addBubble(withText: NSLocalizedString("Resuming conversation..", comment: ""), orImage: nil, asBot: true)
        
        bot.say(text: nil, uuid: uuid) { [weak self](json, error) in
            print("json: \(json)\n-----------------------------\n\n")
            
            if let json = json {
                self?.process(json: json)
            }
        }

    }
}


extension BotViewController {
    
    func process(json: JSONDictionary) {
        
        bot.conversation = json["conversation"] as? String
        
        if let outputs = json["outputs"] as? [JSONDictionary] {
            processOutputs(outputs: outputs)
        }
        
        if let timedResponseInterval = json["timed_response_interval"] as? Double, delayedResponseTimer == nil {

            delayedResponseTimer = Timer(timeInterval: timedResponseInterval, repeats: false) { [weak self](timer) in
                self?.stopDelayedResponseTimer()
                self?.send(text: nil)
            }
            
            if let delayedResponseTimer = delayedResponseTimer {
                RunLoop.main.add(delayedResponseTimer, forMode: RunLoopMode.defaultRunLoopMode)
            }
        }

    }
    
    
    func processOutputs(outputs: [JSONDictionary]) {
        for line in outputs {
            
//            let type = line["type"] as? String

//            let character = line["character"] as? String
//            let id = line["id"] as? String
            let behavior = line["behavior"] as? String
            let parameters = line["parameters"] as? JSONDictionary
            let text = line["text"] as? String
            
            if let behavior = behavior, let parameters = parameters {
                processBehavior(behavior: behavior, parameters: parameters)
            }
            
            if let text = text {
                addBubble(withText: text, orImage: nil, asBot: true)
            }
        }
    }
    
    
    func processBehavior(behavior: String, parameters: JSONDictionary) {
        
        if behavior == "show_image" {
            if let image = parameters["image"] as? String, let url = URL(string: image) {
                loadImage(url: url) { [weak self](image) in
                    self?.addBubble(withText: nil, orImage: image, asBot: true)
                }
            }
        }
    }
    
    
    func addBubble(withText text: String?, orImage: UIImage?, asBot: Bool) {
        
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }

            let color = asBot ? strongSelf.botColor : strongSelf.humanColor
            let textColor = asBot ? strongSelf.botTextColor : strongSelf.humanTextColor
            let direction: ChatBubbleDirection = asBot ? .left : .right
            
            if let text = text, let lastChatBubble = strongSelf.lastChatBubble, lastChatBubble.direction == direction, lastChatBubble.image == nil {
                print("Last chat bubble is in our direction, and does not have an image. We can concatenate!")
                lastChatBubble.append(text: text)
            } else {
            
            let chatBubble = ChatBubble(direction: direction, color: color, image: orImage, text: text, textColor: textColor)
            strongSelf.stackView.addArrangedSubview(chatBubble)
            strongSelf.lastChatBubble = chatBubble
            }
            
            strongSelf.scrollView.layoutIfNeeded()

            let contentHeight = strongSelf.scrollView.contentSize.height
            let scrollHeight = strongSelf.scrollView.bounds.size.height
            
            if contentHeight >= scrollHeight {
                let bottomOffset = CGPoint(x: 0, y: contentHeight - scrollHeight)
                strongSelf.scrollView.setContentOffset(bottomOffset, animated: true)
            }
        }
    }
    
    
    private func loadImage(url: URL, completion: ImageCompletion?) {
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if let data = data, let image = UIImage(data: data) {
                
                if let completion = completion {
                    completion(image)
                }
            }
        }
        task.resume()
    }
}


extension BotViewController {
    
    func setupView() {
        
        view.backgroundColor = UIColor.white
        title = bot.name
    }

    
    func setupViewHierarchy() {
        setupScrollView()
        setupStackView()
        setupSeparator()
        setupInputView()
        setupTextField()
        setupSendButton()
        setupTapGestureRecognizer()
    }
    
    
    func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.alignTop(toView: view)
        scrollView.alignLeading(toView: view)
        scrollView.alignTrailing(toView: view)
    }
    
    
    func setupStackView() {
        scrollView.addSubview(stackView)
        stackView.alignTop(toView: scrollView)
        stackView.alignBottom(toView: scrollView)
        stackView.alignLeading(toView: view)
        stackView.alignTrailing(toView: view)
        stackView.backgroundColor = UIColor.red
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 20
        stackView.isLayoutMarginsRelativeArrangement = true
    }
    
    
    func setupTapGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        stackView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    
    func setupSeparator() {
        view.addSubview(separator)
        separator.backgroundColor = UIColor(white: 0.9, alpha: 1)
        separator.layout(belowView: scrollView)
        separator.alignLeading(toView: view)
        separator.alignTrailing(toView: view)
        separator.addConstraint(withHeight: 1)
        separator.setContentHuggingPriority(UILayoutPriorityRequired, for: .vertical)
    }
    
    
    func setupInputView() {
        view.addSubview(textInputView)
        textInputView.layout(belowView: separator, withPadding: 8)
        textInputView.alignLeading(toView: view, withOffset: 8)
        textInputView.alignTrailing(toView: view, withOffset: 8)
        textInputViewBottomConstraint = textInputView.alignBottom(toView: view, withOffset: 8)
    }
    
    
    func setupTextField() {
        textInputView.addSubview(textField)
        textField.alignTop(toView: textInputView)
        textField.alignBottom(toView: textInputView)
        textField.alignLeading(toView: textInputView)
        textField.setContentHuggingPriority(UILayoutPriorityDefaultLow, for: .horizontal)
        textField.setContentHuggingPriority(UILayoutPriorityRequired, for: .vertical)

        let format = NSLocalizedString("Message to %@", comment: "")
        textField.placeholder = String(format: format, bot.name)
        
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 8
        
        textField.delegate = self
    }
    
    
    func setupSendButton() {
        textInputView.addSubview(sendButton)
        sendButton.alignTop(toView: textInputView)
        sendButton.alignBottom(toView: textInputView)
        sendButton.alignTrailing(toView: textInputView)
        sendButton.layout(rightOfView: textField, withPadding: 8)
        sendButton.setContentHuggingPriority(UILayoutPriorityDefaultHigh, for: .horizontal)
        
        sendButton.setTitle(NSLocalizedString("Send", comment: ""), for: .normal)
        sendButton.setTitleColor(UIColor.white, for: .normal)
        sendButton.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .disabled)
        sendButton.backgroundColor = humanColor
        sendButton.isEnabled = false
        sendButton.layer.cornerRadius = 8
        sendButton.contentEdgeInsets = UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 12)
        
        sendButton.addTarget(self, action: #selector(sendInput), for: .touchUpInside)
    }
    
    
    func sendInput() {
        guard let text = textField.text, text.characters.count > 0 else { return }
        
        stopDelayedResponseTimer()

        print("\n\n=====================\nSending... \(textField.text)")
        
        addBubble(withText: text, orImage: nil, asBot: false)
        
        send(text: text)
        
        textField.text = nil
    }
    
    
    func send(text: String?) {
        if let conversation = bot.conversation {
            bot.say(text: text, uuid: conversation) { [weak self](json, error) in
                print("json: \(json)\n-----------------------------\n\n")
                
                if let json = json {
                    self?.process(json: json)
                }
            }
        } else {
            bot.startConversation() { [weak self](json, error) in
                print("json: \(json)\n-----------------------------\n\n")
                
                if let json = json {
                    self?.process(json: json)
                }
            }
        }
    }
    
    
    func stopDelayedResponseTimer() {
        delayedResponseTimer?.invalidate()
        delayedResponseTimer = nil
    }
    
    
    func dismissKeyboard() {
        self.textField.resignFirstResponder()
    }
}


extension BotViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString = textField.text ?? ""
        let finalString = (currentString as NSString).replacingCharacters(in: range, with: string)
        sendButton.isEnabled = (finalString.characters.count > 0)
        
        return true
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        sendInput()
        return true
    }
}
