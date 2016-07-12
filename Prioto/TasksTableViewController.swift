//
//  TaskTableViewController.swift
//  Prioto
//
//  Created by Kha Nguyen on 7/11/16.
//  Copyright © 2016 Kha. All rights reserved.
//

import UIKit

class TasksTableViewController: UITableViewController, TableViewCellDelegate {
	
	var tasks: [Priority] =
		[Priority(type: "Important | Urgent"),
		 Priority(type: "Not Important | Urgent"),
		 Priority(type: "Important | Not Urgent"),
		 Priority(type: "Not Important | Not Urgent")]
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
		tableView.backgroundColor = UIColor.whiteColor()

		
		tasks[1].addTask("Take out the trash.")
		tasks[0].addTask("Study for test")
		tasks[2].addTask("Finish todo list app")
		tasks[0].addTask("Implement priorities into todo list app")
		tasks[0].addTask("Work on college apps")
		tasks[2].addTask("Email Mr. Shuen")
		tasks[3].addTask("Catch Pokemon ")
		tasks[3].addTask("Eat a sandwich.")

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
		cell.delegate = self
		
        // Configure the cell...
		let task = tasks[indexPath.section].tasksInPriority[indexPath.row]
		cell.task = task
		
		cell.taskTextLabel.text = task.text
		cell.taskPriorityIndex = indexPath.section
		cell.taskIndex = indexPath.row

        return cell
    }
	
	
	// MARK: - Table view delegate
	
	func colorForIndexRow(row: Int, section: Int) -> UIColor {
		let itemCount = tasks.count - 1
		let val = (CGFloat(row) / CGFloat(itemCount)) * 0.75
		
		switch section {
			// important | urgent
			case 0:
				return UIColor(red: 1.0, green: val, blue: 0.0, alpha: 1.0)
			
			// not important | urgent
			case 1:
				return UIColor(red: 0.0, green: val, blue: 1.0, alpha: 1.0)

			// important | not urgent
			case 2:
				return UIColor(red: val, green: val, blue: 1.0, alpha: 1.0)

			// not important | not urgent
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
	
	func taskDeleted(task: Task, priorityIndex: Int, index: Int) {
		
		// could removeAtIndex in the loop but keep it here for when indexOfObject works
		print (tasks[priorityIndex].tasksInPriority.count)
		tasks[priorityIndex].deleteTask(index)
		print (tasks[priorityIndex].tasksInPriority.count)

		
		// use the UITableView to animate the removal of this row
		tableView.beginUpdates()
		let indexPathForRow = NSIndexPath(forRow: index, inSection: priorityIndex)
		tableView.deleteRowsAtIndexPaths([indexPathForRow], withRowAnimation: .Fade)
		tableView.endUpdates()
	}
	
	

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
