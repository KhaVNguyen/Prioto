//
//  TaskTableViewController.swift
//  Prioto
//
//  Created by Kha Nguyen on 7/11/16.
//  Copyright © 2016 Kha. All rights reserved.
//

import UIKit

class TasksTableViewController: UITableViewController {
	
	var tasks: [Priority] =
		[Priority(type: "Important | Urgent"),
		 Priority(type: "Not Important | Urgent"),
		 Priority(type: "Important | Not Urgent"),
		 Priority(type: "Not Important | Not Urgent")]
	
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



        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
//		cell.task = task
		cell.taskTextLabel.text = task.text
//		cell.taskPriorityIndex = indexPath.section
//		cell.taskIndex = indexPath.row

        return cell
    }
	
	// MARK: - Table view delegate
	
	func colorForIndexRow(row: Int, section: Int) -> UIColor {
		let itemCount = tasks.count - 1
		let val = (CGFloat(row) / CGFloat(itemCount)) * 0.4
		
		switch section {
			// important | urgent
			case 0:
				return UIColor(red: 1.0, green: val, blue: 0.0, alpha: 1.0)
			
			// not important | urgent
			case 1:
				return UIColor(red: 0.0, green: val, blue: 1.0, alpha: 1.0)

			// important | not urgent
			case 2:
				return UIColor(red: 1.0, green: val, blue: 1.0, alpha: 1.0)

			// not important | not urgent
			case 3:
				return UIColor(red: 0.0, green: 1.0, blue: val, alpha: 1.0)
			
			default:
				return UIColor(red: 1.0, green: val, blue: 0.0, alpha: 1.0)
		}
	}
	
 
	override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell,
	                        forRowAtIndexPath indexPath: NSIndexPath) {
		// self.tableView.reloadData()
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
			tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
			tableView.reloadSections(NSIndexSet(index:indexPath.section), withRowAnimation: UITableViewRowAnimation.Automatic)
		} else if editingStyle == .Insert {
			// Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
		}
	}
		
	// MARK: Segues
	
	@IBAction func unwindToTasksTableViewController(sender: UIStoryboardSegue) {
		if let sourceViewController = sender.sourceViewController as? DisplayTaskViewController, task = sourceViewController.task, priorityIndex = sourceViewController.priorityIndex {
			if let selectedIndexPath = tableView.indexPathForSelectedRow {
				// Update an existing task.
				if selectedIndexPath.section == priorityIndex {
				tasks[selectedIndexPath.section].tasksInPriority[selectedIndexPath.row] = task
				}
				
				else {
					tasks[priorityIndex].tasksInPriority.append(task)
					tasks[selectedIndexPath.section].tasksInPriority.removeAtIndex(selectedIndexPath.row)
					tableView.reloadData()
				}
				tableView.reloadRowsAtIndexPaths([selectedIndexPath], withRowAnimation: .None)
			} else {
				// Add a new meal.
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