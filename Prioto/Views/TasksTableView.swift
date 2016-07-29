//
//  TasksTableViewNew.swift
//  Prioto
//
//  Created by Kha Nguyen on 7/29/16.
//  Copyright © 2016 Kha. All rights reserved.
//

import Foundation

import UIKit

class TasksTableView: UITableView {
	
	let estimatedHeight: CGFloat = 90
	
	var rearrange: RearrangeProperties!
	
	override init(frame: CGRect, style: UITableViewStyle) {
		
		super.init(frame: frame, style: style)
		
		self.backgroundColor = UIColor.grayColor()
		self.layoutMargins = UIEdgeInsetsZero
		self.separatorInset = UIEdgeInsetsZero
		self.estimatedRowHeight = estimatedHeight
		self.rowHeight = UITableViewAutomaticDimension
		
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
}


