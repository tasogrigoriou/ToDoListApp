//
//  CompletedListViewController.swift
//  ToDoListApp
//
//  Created by Anastasios Grigoriou on 10/18/18.
//  Copyright © 2018 Grigoriou. All rights reserved.
//

import UIKit

class CompletedListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var model: ToDoListModelProtocol
    
    init(model: ToDoListModelProtocol) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNavBarTitle()
        setupBarButtonItems()
        addTaskCompletedObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    private func loadData() {
        model.fetchTasks { [weak self] success in
            if success {
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
        }
    }
    
    private func setupTableView() {
        tableView.register(UINib(nibName: "ToDoTableViewCell", bundle: nil), forCellReuseIdentifier: "ToDoTableViewCell")
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    private func setupNavBarTitle() {
        let label = UILabel(frame: CGRect.zero)
        label.backgroundColor = UIColor.clear
        if let font = UIFont(name: "AvenirNextCondensed-DemiBold", size: 20.0) {
            label.font = font
        }
        label.textAlignment = .center
        label.textColor = .black
        label.text = "To Do List"
        label.sizeToFit()
        navigationItem.titleView = label
    }
    
    private func setupBarButtonItems() {
        let leftButtonItem = UIBarButtonItem(image: UIImage(named: "broom"), style: .plain, target: self, action: #selector(clearCompletedTasks))
        leftButtonItem.tintColor = .black
        navigationItem.leftBarButtonItem = leftButtonItem
    }
    
    private func addTaskCompletedObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(taskCompleted), name: Notification.Name("taskSetToCompleted"), object: nil)
    }
    
    @objc private func clearCompletedTasks() {
        model.clearCompletedTasks { [weak self] success in
            if success {
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
        }
    }
    
    @objc private func taskCompleted() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
}

extension CompletedListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.completedTasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoTableViewCell", for: indexPath) as! ToDoTableViewCell
        cell.titleLabel.text = model.completedTasks[indexPath.row].name
        cell.circleImageView.image = UIImage(named: "completedtask")
        return cell
    }
}
