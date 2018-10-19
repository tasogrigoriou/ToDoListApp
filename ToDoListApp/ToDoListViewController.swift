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
    
    var fetchedTasks: [Task] = []
    var currentTasks: [Task] = []
    var completedTasks: [Task] = []
    
    var tableViewState = TableViewState.normal
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
    
    // MARK - Core Data Methods
    
    func fetchTasks(_ completion: @escaping (_ success: Bool) -> Void) {
        do {
            fetchedTasks = try PersistenceService.context.fetch(Task.fetchRequest())
            completion(true)
        } catch let error as NSError {
            print("Could not fetch - \(error.localizedDescription)")
            completion(false)
        }
    }
    
    func saveNewTask(_ name: String, _ completion: @escaping (_ success: Bool) -> Void) {
        let newTask = Task(context: PersistenceService.context)
        newTask.name = name
        newTask.dateCreated = Date() as NSDate
        newTask.isComplete = false
        
        currentTasks.append(newTask)
        
        PersistenceService.saveContext(completion)
    }
    
    func setTaskToCompleted(task: Task, at indexPath: IndexPath) {
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
    
    @objc private func clearCompletedTasks() {
        DispatchQueue.global(qos: .userInitiated).async {
            let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
            fetchRequest.predicate = NSPredicate.init(format: "isComplete == true")
            do {
                let items = try PersistenceService.context.fetch(fetchRequest)
                for item in items {
                    PersistenceService.context.delete(item)
                }
                PersistenceService.saveContext { [weak self] success in
                    if success {
                        guard let sself = self else { return }
                        if sself.tableViewState == .showingCompleted {
                            var rowsToDelete: [IndexPath] = []
                            for index in 0..<sself.completedTasks.count {
                                rowsToDelete.append(IndexPath(row: index + (sself.currentTasks.count + 1), section: 0))
                            }
                            sself.completedTasks.removeAll()
                            DispatchQueue.main.async {
                                sself.tableView.deleteRows(at: rowsToDelete, with: .fade)
                            }
                        } else {
                            sself.completedTasks.removeAll()
                            DispatchQueue.main.async {
                                sself.tableView.reloadData()
                            }
                        }
                    }
                }
            } catch let error as NSError {
                print("error fetching with fetch request \(error.localizedDescription)")
            }
        }
    }
    
    // MARK - IBActions
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        if let name = textField.text, !name.isEmpty {
            saveNewTask(name) { [weak self] success in
                if success {
                    guard let sself = self else { return }
                    let numTasks = sself.currentTasks.count
                    if numTasks > 0 {
                        sself.tableView.insertRows(at: [IndexPath(row: numTasks - 1, section: 0)], with: .fade)
                    } else {
                        sself.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
                    }
                }
            }
        }
        textField?.resignFirstResponder()
        textField?.text = ""
    }
    
    // MARK - Private Methods
    
    private func loadData() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.fetchTasks { [weak self] success in
                if success {
                    guard let strongSelf = self else { return }
                    strongSelf.setupCurrentAndCompletedTasks()
                    DispatchQueue.main.async {
                        strongSelf.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    private func setupCurrentAndCompletedTasks() {
        for task in fetchedTasks {
            if task.isComplete {
                completedTasks.append(task)
            } else {
                currentTasks.append(task)
            }
        }
        currentTasks = currentTasks.sorted(by: {
            guard let date1 = $0.dateCreated, let date2 = $1.dateCreated else { return false }
            return (date1 as Date).compare(date2 as Date) == .orderedAscending
        })
        completedTasks = completedTasks.sorted(by: {
            guard let date1 = $0.dateCompleted, let date2 = $1.dateCompleted else { return false }
            return (date1 as Date).compare(date2 as Date) == .orderedDescending
        })
    }
    
    private func setupTableView() {
        tableView.register(UINib(nibName: "ToDoTableViewCell", bundle: nil), forCellReuseIdentifier: "ToDoTableViewCell")
        tableView.register(UINib(nibName: "ShowCompletedTableViewCell", bundle: nil), forCellReuseIdentifier: "ShowCompletedTableViewCell")
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    private func setupNavBarTitle() {
        let label = UILabel(frame: CGRect.zero)
        label.backgroundColor = UIColor.clear
        if let font = UIFont(name: "AvenirNextCondensed-DemiBold", size: 20.0) {
            label.font = font
        }
        label.textAlignment = .center
        label.textColor = UIColor.black
        label.text = "To Do List"
        label.sizeToFit()
        navigationItem.titleView = label
    }
    
    private func setupBarButtonItems() {
        let leftButtonItem = UIBarButtonItem(image: UIImage(named: "broom"), style: .plain, target: self, action: #selector(clearCompletedTasks))
        leftButtonItem.tintColor = UIColor.black
        navigationItem.leftBarButtonItem = leftButtonItem
    }
    
    private func addTapGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: view, action: #selector(view.endEditing(_:)))
        tapGestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureRecognizer)
    }
}

extension ToDoListViewController: ShowCompletedCellDelegate {
    func didTapShowCompletedButton(_ button: UIButton) {
        switch tableViewState {
        case .normal:
            tableViewState = .showingCompleted
            var rowsToAdd: [IndexPath] = []
            for index in 0..<completedTasks.count {
                rowsToAdd.append(IndexPath(row: index + (currentTasks.count + 1), section: 0))
            }
            tableView.insertRows(at: rowsToAdd, with: .fade)
        case .showingCompleted:
            tableViewState = .normal
            var rowsToDelete: [IndexPath] = []
            for index in 0..<completedTasks.count {
                rowsToDelete.append(IndexPath(row: index + (currentTasks.count + 1), section: 0))
            }
            tableView.deleteRows(at: rowsToDelete, with: .fade)
        }
        let title = tableViewState == .normal ? "Show Completed" : "Hide Completed"
        button.setTitle(title, for: .normal)
    }
}
    
extension ToDoListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableViewState {
        case .normal:
            return currentTasks.count + 1
        case .showingCompleted:
            return currentTasks.count + 1 + completedTasks.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        
        switch tableViewState {
        case .normal:
            if indexPath.row == currentTasks.count || currentTasks.count == 0 {
                let showCompletedCell = tableView.dequeueReusableCell(withIdentifier: "ShowCompletedTableViewCell", for: indexPath) as! ShowCompletedTableViewCell
                showCompletedCell.delegate = self
                cell = showCompletedCell
            } else {
                let toDoCell = tableView.dequeueReusableCell(withIdentifier: "ToDoTableViewCell", for: indexPath) as! ToDoTableViewCell
                toDoCell.titleLabel.text = currentTasks[indexPath.row].name
                cell = toDoCell
            }
            return cell
        case .showingCompleted:
            if indexPath.row == currentTasks.count {
                let showCompletedCell = tableView.dequeueReusableCell(withIdentifier: "ShowCompletedTableViewCell", for: indexPath) as! ShowCompletedTableViewCell
                showCompletedCell.delegate = self
                cell = showCompletedCell
            } else if indexPath.row < currentTasks.count {
                let toDoCell = tableView.dequeueReusableCell(withIdentifier: "ToDoTableViewCell", for: indexPath) as! ToDoTableViewCell
                toDoCell.titleLabel.text = currentTasks[indexPath.row].name
                cell = toDoCell
            } else {
                let completedCell = tableView.dequeueReusableCell(withIdentifier: "ToDoTableViewCell", for: indexPath) as! ToDoTableViewCell
                let index = indexPath.row - (currentTasks.count + 1)
                completedCell.titleLabel.text = completedTasks[index].name
                cell = completedCell
            }
            return cell
        }
    }
}

extension ToDoListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if keyboardIsShowing {
            keyboardIsShowing = false
            return false
        } else if ((tableView.cellForRow(at: indexPath) as? ShowCompletedTableViewCell) != nil) ||
            indexPath.row > currentTasks.count {
            return false
        }
        
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if ((tableView.cellForRow(at: indexPath) as? ToDoTableViewCell) != nil) {
            setTaskToCompleted(task: currentTasks[indexPath.row], at: indexPath)
        }
    }
}

extension ToDoListViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let name = textField.text, !name.isEmpty {
            saveNewTask(name) { [weak self] success in
                if success {
                    guard let sself = self else { return }
                    let numTasks = sself.currentTasks.count
                    if numTasks > 0 {
                        sself.tableView.insertRows(at: [IndexPath(row: numTasks - 1, section: 0)], with: .fade)
                    } else {
                        sself.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
                    }
                }
            }
        }
        textField.resignFirstResponder()
        textField.text = ""
        
        return true
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.textField = textField
        keyboardIsShowing = true
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
}

enum TableViewState {
    case normal
    case showingCompleted
}

