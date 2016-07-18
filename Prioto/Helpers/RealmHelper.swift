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
	
	static func addTask(task: Task) {
		let realm = try! Realm()
		try! realm.write() {
			realm.add(task)
		}
	}
	
	
	
	static func deleteTask(task: Task) {
		let realm = try! Realm()
		try! realm.write() {
			realm.delete(task)
		}
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
}