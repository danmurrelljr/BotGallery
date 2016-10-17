//
//  TableViewCellExtensions.swift
//  BotGallery
//
//  Created by Dan Murrell on 10/24/16.
//  Copyright © 2016 Mutant Soup. All rights reserved.
//

import UIKit


extension UITableView
{
    func registerCell(_ cellClass: AnyClass)
    {
        self.register(cellClass, forCellReuseIdentifier: cellClass.identifier)
    }
}


extension UITableViewCell
{
    static var identifier: String {return NSStringFromClass(self)}
}
