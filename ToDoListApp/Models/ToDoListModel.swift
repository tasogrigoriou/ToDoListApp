//
//  ToDoListModel.swift
//  ToDoListApp
//
//  Created by Anastasios Grigoriou on 10/18/18.
//  Copyright © 2018 Grigoriou. All rights reserved.
//

import Foundation
import CoreData

protocol ToDoListModelProtocol {
    func fetchTasks(_ completion: ((_ success: Bool) -> Void)?)
    func saveNewTask(_ name: String, _ completion: ((_ success: Bool) -> Void)?)
    func setTaskToCompleted(task: Task, _ completion: ((_ success: Bool) -> Void)?)
    func updateTask(_ task: Task, newName: String, _ completion: ((_ success: Bool) -> Void)?)
    func clearCompletedTasks(_ completion: ((_ success: Bool) -> Void)?)
    var fetchedTasks: [Task] { get }
    var currentTasks: [Task] { get }
    var completedTasks: [Task] { get }
}

class ToDoListModel {
    var fetchedTasks: [Task] = []
    var currentTasks: [Task] = []
    var completedTasks: [Task] = []
    
    private func setupCurrentAndCompletedTasks() {
        currentTasks.removeAll()
        completedTasks.removeAll()
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
}

extension ToDoListModel: ToDoListModelProtocol {
    func fetchTasks(_ completion: ((_ success: Bool) -> Void)?) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                self.fetchedTasks = try PersistenceService.context.fetch(Task.fetchRequest())
                self.setupCurrentAndCompletedTasks()
                completion?(true)
            } catch let error as NSError {
                print("Could not fetch - \(error.localizedDescription)")
                completion?(false)
            }
        }
    }
    
    func saveNewTask(_ name: String, _ completion: ((_ success: Bool) -> Void)?) {
        DispatchQueue.global(qos: .userInitiated).async {
            let newTask = Task(context: PersistenceService.context)
            newTask.name = name
            newTask.dateCreated = Date() as NSDate
            newTask.isComplete = false
            
            self.currentTasks.append(newTask)
            
            PersistenceService.saveContext(completion)
        }
    }
    
    func setTaskToCompleted(task: Task, _ completion: ((_ success: Bool) -> Void)?) {
        DispatchQueue.global(qos: .userInitiated).async {
            task.isComplete = true
            task.dateCompleted = Date() as NSDate
            if let index = self.currentTasks.firstIndex(where: { $0 == task }) {
                self.currentTasks.remove(at: index)
            }
            self.completedTasks.insert(task, at: 0)
            
            PersistenceService.saveContext(completion)
        }
    }
    
    func updateTask(_ task: Task, newName: String, _ completion: ((_ success: Bool) -> Void)?) {
        DispatchQueue.global(qos: .userInitiated).async {
            if let index = self.currentTasks.firstIndex(where: { $0 == task }) {
                self.currentTasks[index].name = newName
            }
            task.name = newName
            PersistenceService.saveContext(completion)
        }
    }
    
    func clearCompletedTasks(_ completion: ((_ success: Bool) -> Void)?) {
        DispatchQueue.global(qos: .userInitiated).async {
            let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
            fetchRequest.predicate = NSPredicate.init(format: "isComplete == true")
            do {
                let items = try PersistenceService.context.fetch(fetchRequest)
                for item in items {
                    PersistenceService.context.delete(item)
                }
                self.completedTasks.removeAll()
                
                PersistenceService.saveContext(completion)
                
            } catch let error as NSError {
                print("error fetching with fetch request \(error.localizedDescription)")
            }
        }
    }
}
