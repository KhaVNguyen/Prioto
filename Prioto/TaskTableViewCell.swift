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
protocol TableViewCellDelegate {
	// indicates that the given item has been deleted
	func deleteTask(task: Task, priorityIndex: Int)
}

class TaskTableViewCell: UITableViewCell {

	@IBOutlet weak var taskTextLabel: UILabel!
	
	@IBAction func deleteButtonTapped(sender: AnyObject) {
		if delegate != nil && task != nil && taskPriorityIndex != nil && taskIndex != nil {
			// notify the delegate that this item should be deleted
			delegate!.deleteTask(task!, priorityIndex: taskPriorityIndex!)
		}
	}
	
	// gesture-related variables
	var originalCenter = CGPoint()
	var deleteOnDragRelease = false
	
	// The object that acts as delegate for this cell.
	var delegate: TableViewCellDelegate?
	// The item that this cell renders.
	var task: Task?
	var taskPriorityIndex: Int?
	var taskIndex: Int?
	
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		var recognizer = UIPanGestureRecognizer(target: self, action: "handlePan:")
		recognizer.delegate = self
		addGestureRecognizer(recognizer)

    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
	
	//MARK: - horizontal pan gesture methods
	func handlePan(recognizer: UIPanGestureRecognizer) {
		// 1
		if recognizer.state == .Began {
			// when the gesture begins, record the current center location
			originalCenter = center
		}
		// 2
		if recognizer.state == .Changed {
			let translation = recognizer.translationInView(self)
			center = CGPointMake(originalCenter.x + translation.x, originalCenter.y)
			// has the user dragged the item far enough to initiate a delete/complete?
			deleteOnDragRelease = frame.origin.x < -frame.size.width / 2.0
		}
		// 3
		if recognizer.state == .Ended {
			// the frame this cell had before user dragged it
			let originalFrame = CGRect(x: 0, y: frame.origin.y,
			                           width: bounds.size.width, height: bounds.size.height)
			if !deleteOnDragRelease {
				// if the item is not being deleted, snap back to the original location
				UIView.animateWithDuration(0.2, animations: {self.frame = originalFrame})
			}
			
			if deleteOnDragRelease {
				if delegate != nil && task != nil && taskPriorityIndex != nil && taskIndex != nil{
					// notify the delegate that this item should be deleted
					delegate!.deleteTask(task!, priorityIndex: taskPriorityIndex!)
				}
			}
		}
	}
	
	override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
		if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
			let translation = panGestureRecognizer.translationInView(superview!)
			if fabs(translation.x) > fabs(translation.y) {
				return true
			}
			return false
		}
		return false
	}
}
