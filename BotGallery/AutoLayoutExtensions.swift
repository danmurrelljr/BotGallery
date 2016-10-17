//
//  AutoLayoutExtensions.swift
//  BotGallery
//
//  Created by Dan Murrell on 10/24/16.
//  Copyright © 2016 Mutant Soup. All rights reserved.
//

import UIKit


protocol AutoLayout {
    func addConstraint(withSize size: CGSize)
    func addConstraint(withHeight height: CGFloat)
    func addConstraint(withWidth width: CGFloat)
    func alignCenter()
    func alignCenterX()
    func alignCenterY()
    func alignLeading(toView view: UIView, withOffset offset: CGFloat) -> NSLayoutConstraint?
    func alignTrailing(toView view: UIView, withOffset offset: CGFloat) -> NSLayoutConstraint?
    func alignTop(toView view: UIView, withOffset offset: CGFloat) -> NSLayoutConstraint?
    func alignBottom(toView view: UIView, withOffset offset: CGFloat) -> NSLayoutConstraint?
    func align(toView view: UIView, withInsets insets: UIEdgeInsets)
    func layout(aboveView view: UIView, withPadding padding: CGFloat) -> NSLayoutConstraint?
    func layout(belowView view: UIView, withPadding padding: CGFloat) -> NSLayoutConstraint?
    func layout(leftOfView view: UIView, withPadding padding: CGFloat) -> NSLayoutConstraint?
    func layout(rightOfView view: UIView, withPadding padding: CGFloat) -> NSLayoutConstraint?
    func layout(beforeView view: UIView, withPadding padding: CGFloat) -> NSLayoutConstraint?
    func layout(followingView view: UIView, withPadding padding: CGFloat) -> NSLayoutConstraint?
}


extension UIView: AutoLayout {
    
    func addConstraint(withSize size: CGSize) {
        addConstraint(withWidth: size.width)
        addConstraint(withHeight: size.height)
    }
    
    
    func addConstraint(withHeight height: CGFloat) {
        addPropertyConstraint(attribute: NSLayoutAttribute.height, withValue: height)
    }
    
    
    func addConstraint(withWidth width: CGFloat) {
        addPropertyConstraint(attribute: NSLayoutAttribute.width, withValue: width)
    }
    
    
    func alignCenter() {
        alignCenterX()
        alignCenterY()
    }
    
    
    func alignCenterX() {
        addConstraintAttribute(attribute: NSLayoutAttribute.centerX)
    }
    
    
    func alignCenterY() {
        addConstraintAttribute(attribute: NSLayoutAttribute.centerY)
    }

    @discardableResult
    func alignLeading(toView view: UIView, withOffset offset: CGFloat = 0) -> NSLayoutConstraint? {
        return addConstraintAttribute(attribute: NSLayoutAttribute.leading, view: view, constant: offset)
    }
    
    
    @discardableResult
    func alignTrailing(toView view: UIView, withOffset offset: CGFloat = 0) -> NSLayoutConstraint? {
        return addConstraintAttribute(attribute: NSLayoutAttribute.trailing, view: view, constant: -offset)
    }
    
    
    @discardableResult
    func alignTop(toView view: UIView, withOffset offset: CGFloat = 0) -> NSLayoutConstraint? {
        return addConstraintAttribute(attribute: NSLayoutAttribute.top, view: view, constant: offset)
    }
    
    
    @discardableResult
    func alignBottom(toView view: UIView, withOffset offset: CGFloat = 0) -> NSLayoutConstraint? {
        return addConstraintAttribute(attribute: NSLayoutAttribute.bottom, view: view, constant: -offset)
    }
    
    
    func align(toView view: UIView, withInsets insets: UIEdgeInsets = UIEdgeInsets.zero) {
        addConstraintAttribute(attribute: NSLayoutAttribute.top, view: view, constant: insets.top)
        addConstraintAttribute(attribute: NSLayoutAttribute.bottom, view: view, constant: -insets.bottom)
        addConstraintAttribute(attribute: NSLayoutAttribute.leading, view: view, constant: insets.left)
        addConstraintAttribute(attribute: NSLayoutAttribute.trailing, view: view, constant: -insets.right)
    }
    
    
    @discardableResult
    func layout(aboveView view: UIView, withPadding padding: CGFloat = 0) -> NSLayoutConstraint? {
        return addConstraintAttribute(attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, view: view, toAttribute: NSLayoutAttribute.top, constant: padding)
    }
    
    
    @discardableResult
    func layout(belowView view: UIView, withPadding padding: CGFloat = 0) -> NSLayoutConstraint? {
        return addConstraintAttribute(attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, view: view, toAttribute: NSLayoutAttribute.bottom, constant: padding)
    }
    
    
    @discardableResult
    func layout(leftOfView view: UIView, withPadding padding: CGFloat = 0) -> NSLayoutConstraint? {
        return addConstraintAttribute(attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, view: view, toAttribute: NSLayoutAttribute.left, constant: padding)
    }
    
    
    @discardableResult
    func layout(rightOfView view: UIView, withPadding padding: CGFloat = 0) -> NSLayoutConstraint? {
        return addConstraintAttribute(attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, view: view, toAttribute: NSLayoutAttribute.right, constant: padding)
    }
    
    
    @discardableResult
    func layout(beforeView view: UIView, withPadding padding: CGFloat = 0) -> NSLayoutConstraint? {
        return addConstraintAttribute(attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, view: view, toAttribute: NSLayoutAttribute.leading, constant: padding)
    }
    
    
    @discardableResult
    func layout(followingView view: UIView, withPadding padding: CGFloat = 0) -> NSLayoutConstraint? {
        return addConstraintAttribute(attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, view: view, toAttribute: NSLayoutAttribute.trailing, constant: padding)
    }
    
    
    // MARK: - Private
    
    @discardableResult
    private func addConstraintAttribute(attribute: NSLayoutAttribute) -> NSLayoutConstraint?
    {
        return addConstraintAttribute(attribute: attribute, constant: 0)
    }
    
    @discardableResult
    private func addConstraintAttribute(attribute: NSLayoutAttribute, constant: CGFloat) -> NSLayoutConstraint?
    {
        guard let superview = self.superview else { assertionFailure("Unable to add constraint without a superview!"); return nil }
        return addConstraintAttribute(attribute: attribute, view: superview, constant: constant)
    }
    
    
    @discardableResult
    private func addConstraintAttribute(attribute: NSLayoutAttribute, view: UIView, constant: CGFloat) -> NSLayoutConstraint
    {
        return addConstraintAttribute(attribute: attribute, relatedBy: NSLayoutRelation.equal, view: view, constant: constant)
    }
    
    
    @discardableResult
    private func addConstraintAttribute(attribute: NSLayoutAttribute, relatedBy: NSLayoutRelation, view: UIView, constant: CGFloat) -> NSLayoutConstraint
    {
        return addConstraintAttribute(attribute: attribute, relatedBy: relatedBy, view: view, toAttribute: attribute, constant: constant)
    }

    
    @discardableResult
    private func addConstraintAttribute(attribute: NSLayoutAttribute, relatedBy: NSLayoutRelation, view: UIView, toAttribute: NSLayoutAttribute, constant: CGFloat) -> NSLayoutConstraint
    {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        let constraint = NSLayoutConstraint(item: self, attribute: attribute, relatedBy: relatedBy, toItem: view, attribute: toAttribute, multiplier: 1.0, constant: constant)
        constraint.isActive = true
        
        return constraint
    }
    
    
    private func addPropertyConstraint(attribute: NSLayoutAttribute, withValue value: CGFloat)
    {
        addPropertyConstraint(attribute: attribute, withValue: value, relatedBy: NSLayoutRelation.equal)
    }
    
    
    private func addPropertyConstraint(attribute: NSLayoutAttribute, withValue value: CGFloat, relatedBy: NSLayoutRelation)
    {
        addPropertyConstraint(attribute: attribute, withValue: value, relatedBy: relatedBy, priority: UILayoutPriorityRequired)
    }
    
    
    private func addPropertyConstraint(attribute: NSLayoutAttribute, withValue value: CGFloat, relatedBy: NSLayoutRelation, priority: UILayoutPriority)
    {
        guard let superview = self.superview else { assertionFailure("Unable to add constraint without a superview!"); return }
        let constraint = NSLayoutConstraint(item: self, attribute: attribute, relatedBy: relatedBy, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: value)
        constraint.priority = priority
        superview.addConstraint(constraint)
        self.translatesAutoresizingMaskIntoConstraints = false
    }

}
