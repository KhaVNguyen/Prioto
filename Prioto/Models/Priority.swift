//
//  Priority.swift
//  Prioto
//
//  Created by Kha Nguyen on 7/11/16.
//  Copyright © 2016 Kha. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

class Priority : Object{
	dynamic var type: String = ""
	dynamic var tasksInPriority: [Task] = []
	

	required init() {
		super.init()
	}
	
	required init(realm: RLMRealm, schema: RLMObjectSchema) {
		super.init(realm: realm, schema: schema)
	}
	
	required init(value: AnyObject, schema: RLMSchema) {
		super.init(value: value, schema: schema)
	}
	
	required convenience init(type: String) {
		self.init()
		self.type = type
	}
	
	func addTask(text: String) {
		let task = Task()
		task.text = text
		self.tasksInPriority.append(task)
	}
	
	func deleteTask(index: Int) {
		tasksInPriority.removeAtIndex(index)
	}
	
	func indexOfTask(task: Task) -> Int {
		return (tasksInPriority as NSArray).indexOfObject(task)
	}
}
