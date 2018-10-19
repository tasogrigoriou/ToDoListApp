//
//  Task+CoreDataProperties.swift
//  ToDoListApp
//
//  Created by Anastasios Grigoriou on 9/18/18.
//  Copyright © 2018 Grigoriou. All rights reserved.
//
//

import Foundation
import CoreData

extension Task {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: "Task")
    }

    @NSManaged public var dateCreated: NSDate?
    @NSManaged public var dateCompleted: NSDate?
    @NSManaged public var name: String?
    @NSManaged public var isComplete: Bool
}
