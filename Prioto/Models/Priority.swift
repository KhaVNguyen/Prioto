//
//  Priority.swift
//  Prioto
//
//  Created by Kha Nguyen on 7/11/16.
//  Copyright © 2016 Kha. All rights reserved.
//

import Foundation

class Priority {
	var type: String
	var tasksInPriority: [Task] = []
	
	init(type: String) {
		self.type = type
	}
	
	func addTask(text: String) {
		let task = Task(text: text)
		self.tasksInPriority.append(task)
	}
	
	func deleteTask(index: Int) {
		tasksInPriority.removeAtIndex(index)
	}
	
	func indexOfTask(task: Task) -> Int {
		return (tasksInPriority as NSArray).indexOfObject(task)
	}
}
