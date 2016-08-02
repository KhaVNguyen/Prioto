//
//  RealmHelper.swift
//  Prioto
//
//  Created by Kha Nguyen on 7/15/16.
//  Copyright © 2016 Kha. All rights reserved.
//

import Foundation
import RealmSwift

class RealmHelper {
	
	static func deleteTask(task: Task) -> Task {
		let realm = try! Realm()
		try! realm.write() {
			realm.delete(task)
		}
		return task
	}

	static func updateTask(taskToBeUpdated: Task, newTask: Task) {
		let realm = try! Realm()
		try! realm.write() {
			taskToBeUpdated.text = newTask.text
			taskToBeUpdated.details = newTask.details
			taskToBeUpdated.dueDate = newTask.dueDate
			taskToBeUpdated.completed = newTask.completed
		}
	}
	
	static func addPriorities() {
		modifyRealm { priorities in
			//let group = groups.realm!.create(Group.self, value: ["name": "Group \(arc4random())", "entries": []])
			//groups.append(group)
			let priorityTitles = ["Urgent | Important", "Urgent | Not Important", "Not Urgent | Important", "Not Urgent | Not Important"]
			for priorityTitle in priorityTitles {
				let priority = priorities.realm!.create(Priority.self, value: ["name": priorityTitle, "tasks": []])
				priorities.append(priority)
			}
		}
	}
	
	static func addTask(task: Task) {
		modifyRealm { priorities in
			//let group = groups[Int(arc4random_uniform(UInt32(groups.count)))]
			//let entry = groups.realm!.create(Entry.self, value: ["Entry \(arc4random())", NSDate()])
			//group.entries.append(entry)
			
			let priority = priorities[task.priorityIndex]
			priority.tasks.append(task)
		}
		
	}
	
	static func insertTask(task: Task, indexPath: NSIndexPath) {
		modifyRealm { priorities in
			let priority = priorities[indexPath.section]
			priority.tasks.insert(task, atIndex: indexPath.row)
		}
		
	}
	
	
	static func modifyRealm(block: (List<Priority>) -> Void) {
			let realm = try! Realm()
			let tasksByPriority = realm.objects(TasksByPriority.self).first!
			try! realm.write {
				block(tasksByPriority.priorities)
			}
	}
	
	static func getTaskTitles() -> [String] {
		var taskTitles: [String] = []
		let realm = try! Realm()
		let tasksByPriority = realm.objects(TasksByPriority.self).first!
		let priorities = tasksByPriority.priorities
		for priority in priorities {
			for task in priority.tasks {
				taskTitles.append(task.text)
			}
		}
		print(taskTitles)
		return taskTitles
	}
}