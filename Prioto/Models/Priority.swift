//
//  Priority.swift
//  Prioto
//
//  Created by Kha Nguyen on 8/1/16.
//  Copyright © 2016 Kha. All rights reserved.
//

import Foundation
import RealmSwift

class Priority: Object {
	dynamic var name = ""
	dynamic var shouldNotAddPlaceholderCell = false
	let tasks = List<Task>()
}
