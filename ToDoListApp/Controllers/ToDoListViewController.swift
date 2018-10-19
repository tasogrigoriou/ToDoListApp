//
//  ToDoViewController.swift
//  ToDoListApp
//
//  Created by Anastasios Grigoriou on 9/18/18.
//  Copyright © 2018 Grigoriou. All rights reserved.
//

import UIKit
import CoreData

class ToDoListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    
    let model = ToDoListModel()
    
    var tableViewState = TableViewState.current
    var keyboardIsShowing = false
    
    // MARK - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNavBarTitle()
        setupBarButtonItems()
        addTapGestureRecognizer()
        loadData()
    }
    
    func setTaskToCompleted(task: Task, at indexPath: IndexPath) {
        model.setTaskToCompleted(task: task) { [weak self] success in
            if success {
                
            }
        }
        DispatchQueue.global(qos: .userInitiated).async {
            task.isComplete = true
            task.dateCompleted = Date() as NSDate
            var rowToDelete: Int?
            if let index = self.currentTasks.firstIndex(where: { $0 == task }) {
                rowToDelete = index
                self.currentTasks.remove(at: index)
            }
            self.completedTasks.insert(task, at: 0)
            
            PersistenceService.saveContext({ [weak self] success in
                if success {
                    DispatchQueue.main.async {
                        guard let sself = self else { return }
                        sself.tableView.beginUpdates()
                        if let row = rowToDelete {
                            sself.tableView.deleteRows(at: [IndexPath(row: row, section: 0)], with: .fade)
                        }
                        if sself.tableViewState == .showingCompleted {
                            let rowToAdd = sself.currentTasks.count + 1
                            sself.tableView.insertRows(at: [IndexPath(row: rowToAdd, section: 0)], with: .fade)
                        }
                        sself.tableView.endUpdates()
                    }
                }
            })
            
        }
    }
    
    @objc private func addNewTask() {
        
    }
    
    // MARK - IBActions
    
//    @IBAction func addButtonPressed(_ sender: UIButton) {
//        if let name = textField.text, !name.isEmpty {
//            saveNewTask(name) { [weak self] success in
//                if success {
//                    guard let sself = self else { return }
//                    let numTasks = sself.currentTasks.count
//                    if numTasks > 0 {
//                        sself.tableView.insertRows(at: [IndexPath(row: numTasks - 1, section: 0)], with: .fade)
//                    } else {
//                        sself.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
//                    }
//                }
//            }
//        }
//        textField?.resignFirstResponder()
//        textField?.text = ""
//    }
    
    // MARK - Private Methods
    
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
        let rightButtonItem = UIBarButtonItem(image: UIImage(named: "plus"), style: .plain, target: self, action: #selector(addNewTask))
        rightButtonItem.tintColor = .black
        navigationItem.rightBarButtonItem = rightButtonItem
    }
    
    private func addTapGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: view, action: #selector(view.endEditing(_:)))
        tapGestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureRecognizer)
    }
}

//extension ToDoListViewController: ShowCompletedCellDelegate {
//    func didTapShowCompletedButton(_ button: UIButton) {
//        switch tableViewState {
//        case .normal:
//            tableViewState = .showingCompleted
//            var rowsToAdd: [IndexPath] = []
//            for index in 0..<completedTasks.count {
//                rowsToAdd.append(IndexPath(row: index + (currentTasks.count + 1), section: 0))
//            }
//            tableView.insertRows(at: rowsToAdd, with: .fade)
//        case .showingCompleted:
//            tableViewState = .normal
//            var rowsToDelete: [IndexPath] = []
//            for index in 0..<completedTasks.count {
//                rowsToDelete.append(IndexPath(row: index + (currentTasks.count + 1), section: 0))
//            }
//            tableView.deleteRows(at: rowsToDelete, with: .fade)
//        }
//        let title = tableViewState == .normal ? "Show Completed" : "Hide Completed"
//        button.setTitle(title, for: .normal)
//    }
//}

extension ToDoListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableViewState {
        case .current: return model.currentTasks.count
        case .completed: return model.completedTasks.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoTableViewCell", for: indexPath) as! ToDoTableViewCell
        switch tableViewState {
        case .current:
            cell.titleLabel.text = model.currentTasks[indexPath.row].name
        case .completed:
            cell.titleLabel.text = model.completedTasks[indexPath.row].name
        }
        return cell
    }
}

extension ToDoListViewController: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
//        if keyboardIsShowing {
//            keyboardIsShowing = false
//            return false
//        } else if ((tableView.cellForRow(at: indexPath) as? ShowCompletedTableViewCell) != nil) ||
//            indexPath.row > currentTasks.count {
//            return false
//        }
//
//        return true
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if ((tableView.cellForRow(at: indexPath) as? ToDoTableViewCell) != nil) {
//            setTaskToCompleted(task: currentTasks[indexPath.row], at: indexPath)
//        }
//    }
}

extension ToDoListViewController: UITextFieldDelegate {
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        if let name = textField.text, !name.isEmpty {
//            model.saveNewTask(name) { [weak self] success in
//                if success {
//                    guard let sself = self else { return }
//                    let numTasks = sself.currentTasks.count
//                    if numTasks > 0 {
//                        sself.tableView.insertRows(at: [IndexPath(row: numTasks - 1, section: 0)], with: .fade)
//                    } else {
//                        sself.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
//                    }
//                }
//            }
//        }
//        textField.resignFirstResponder()
//        textField.text = ""
//
//        return true
//    }
}

enum TableViewState {
    case current
    case completed
}

