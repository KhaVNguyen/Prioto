//
//  Task.swift
//  Prioto
//
//  Created by Kha Nguyen on 7/11/16.
//  Copyright © 2016 Kha. All rights reserved.
//

import Foundation
import RealmSwift

class Task: Object {
	dynamic var text: String = ""
	dynamic var details: String = ""
	dynamic var completed: Bool = false
	dynamic var dueDate: NSDate? = nil
	dynamic var priorityIndex: Int = 0
	dynamic var dateCreated = NSDate()
	
	convenience init(text: String) {
		self.init()
		self.text = text
	}
	
	convenience init(text: String, priority: Int) {
		self.init()
		self.text = text
		self.priorityIndex = priority
	}
}
