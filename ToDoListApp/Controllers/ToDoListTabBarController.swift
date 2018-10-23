//
//  ToDoTabBarController.swift
//  ToDoApp
//
//  Created by Anastasios Grigoriou on 10/18/18.
//  Copyright © 2018 Grigoriou. All rights reserved.
//

import UIKit

class ToDoListTabBarController: UITabBarController {
    init() {
        super.init(nibName: nil, bundle: nil)
        setupNavigationControllers()
        setupTabBarItems()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
    
    private func setupNavigationControllers() {
        let model = ToDoListModel()
        let currentVC = CurrentListViewController(model: model)
        let completedVC = CompletedListViewController(model: model)
        let currentNav = UINavigationController(rootViewController: currentVC)
        let completedNav = UINavigationController(rootViewController: completedVC)
        viewControllers = [currentNav, completedNav]
    }
    
    private func setupTabBarItems() {
        tabBar.items?[0].image = UIImage(named: "current")
        tabBar.items?[0].selectedImage = UIImage(named: "current")
        tabBar.items?[0].title = "Current"
        tabBar.items?[0].tag = 0
        
        tabBar.items?[1].image = UIImage(named: "complete")
        tabBar.items?[1].selectedImage = UIImage(named: "complete")
        tabBar.items?[1].title = "Completed"
        tabBar.items?[1].tag = 1
    }
}
