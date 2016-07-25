//
//  TaskTableViewController.swift
//  Prioto
//
//  Created by Kha Nguyen on 7/11/16.
//  Copyright © 2016 Kha. All rights reserved.
//

import UIKit
import MGSwipeTableCell
import RealmSwift
import Realm
import AEAccordion

class TasksTableViewController: UITableViewController {
	
	@IBAction func fillButtonTapped(sender: AnyObject) {
		RealmHelper.addTask(Task(text: "1", priority: 0))
		RealmHelper.addTask(Task(text: "2", priority: 0))
		RealmHelper.addTask(Task(text: "3", priority: 0))
		RealmHelper.addTask(Task(text: "4", priority: 0))
		RealmHelper.addTask(Task(text: "5", priority: 0))
		
		RealmHelper.addTask(Task(text: "1", priority: 1))
		RealmHelper.addTask(Task(text: "2", priority: 1))
		RealmHelper.addTask(Task(text: "3", priority: 1))
		RealmHelper.addTask(Task(text: "4", priority: 1))
		RealmHelper.addTask(Task(text: "5", priority: 1))
		
		RealmHelper.addTask(Task(text: "1", priority: 2))
		RealmHelper.addTask(Task(text: "2", priority: 2))
		RealmHelper.addTask(Task(text: "3", priority: 2))
		RealmHelper.addTask(Task(text: "4", priority: 2))
		RealmHelper.addTask(Task(text: "5", priority: 2))
		
		RealmHelper.addTask(Task(text: "1", priority: 3))
		RealmHelper.addTask(Task(text: "2", priority: 3))
		RealmHelper.addTask(Task(text: "3", priority: 3))
		RealmHelper.addTask(Task(text: "4", priority: 3))
		RealmHelper.addTask(Task(text: "5", priority: 3))
	}
	
	
	@IBAction func deleteAllButtonTapped(sender: AnyObject) {
		try! realm.write() {
			realm.deleteAll()
		}
	}
	
	var realm: Realm!
	var notificationToken: NotificationToken?
	var priorityIndexes = [0, 1, 2, 3]
	var priorityTitles = ["Urgent | Important", "Urgent | Not Important", "Not Urgent | Important", "Not Urgent | Not Important"]
	var tasksByPriority = [Results<Task>]()
    override func viewDidLoad() {
        super.viewDidLoad()
		
		
		realm = try! Realm()
		
		notificationToken = realm.addNotificationBlock { [unowned self] note, realm in
			self.tableView.reloadData()
		}
		
		tableView.backgroundColor = UIColor.whiteColor()
		
		for priority in priorityIndexes {
			let unsortedObjects = realm.objects(Task.self).filter("priorityIndex == \(priority)")
			let sortedObjects = unsortedObjects.sorted("dateCreated", ascending: true)
			tasksByPriority.append(sortedObjects)
		}
		
		var leftButton = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("showEditing:"))
		self.navigationItem.leftBarButtonItem = leftButton
		
		tableView.reloadData()
		
		// long press drag and drop gesture recognizer
		let longpress = UILongPressGestureRecognizer(target: self, action: "longPressGestureRecognized:")
		tableView.addGestureRecognizer(longpress)
	}
	
	func showEditing(sender: UIBarButtonItem) {
		if(self.tableView.editing == true)
		{
			self.tableView.editing = false
			self.navigationItem.leftBarButtonItem?.title = "Done"
		}
		else
		{
			self.tableView.editing = true
			self.navigationItem.leftBarButtonItem?.title = "Edit"
		}
	}
	
	override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		if editingStyle == .Delete {
			// Delete the row from the data source
			RealmHelper.deleteTask(self.taskForIndexPath(indexPath)!)
		} else if editingStyle == .Insert {
			// Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
		}
	}
	
	func longPressGestureRecognized(gestureRecognizer: UIGestureRecognizer) {
		let longPress = gestureRecognizer as! UILongPressGestureRecognizer
		let state = longPress.state
		let locationInView = longPress.locationInView(tableView)
		let indexPath = tableView.indexPathForRowAtPoint(locationInView)
		
		struct My {
			static var cellSnapshot : UIView? = nil
			static var cellIsAnimating : Bool = false
			static var cellNeedToShow : Bool = false
		}
		struct Path {
			static var initialIndexPath : NSIndexPath? = nil
		}
		
		switch state {
		case UIGestureRecognizerState.Began:
			if indexPath != nil {
				Path.initialIndexPath = indexPath
				let cell = tableView.cellForRowAtIndexPath(indexPath!) as UITableViewCell!
				My.cellSnapshot  = snapshotOfCell(cell)
				
				var center = cell.center
				My.cellSnapshot!.center = center
				My.cellSnapshot!.alpha = 0.0
				tableView.addSubview(My.cellSnapshot!)
				
				UIView.animateWithDuration(0.25, animations: { () -> Void in
					center.y = locationInView.y
					My.cellIsAnimating = true
					My.cellSnapshot!.center = center
					My.cellSnapshot!.transform = CGAffineTransformMakeScale(1.05, 1.05)
					My.cellSnapshot!.alpha = 0.98
					cell.alpha = 0.0
					}, completion: { (finished) -> Void in
						if finished {
							My.cellIsAnimating = false
							if My.cellNeedToShow {
								My.cellNeedToShow = false
								UIView.animateWithDuration(0.25, animations: { () -> Void in
									cell.alpha = 1
								})
							} else {
								cell.hidden = true
							}
						}
				})
			}
			
		case UIGestureRecognizerState.Changed:
			if My.cellSnapshot != nil {
				var center = My.cellSnapshot!.center
				center.y = locationInView.y
				My.cellSnapshot!.center = center
				
				if ((indexPath != nil) && (indexPath != Path.initialIndexPath)) {
					//itemsArray.insert(itemsArray.removeAtIndex(Path.initialIndexPath!.row), atIndex: indexPath!.row)
					try! realm.write() {
						taskForIndexPath(Path.initialIndexPath!)?.priorityIndex = indexPath!.section
						tableView.reloadData()
					}
					Path.initialIndexPath = indexPath
				}
			}
		default:
			if Path.initialIndexPath != nil {
				let cell = tableView.cellForRowAtIndexPath(Path.initialIndexPath!) as UITableViewCell!
				if My.cellIsAnimating {
					My.cellNeedToShow = true
				} else {
					cell.hidden = false
					cell.alpha = 0.0
				}
				
				UIView.animateWithDuration(0.25, animations: { () -> Void in
					My.cellSnapshot!.center = cell.center
					My.cellSnapshot!.transform = CGAffineTransformIdentity
					My.cellSnapshot!.alpha = 0.0
					cell.alpha = 1.0
					
					}, completion: { (finished) -> Void in
						if finished {
							Path.initialIndexPath = nil
							My.cellSnapshot!.removeFromSuperview()
							My.cellSnapshot = nil
						}
				})
			}
		}
	}
	
	func snapshotOfCell(inputView: UIView) -> UIView {
		UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
		inputView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
		let image = UIGraphicsGetImageFromCurrentImageContext() as UIImage
		UIGraphicsEndImageContext()
		
		let cellSnapshot : UIView = UIImageView(image: image)
		cellSnapshot.layer.masksToBounds = false
		cellSnapshot.layer.cornerRadius = 0.0
		cellSnapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0)
		cellSnapshot.layer.shadowRadius = 5.0
		cellSnapshot.layer.shadowOpacity = 0.4
		return cellSnapshot
	}
	
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
	override func tableView(tableView: UITableView, heightForRowAtIndexPath
		indexPath: NSIndexPath) -> CGFloat {
		return tableView.rowHeight;
	}
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return priorityIndexes.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return Int(tasksByPriority[section].count)
    }
	
	
	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return priorityTitles[section]
	}
	

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("taskTableViewCell", forIndexPath: indexPath) as! TaskTableViewCell
		
        // Configure the cell...
		let task = self.taskForIndexPath(indexPath)
				
		//configure left buttons
		cell.leftButtons = [MGSwipeButton(title: "", icon: UIImage(named:"completeTask.png"), backgroundColor: UIColor(red: 0, green: 0, blue: 0, alpha: 0), callback: {
			(sender: MGSwipeTableCell!) -> Bool in
			try! self.realm.write() {
				let task = self.taskForIndexPath(indexPath)
				self.taskForIndexPath(indexPath)?.completed = !(self.taskForIndexPath(indexPath)?.completed)!
				self.strikethroughCompleted(indexPath, cell: cell, task: task!)
			}
			return true
			})]
		cell.leftSwipeSettings.transition = MGSwipeTransition.Border
		cell.rightButtons = [MGSwipeButton(title: "", icon: UIImage(named:"deleteTask.png"), backgroundColor: UIColor(red: 0, green: 0, blue: 0, alpha: 0), callback: {
			(sender: MGSwipeTableCell!) -> Bool in
			RealmHelper.deleteTask(self.taskForIndexPath(indexPath)!)
			return true
		})]
		
		self.strikethroughCompleted(indexPath, cell: cell, task: task!)
		
		cell.contentView.layer.cornerRadius = 8
		cell.contentView.layer.masksToBounds = true
		cell.layer.borderColor = UIColor.whiteColor().CGColor
		cell.layer.borderWidth = 2
		cell.layer.cornerRadius = 5
		
        return cell
    }
	
	func taskForIndexPath(indexPath: NSIndexPath) -> Task? {
		return tasksByPriority[indexPath.section][indexPath.row]
	}
	
	func strikethroughCompleted(indexPath: NSIndexPath, cell: TaskTableViewCell, task: Task) {
		if let task = taskForIndexPath(indexPath) {
			if task.completed {
				let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: task.text)
				attributeString.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0, attributeString.length))
				cell.taskTextLabel.attributedText = attributeString
			}
			else {
				cell.taskTextLabel.text = task.text
			}
		}
	}
	// MARK: - Table view delegate
	
	func colorForIndexRow(row: Int, section: Int) -> UIColor {
		let itemCount = tasksByPriority[section].count - 1
		let val = (CGFloat(row) / CGFloat(itemCount)) * 0.5
		
		switch section {
			// urgent | important
			case 0:
				return UIColor(red: 1.0, green: val, blue: 0.0, alpha: 1.0)
			
			// urgent | not important
			case 1:
				return UIColor(red: 0.0, green: val, blue: 1.0, alpha: 1.0)

			// not urgent | important
			case 2:
				return UIColor(red: 1.0, green: val, blue: 1.0, alpha: 1.0)

			// not urgent | not important
			case 3:
				return UIColor(red: 0.0, green: 1.0, blue: val, alpha: 1.0)
			
			default:
				return UIColor(red: 1.0, green: val, blue: 0.0, alpha: 1.0)
		}
	}
	
 
	override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell,
	                        forRowAtIndexPath indexPath: NSIndexPath) {
		cell.backgroundColor = colorForIndexRow(indexPath.row, section: indexPath.section)
	}
	
	// Override to support conditional editing of the table view.
	override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		// Return false if you do not want the specified item to be editable.
		return true
	}
	
	// MARK: Segues
	
	@IBAction func unwindToTasksTableViewController(sender: UIStoryboardSegue) {
		if let sourceViewController = sender.sourceViewController as? DisplayTaskViewController, task = sourceViewController.task, priorityIndex = sourceViewController.priorityIndex {
			if let selectedIndexPath = tableView.indexPathForSelectedRow {
				// Update an existing task.
				if selectedIndexPath.section == priorityIndex { // not changing priority
					RealmHelper.updateTask(taskForIndexPath(selectedIndexPath)!, newTask: task)
				}
				
				else { // changing priority
					RealmHelper.addTask(task)
					RealmHelper.deleteTask(taskForIndexPath(selectedIndexPath)!)
				}
			}
			else {
				RealmHelper.addTask(task)
			}
		}
		
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if let identifier = segue.identifier {
			
			if identifier == "editTaskDetailsSegue" {
				let displayTaskViewController = segue.destinationViewController as! DisplayTaskViewController
				
				// set task of DisplayTaskViewController to task tapped on
				if let selectedTaskCell = sender as? TaskTableViewCell {
					let indexPath = tableView.indexPathForCell(selectedTaskCell)!
					let selectedTask = taskForIndexPath(indexPath)
					displayTaskViewController.task = selectedTask
					print("Task completed: \(selectedTask!.completed)")
					displayTaskViewController.priorityIndex = indexPath.section
					displayTaskViewController.completed = (selectedTask?.completed)!
				}
			}
			
			else if identifier == "addNewTaskSegue" {
			}
		}
	}
}

extension AEAccordionTableViewController {
	
}