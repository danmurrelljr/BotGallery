//
//  TextField.swift
//  BotGallery
//
//  Created by Dan Murrell on 10/24/16.
//  Copyright © 2016 Mutant Soup. All rights reserved.
//

import UIKit

class TextField: UITextField {
    let inset: CGFloat = 8
    
    // placeholder position
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: inset , dy: inset)
    }
    
    // text position
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: inset , dy: inset)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: inset, dy: inset)
    }
}
