//
//  Task.swift
//  Prioto
//
//  Created by Kha Nguyen on 8/1/16.
//  Copyright © 2016 Kha. All rights reserved.
//


import RealmSwift

class Task: Object {
	dynamic var uuid: String =  ""
	dynamic var text: String = ""
	dynamic var details: String = ""
	dynamic var completed: Bool = false
	dynamic var dueDate: NSDate? = nil
	dynamic var reminderDate: NSDate? = nil
	dynamic var priorityIndex: Int = 0
	dynamic var dateCreated = NSDate()
	dynamic var timeWorked = 0 // in seconds 
	dynamic var isBeingWorkedOn = false
	
	convenience init(text: String) {
		self.init()
		self.text = text
		
	}
	
	convenience init(text: String, priority: Int) {
		self.init()
		self.text = text
		self.priorityIndex = priority
	}
	
	
	convenience init(task: Task) {
		self.init()
		self.text = task.text
		self.details = task.details
		self.completed = task.completed
		self.dueDate = task.dueDate
		self.dateCreated = task.dateCreated
		self.timeWorked = task.timeWorked
		self.priorityIndex = task.priorityIndex
		self.isBeingWorkedOn = task.isBeingWorkedOn
		self.reminderDate = task.reminderDate
		self.uuid = task.uuid
	}
	
	convenience init(task: Task, index: Int) {
		self.init()
		self.text = task.text
		self.priorityIndex = index
		self.details = task.details
		self.completed = task.completed
		self.dueDate = task.dueDate
		self.dateCreated = task.dateCreated
		self.timeWorked = task.timeWorked
		self.reminderDate = task.reminderDate
		self.uuid = task.uuid
	}
}
