import XCTest
@testable import ToDoListApp

class ToDoListAppTests: XCTestCase {
    
    var model: ToDoListModelProtocol!
    
    override func setUp() {
        super.setUp()
        model = ToDoListModel()
    }
    
    func test_fetchTasksSuccess() {
        let result = true
        model.fetchTasks { success in
            XCTAssertEqual(result, success)
        }
    }
    
    func test_saveNewTaskSuccess() {
        let result = true
        model.saveNewTask(name) { success in
            XCTAssertEqual(result, success)
        }
    }
    
    func test_saveNewTaskWithName() {
        let name = "newtask"
        model.saveNewTask(name) { [weak self] success in
            if success {
                XCTAssertEqual(name, self?.model.currentTasks.last?.name)
            }
        }
    }
    
    func test_setTaskToCompleted() {
        let name = "soonToBeCompletedTask"
        model.saveNewTask(name) { [weak self] success in
            if success, let task = self?.model.currentTasks.last {
                self?.model.setTaskToCompleted(task: task, { success in
                    if success {
                        XCTAssertEqual(name, self?.model.completedTasks.first?.name)
                    }
                })
            }
        }
    }
    
    func test_deleteTask() {
        model.saveNewTask("soonToBeDeletedTask") { [weak self] success in
            if success, let task = self?.model.currentTasks.last {
                self?.model.deleteTask(task) { success in
                    if success {
                        XCTAssertNotEqual(task, self?.model.currentTasks.last)
                    }
                }
            }
        }
    }
    
    func test_clearCompletedTasksSuccess() {
        let result = true
        model.clearCompletedTasks { success in
            XCTAssertEqual(result, success)
        }
    }
    
    func test_clearCompletedTasks() {
        let result = 0
        model.saveNewTask("soonToBeClearedTask") { [weak self] success in
            if success, let task = self?.model.currentTasks.last {
                self?.model.setTaskToCompleted(task: task, { success in
                    if success {
                        self?.model.clearCompletedTasks { success in
                            if success {
                                XCTAssertEqual(result, self?.model.completedTasks.count)
                            }
                        }
                    }
                })
            }
        }
    }
}

