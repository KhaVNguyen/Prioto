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


class TasksTableViewController: UITableViewController {
	var realm: Realm!
	var notificationToken: NotificationToken?
	var priorityIndexes = [0, 1, 2, 3]
	var priorityTitles = ["Urgent | Important", "Urgent | Not Important", "Not Urgent | Important", "Not Urgent | Not Important"]
	var tasksByPriority = [Results<Task>]() {
		didSet {
			print("didSet")
			printOutTaskByPriority()
		}
	}

	
	func printOutTaskByPriority(){
		var index = 0
		for priority in tasksByPriority {
			print("\(priorityTitles[index++]):\(priority.count)")
			for task in priority {
				print(task.text)
			}
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		realm = try! Realm()
		
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
		
		notificationToken = realm.addNotificationBlock { [unowned self] note, realm in
			self.tableView.reloadData()
		}
		
		tableView.backgroundColor = UIColor.whiteColor()
		
		for priority in priorityIndexes {
			let unsortedObjects = realm.objects(Task.self).filter("priorityIndex == \(priority)")
			let sortedObjects = unsortedObjects.sorted("dateCreated", ascending: true)
			tasksByPriority.append(sortedObjects)
		}
		
		tableView.reloadData()
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
		
		self.strikethroughCompleted(indexPath, cell: cell, task: task!)
		
		//configure left buttons
		cell.leftButtons = [MGSwipeButton(title: "Done", backgroundColor: UIColor(red: 0, green: 0, blue: 0, alpha: 0), callback: {
			(sender: MGSwipeTableCell!) -> Bool in
			
			task!.completed = !task!.completed
			self.strikethroughCompleted(indexPath, cell: cell, task: task!)
			return true
			})]
		cell.leftSwipeSettings.transition = MGSwipeTransition.Border
		cell.rightButtons = [MGSwipeButton(title: "Delete", backgroundColor: UIColor(red: 0, green: 0, blue: 0, alpha: 0), callback: {
			(sender: MGSwipeTableCell!) -> Bool in
			RealmHelper.deleteTask(self.taskForIndexPath(indexPath)!)
			self.printOutTaskByPriority()
			return true
		})]
		
		cell.contentView.layer.cornerRadius = 8
		cell.contentView.layer.masksToBounds = true
		cell.layer.borderColor = UIColor.whiteColor().CGColor
		cell.layer.borderWidth = 2
		cell.layer.cornerRadius = 8
		
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
	
	// Override to support editing the table view.
//	override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
//		if editingStyle == .Delete {
//			// Delete the row from the data source
//			// RealmHelper.deleteTask(taskForIndexPath(indexPath)!)
//			print(tasksByPriority[indexPath.section])
//		} else if editingStyle == .Insert {
//			// Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//		}
//	}
	
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
					printOutTaskByPriority()
				}
			}
			else {
				RealmHelper.addTask(task)
				printOutTaskByPriority()
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
					displayTaskViewController.priorityIndex = indexPath.section
				}
			}
			
			else if identifier == "addNewTaskSegue" {
				print("Adding new task")
			}
		}
	}
}