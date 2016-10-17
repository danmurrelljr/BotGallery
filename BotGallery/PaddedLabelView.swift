//
//  PaddedLabelView.swift
//  BotGallery
//
//  Created by Dan Murrell on 10/25/16.
//  Copyright © 2016 Mutant Soup. All rights reserved.
//

import UIKit


class PaddedLabelView: UIView {
    
    let insets: UIEdgeInsets
    let label = UILabel()
    
    
    init(padding: CGFloat) {
        self.insets = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        
        super.init(frame: CGRect.zero)
        
        setupLabel()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupLabel() {
        addSubview(label)
        label.align(toView: self, withInsets: insets)
    }
}
