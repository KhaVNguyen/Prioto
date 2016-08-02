//
//  TaskTableViewCell.swift
//  Prioto
//
//  Created by Kha Nguyen on 7/11/16.
//  Copyright © 2016 Kha. All rights reserved.
//

import UIKit
import QuartzCore
import MGSwipeTableCell



// A protocol that the TableViewCell uses to inform its delegate of state change
//protocol TableViewCellDelegate {
//	// indicates that the given item has been deleted
//	func deleteTask(task: Task, priorityIndex: Int,row:Int,section:Int)
//}

class TaskTableViewCell: MGSwipeTableCell {
	@IBOutlet weak var stackView: UIStackView!

	@IBOutlet weak var taskTextLabel: UILabel!
	
	@IBAction func expandTaskButtonTapped(sender: AnyObject) {
		if let selectionCallback = self.selectionCallback{
			selectionCallback()
		}
	}
	
	@IBAction func timeTaskButtonTapped(sender: AnyObject) {
		if let timeTaskCallBack = self.timeTaskCallBack {
			timeTaskCallBack()
		}
	}
	var expanded = false
	var selectionCallback: (() -> Void)?
	var timeTaskCallBack: (() -> Void)?

	let gradientLayer = CAGradientLayer()
	
	override func awakeFromNib() {
        super.awakeFromNib()
		stackView.arrangedSubviews.last?.hidden = true
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

	
	func changeCellStatus(expanded: Bool){
		self.expanded = expanded
		UIView.animateWithDuration(0.5,
		                           delay: 0,
		                           usingSpringWithDamping: 1,
		                           initialSpringVelocity: 1,
		                           options: UIViewAnimationOptions.CurveEaseIn,
		                           animations: { () -> Void in
									//print("expanded: \(expanded).Before assignment: \(self.stackView.arrangedSubviews.last!.hidden)")
									self.stackView.arrangedSubviews.last!.hidden = !expanded
									//print("hidden: \(self.stackView.arrangedSubviews.last!.hidden)")
			},
		                           completion: nil)
	}
	
	func switchCellStatus() {
		self.expanded = !self.expanded
		changeCellStatus(expanded)
	}
	
	
	@IBOutlet weak var timeElapsedLabel: UILabel!
	
	
	
	
	
}
