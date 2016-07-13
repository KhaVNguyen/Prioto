//
//  Task.swift
//  Prioto
//
//  Created by Kha Nguyen on 7/11/16.
//  Copyright © 2016 Kha. All rights reserved.
//

import Foundation

class Task {
	var text: String
	var details: String?
	var completed: Bool
	var dueDate: NSDate?
	
	init(text: String) {
		self.text = text
		self.completed = false
	}
}
