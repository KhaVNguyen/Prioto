//
//  TasksTableViewNew.swift
//  Prioto
//
//  Created by Kha Nguyen on 7/29/16.
//  Copyright © 2016 Kha. All rights reserved.
//

import Foundation
import Spring
import UIKit

class TasksTableView: UITableView {
		
	var rearrange: RearrangeProperties!
	
	override init(frame: CGRect, style: UITableViewStyle) {
		
		super.init(frame: frame, style: style)
		
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
}


