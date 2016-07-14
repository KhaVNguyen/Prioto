//
//  TaskTableViewCell.swift
//  Prioto
//
//  Created by Kha Nguyen on 7/11/16.
//  Copyright © 2016 Kha. All rights reserved.
//

import UIKit
import QuartzCore


// A protocol that the TableViewCell uses to inform its delegate of state change
//protocol TableViewCellDelegate {
//	// indicates that the given item has been deleted
//	func deleteTask(task: Task, priorityIndex: Int,row:Int,section:Int)
//}

class TaskTableViewCell: UITableViewCell {

	@IBOutlet weak var taskTextLabel: UILabel!
	
	// The object that acts as delegate for this cell.
	//var delegate: TableViewCellDelegate?
	// The item that this cell renders.
//	var task: Task?
//	var taskPriorityIndex: Int?
//	var taskIndex: Int?
	
	let gradientLayer = CAGradientLayer()
	
	override func awakeFromNib() {
        super.awakeFromNib()
		gradientLayer.frame = bounds
		let color1 = UIColor(white: 1.0, alpha: 0.2).CGColor as CGColorRef
		let color2 = UIColor(white: 1.0, alpha: 0.1).CGColor as CGColorRef
		let color3 = UIColor.clearColor().CGColor as CGColorRef
		let color4 = UIColor(white: 0.0, alpha: 0.1).CGColor as CGColorRef
		gradientLayer.colors = [color1, color2, color3, color4]
		gradientLayer.locations = [0.0, 0.01, 0.95, 1.0]
		layer.insertSublayer(gradientLayer, atIndex: 0)
    }
	
	override func layoutSubviews() {
		super.layoutSubviews()
		gradientLayer.frame = bounds
	}

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
	
}
