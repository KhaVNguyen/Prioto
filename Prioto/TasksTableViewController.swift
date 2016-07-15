//
//  TaskTableViewController.swift
//  Prioto
//
//  Created by Kha Nguyen on 7/11/16.
//  Copyright © 2016 Kha. All rights reserved.
//

import UIKit
import MGSwipeTableCell

class TasksTableViewController: UITableViewController {
	
	var tasks: [Priority] =
		[Priority(type: "Urgent | Important"),
		 Priority(type: "Urgent | Not Important"),
		 Priority(type: "Not Urgent | Important"),
		 Priority(type: "Not Urgent | Not Important")]
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		tableView.backgroundColor = UIColor.whiteColor()
		
		tasks[1].addTask("Call Bill.")
		tasks[1].addTask("Take out the trash.")
		tasks[0].addTask("Study for test")
		tasks[2].addTask("Finish todo list app")
		tasks[0].addTask("Implement priorities into todo list app")
		tasks[0].addTask("Work on college apps")
		tasks[0].addTask("Implement pomodoro timer")
		tasks[2].addTask("Email Mr. Shuen")
		tasks[2].addTask("Go for a walk")
		tasks[0].addTask("Catch Pokemon ")
		tasks[3].addTask("Eat a sandwich.")
		tasks[3].addTask("Drink lemonade.")
		tasks[3].addTask("Sleep a full 8 hours.")
		tasks[3].addTask("Eat rice.")
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
        return tasks.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tasks[section].tasksInPriority.count
    }
	
	
	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return tasks[section].type
	}
	

	
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("taskTableViewCell", forIndexPath: indexPath) as! TaskTableViewCell
		
        // Configure the cell...
		let task = tasks[indexPath.section].tasksInPriority[indexPath.row]
		cell.taskTextLabel.text = task.text

		//configure left buttons
		cell.leftButtons = [MGSwipeButton(title: "Done", backgroundColor: UIColor(red: 0, green: 0, blue: 0, alpha: 0), callback: {
			(sender: MGSwipeTableCell!) -> Bool in
			self.tasks[indexPath.section].tasksInPriority[indexPath.row].completed = !self.tasks[indexPath.section].tasksInPriority[indexPath.row].completed
			if self.tasks[indexPath.section].tasksInPriority[indexPath.row].completed {
				let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: self.tasks[indexPath.section].tasksInPriority[indexPath.row].text)
				attributeString.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0, attributeString.length))
				cell.taskTextLabel.attributedText = attributeString
			}
			else {
				cell.taskTextLabel.text = task.text
			}
			return true
			})]
		cell.leftSwipeSettings.transition = MGSwipeTransition.Border
		
        return cell
    }
	
	
	// MARK: - Table view delegate
	
	func colorForIndexRow(row: Int, section: Int) -> UIColor {
		let itemCount = tasks.count - 1
		let val = (CGFloat(row) / CGFloat(itemCount)) * 0.4
		
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
	override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		if editingStyle == .Delete {
			// Delete the row from the data source
			tasks[indexPath.section].tasksInPriority.removeAtIndex(indexPath.row)
			tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .None)
			tableView.reloadSections(NSIndexSet(index:indexPath.section), withRowAnimation: UITableViewRowAnimation.None)
		} else if editingStyle == .Insert {
			// Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
		}
	}
		
	// MARK: Segues
	
	@IBAction func unwindToTasksTableViewController(sender: UIStoryboardSegue) {
		if let sourceViewController = sender.sourceViewController as? DisplayTaskViewController, task = sourceViewController.task, priorityIndex = sourceViewController.priorityIndex {
			if let selectedIndexPath = tableView.indexPathForSelectedRow {
				// Update an existing task.
				if selectedIndexPath.section == priorityIndex { // not changing priority
					tasks[selectedIndexPath.section].tasksInPriority[selectedIndexPath.row] = task
					tableView.reloadRowsAtIndexPaths([selectedIndexPath], withRowAnimation: .None)
				}
				
				else { // changing priority
					let newIndexPath = NSIndexPath(forRow: tasks[priorityIndex].tasksInPriority.count, inSection: priorityIndex)
					tasks[priorityIndex].tasksInPriority.append(task)
					tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Bottom)
					
					tasks[selectedIndexPath.section].tasksInPriority.removeAtIndex(selectedIndexPath.row)
					tableView.deleteRowsAtIndexPaths([selectedIndexPath], withRowAnimation: .Fade)
					
					tableView.reloadData()
				}
			} else {
				let newIndexPath = NSIndexPath(forRow: tasks[priorityIndex].tasksInPriority.count, inSection: priorityIndex)
				
				tasks[priorityIndex].tasksInPriority.append(task)
				
				tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Bottom)
				tableView.reloadData()
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
					let selectedTask = tasks[indexPath.section].tasksInPriority[indexPath.row]
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