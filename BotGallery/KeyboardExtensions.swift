//
//  KeyboardExtensions.swift
//  BotGallery
//
//  Created by Dan Murrell on 10/26/16.
//  Copyright © 2016 Mutant Soup. All rights reserved.
//

import UIKit


private var bottomConstraintInitialConstant: CGFloat = 0
private var keyboardWillChangeFrameObserver: NSObjectProtocol? = nil
private var keyboardWillHideObserver: NSObjectProtocol? = nil


protocol KeyboardObservation {
    func addKeyboardFrameWillChangeObserver(forView view: UIView, withBottomConstraint constraint: NSLayoutConstraint)
    func removeKeyboardFrameWillChangeObserver()
}


extension KeyboardObservation where Self: UIViewController {

    func addKeyboardFrameWillChangeObserver(forView view: UIView, withBottomConstraint constraint: NSLayoutConstraint) {
    
        bottomConstraintInitialConstant = constraint.constant
        
        keyboardWillChangeFrameObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil, queue: nil) { [weak self](notification) in
            self?.handleKeyboardChangeNotification(notification, view: view, constraint: constraint)
        }
    }
    
    
    func removeKeyboardFrameWillChangeObserver() {
        
        bottomConstraintInitialConstant = 0
        
        if let willChangeFrameObserver = keyboardWillChangeFrameObserver {
            NotificationCenter.default.removeObserver(willChangeFrameObserver)
            keyboardWillChangeFrameObserver = nil
        }
        
        if let willhideObserver = keyboardWillHideObserver {
            NotificationCenter.default.removeObserver(willhideObserver)
            keyboardWillHideObserver = nil
        }
    }

    
    private func handleKeyboardChangeNotification(_ notification: Notification, view: UIView, constraint: NSLayoutConstraint) {
        
        guard let frameEnd: CGRect = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue,
            let animationDuration: Double = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue else { return }
        
        if notification.name == NSNotification.Name.UIKeyboardWillChangeFrame {
            constraint.constant = -(self.view.bounds.size.height - frameEnd.origin.y) + bottomConstraintInitialConstant
        } else {
            constraint.constant = 0
        }
        
        view.setNeedsLayout()
        
        UIView.animate(withDuration: animationDuration) {
            self.view.layoutIfNeeded()
        }
    }
}
