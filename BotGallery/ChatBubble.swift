//
//  ChatBubble.swift
//  BotGallery
//
//  Created by Dan Murrell on 10/25/16.
//  Copyright © 2016 Mutant Soup. All rights reserved.
//

import UIKit


enum ChatBubbleDirection {
    case left
    case right
}


class ChatBubble: UIStackView {
    
    var image: UIImage?
    var texts: [String] = []
    var textColor: UIColor?
    let direction: ChatBubbleDirection
    let color: UIColor
    
    var imageView: UIImageView?
    var paddedLabelViews: [PaddedLabelView] = []
    
    
    init(direction: ChatBubbleDirection, color: UIColor, image: UIImage? = nil, text: String? = nil, textColor: UIColor? = nil) {
        self.direction = direction
        self.color = color
        self.image = image
        self.textColor = textColor
        
        if let text = text {
            texts.append(text)
        }
        
        super.init(frame: CGRect.zero)
        
        setupMyView()
        setupStackView()
        setupViews()
        insertViews()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setupMyView() {
    }
    
    
    func append(text: String) {
        texts.append(text)

        let paddedLabelView = self.paddedLabelView(withText: text)
        paddedLabelViews.append(paddedLabelView)
        add(paddedLabelView: paddedLabelView)
    }

    
    private func setupStackView() {
        self.axis = .vertical
        self.distribution = .fill
        self.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        self.isLayoutMarginsRelativeArrangement = true
        self.spacing = 2
        
        if direction == .left {
            self.alignment = .leading
        } else {
            self.alignment = .trailing
        }
    }

    
    private func setupViews() {

        if let image = image {
            imageView = UIImageView(image: image)
            imageView?.layer.cornerRadius = 0
            imageView?.contentMode = .scaleAspectFit
        }
        
        if let text = texts.first {
            let paddedLabelView = self.paddedLabelView(withText: text)
            add(paddedLabelView: paddedLabelView)
        }
    }

    
    private func insertViews() {
        switch direction {
        case .left:
            if let imageView = imageView {
                add(imageView: imageView)
            }
            if let paddedLabelView = paddedLabelViews.first {
                add(paddedLabelView: paddedLabelView)
            }
            add(padding: 25)
            break
            
        case .right:
            add(padding: 25)
            if let paddedLabelView = paddedLabelViews.first {
                add(paddedLabelView: paddedLabelView)
            }
            if let imageView = imageView {
                add(imageView: imageView)
            }
            break
        }
    }
    
    
    private func add(paddedLabelView: PaddedLabelView) {
        addArrangedSubview(paddedLabelView)
        paddedLabelView.setContentHuggingPriority(UILayoutPriorityRequired, for: .horizontal)
    }
    
    
    private func add(imageView: UIImageView) {
        addArrangedSubview(imageView)
        if var size = imageView.image?.size {
            let maximum = UIScreen.main.bounds.width - (self.layoutMargins.left + self.layoutMargins.right)
            if size.width > maximum {
                size.width = maximum
                size.height = maximum
            }
            imageView.addConstraint(withSize: size)
        }
    }

    
    private func add(padding: CGFloat) {
        let size = CGSize(width: padding, height: padding)
        let frame = CGRect(origin: CGPoint.zero, size: size)
        let space = UIView(frame: frame)
        space.backgroundColor = UIColor.red

        addArrangedSubview(space)
    }
    
    
    private func paddedLabelView(withText text: String) -> PaddedLabelView {
        let paddedLabelView = PaddedLabelView(padding: 8)
        
        paddedLabelView.label.text = text
        paddedLabelView.label.numberOfLines = 0
        paddedLabelView.label.textColor = textColor
        paddedLabelView.label.textAlignment = direction == .left ? .left : .right
        paddedLabelView.backgroundColor = color
        paddedLabelView.layer.cornerRadius = 8
        
        return paddedLabelView
    }
}
