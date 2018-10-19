//
//  ToDoTabBarController.swift
//  ToDoApp
//
//  Created by Anastasios Grigoriou on 10/18/18.
//  Copyright © 2018 Grigoriou. All rights reserved.
//

import UIKit

class ToDoTabBarController: UITabBarController {
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        setupNavigationControllers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupNavigationControllers() {
        
    }
    
}
