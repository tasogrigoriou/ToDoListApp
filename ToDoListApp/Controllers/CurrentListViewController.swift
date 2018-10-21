//
//  CurrentListViewController.swift
//  ToDoListApp
//
//  Created by Anastasios Grigoriou on 10/18/18.
//  Copyright © 2018 Grigoriou. All rights reserved.
//

import UIKit

class CurrentListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var model: ToDoListModelProtocol
    
    init(model: ToDoListModelProtocol) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
        definesPresentationContext = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNavBarTitle()
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
        if let font = UIFont(name: "AvenirNextCondensed-Bold", size: 22.0) {
            label.font = font
        }
        label.textAlignment = .center
        label.textColor = .black
        label.text = "To Do List"
        label.sizeToFit()
        navigationItem.titleView = label
    }
    
    @IBAction func addButtonPressed() {
        addNewTask()
    }
    
    @objc private func addNewTask() {
        let popUpVC = PopUpViewController(delegate: self)
        present(popUpVC, animated: true, completion: nil)
    }
    
    private func setTaskToCompleted(task: Task, row: Int) {
        model.setTaskToCompleted(task: task) { [weak self] success in
            guard let strongSelf = self else { return }
            if success {
                DispatchQueue.main.async {
                    strongSelf.tableView.deleteRows(at: [IndexPath(row: row, section: 0)], with: .fade)
                    NotificationCenter.default.post(name: Notification.Name("taskSetToCompleted"), object: nil)
                }
            }
        }
    }

}

extension CurrentListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.currentTasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoTableViewCell", for: indexPath) as! ToDoTableViewCell
        cell.delegate = self
        cell.titleLabel.text = model.currentTasks[indexPath.row].name
        return cell
    }
}

extension CurrentListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let popUpVC = PopUpViewController(task: model.currentTasks[indexPath.row], delegate: self)
        present(popUpVC, animated: true, completion: nil)
    }
}

extension CurrentListViewController: PopUpViewControllerDelegate {
    func createNewTask(name: String) {
        model.saveNewTask(name) { [weak self] success in
            if success {
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
        }
    }
    
    func updateTask(_ task: Task, newName: String) {
        model.updateTask(task, newName: newName) { [weak self] success in
            if success {
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
        }
    }
}

extension CurrentListViewController: ToDoTableViewCellDelegate {
    func setTaskToCompleted(_ sender: ToDoTableViewCell) {
        guard let indexPath = tableView.indexPath(for: sender) else { return }
        setTaskToCompleted(task: model.currentTasks[indexPath.row], row: indexPath.row)
    }
}

