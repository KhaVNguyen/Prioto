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
import AudioToolbox
import Spring
import SwiftyUserDefaults
import ChameleonFramework
import PopupDialog


class TasksTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	
	@IBOutlet var tasksTableView: TasksTableView!
	
	@IBAction func fillButtonTapped(sender: AnyObject) {
		RealmHelper.addTask(Task(text: "Complete feature to reorder tasks", priority: 0))
		RealmHelper.addTask(Task(text: "User test app", priority: 0))
		RealmHelper.addTask(Task(text: "Email Mr. Shuen / other instructor", priority: 0))
		RealmHelper.addTask(Task(text: "Integrate time and tasks", priority: 0))
		
		RealmHelper.addTask(Task(text: "Answer emails", priority: 1))
		RealmHelper.addTask(Task(text: "Share app with mom", priority: 1))
		
		RealmHelper.addTask(Task(text: "Go to the gym", priority: 2))
		RealmHelper.addTask(Task(text: "Call grandma", priority: 2))
		RealmHelper.addTask(Task(text: "Research productivity", priority: 2))
		RealmHelper.addTask(Task(text: "Think of long - term marketing strategy", priority: 2))
		
		RealmHelper.addTask(Task(text: "Watch TV", priority: 3))
		RealmHelper.addTask(Task(text: "Play Pokemon GO", priority: 3))
		RealmHelper.addTask(Task(text: "Watch YouTube videos", priority: 3))
		
		RealmHelper.getTaskTitles()
		
		//		taskExpanded = [[], [], [], []]
		//		let realm = try! Realm()
		//		let tasksByPriority = realm.objects(TasksByPriority.self).first!
		//		let priorities = tasksByPriority.priorities
		//		var section = 0
		//		for priority in priorities {
		//			for task in priority.tasks {
		//				taskExpanded[section].append(false)
		//			}
		//			section += 1
		//		}
		
	}
	
	@IBAction func printExpandedButtonTapped(sender: AnyObject) {
		//		print("---------------------------------------------------")
		//		for priority in taskExpanded {
		//			print(priority)
		//		}
		let realm = try! Realm()
		let tasksByPriority = realm.objects(TasksByPriority.self).first!
		let priorities = tasksByPriority.priorities
		var section = 0
		
		for priority in priorities {
			for task in priority.tasks {
				print(String(task.isBeingWorkedOn) + ": " + task.text)
			}
			section += 1
		}
		
	}
	var realm: Realm!
	var notificationToken: NotificationToken?
	var priorityIndexes = [0, 1, 2, 3]
	var priorityTitles = ["Urgent | Important", "Urgent | Not Important", "Not Urgent | Important", "Not Urgent | Not Important"]
	
	let tasksByPriority: TasksByPriority = {
		// Get the singleton GroupParent() object from the Realm, creating it
		// if needed. In a more complete example with more than one view, this
		// would be supplied as the data source by whatever is displaying this
		// table view
		
		let config = Realm.Configuration(
			// Set the new schema version. This must be greater than the previously used
			// version (if you've never set a schema version before, the version is 0).
			schemaVersion: 2,
			
			// Set the block which will be called automatically when opening a Realm with
			// a schema version lower than the one set above
			migrationBlock: { migration, oldSchemaVersion in
    // We haven’t migrated anything yet, so oldSchemaVersion == 0
    if (oldSchemaVersion < 2) {
		// Nothing to do!
		// Realm will automatically detect new properties and removed properties
		// And will update the schema on disk automatically
    }
  })
		
		// Tell Realm to use this new configuration object for the default Realm
		Realm.Configuration.defaultConfiguration = config
		
		// Now that we've told Realm how to handle the schema change, opening the file
		// will automatically perform the migration
		let realm = try! Realm()

		let obj = realm.objects(TasksByPriority.self).first
		if obj != nil {
			return obj!
		}
		
		let newObj = TasksByPriority()
		try! realm.write { realm.add(newObj) }
		return newObj
	}()
	
	var currentIndexPath: NSIndexPath?
	var selectedIndexPath : NSIndexPath!
	
	//	var taskExpanded: [[Bool]] = [[],[],[],[]]
	//	var initialLoaded: Bool = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		storyboard.instantiateViewControllerWithIdentifier("NewFocusViewController")
		
		
		self.realm = try! Realm()
		
		notificationToken = realm.addNotificationBlock { [unowned self] note, realm in
			self.tasksTableView.reloadData()
			// print("Realm array changed")
		}
		
		
		RealmHelper.addPriorities()
		
		tasksTableView.backgroundColor = UIColor(hexString: "#202030")
		//		tasksTableView.estimatedRowHeight = CGFloat(50)
		//		tasksTableView.rowHeight = UITableViewAutomaticDimension
		tasksTableView.rowHeight = 55
		
		tasksTableView.layoutMargins = UIEdgeInsetsZero
		tasksTableView.separatorInset = UIEdgeInsetsZero
		
		tasksTableView.delegate = self
		tasksTableView.dataSource = self
		tasksTableView.tableFooterView = UIView()
		
		tasksTableView.setRearrangeOptions([.hover], dataSource: self)
		
		let nib = UINib(nibName: "PriorityHeaderView", bundle: nil)
		tasksTableView.registerNib(nib, forHeaderFooterViewReuseIdentifier: "PriorityHeaderView")
		
		
		//		let tasksByPriority = realm.objects(TasksByPriority.self).first!
		//		let priorities = tasksByPriority.priorities
		//		var section = 0
		//		for priority in priorities {
		//			for task in priority.tasks {
		//				taskExpanded[section].append(false)
		//			}
		//			section += 1
		//		}
		//		print("Task expanded:")
		//		print(taskExpanded)
		
		tasksTableView.reloadData()
		//		initialLoaded = true
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TasksTableViewController.resetAllWorkingOn), name: "appClosed", object: nil)
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	//  MARK: - Table view data source
	
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		// #warning Incomplete implementation, return the number of sections
		
		return priorityIndexes.count
	}
	
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		// #warning Incomplete implementation, return the number of rows
		
		
		if(tasksByPriority.priorities[section].tasks.count == 0) {
			return 1
		}
		else {
			return tasksByPriority.priorities[section].tasks.count
		}
		
	}
	
	
	//	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
	//		// return priorityTitles[section]
	//		switch section {
	//		case 0:
	//			return "Section 0"
	//		case 1:
	//			return "Section 1"
	//		case 2:
	//			return "Section 2"
	//		default:
	//			return "Unknown"
	//		}
	//
	//	}
	
	var sectionTaskWillBeAddedTo: Int?
	
	func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		
		// Here, we use NSFetchedResultsController
		// And we simply use the section name as title
		let title = priorityTitles[section]
		
		// Dequeue with the reuse identifier
		let cell = self.tasksTableView.dequeueReusableHeaderFooterViewWithIdentifier("PriorityHeaderView")
		let header = cell as! PriorityHeaderView
		header.priorityLabel.text = title
		header.addTaskToSectionCallback = {
			self.sectionTaskWillBeAddedTo = section
			self.performSegueWithIdentifier("addNewTaskSegue", sender: self)
		}
		
		return cell
	}
	
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		if tasksByPriority.priorities[indexPath.section].tasks.count == 0 {
			//			let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "placeholderCell")
			let cell = tasksTableView.dequeueReusableCellWithIdentifier("placeholderCell", forIndexPath: indexPath) as! PlaceholderTableViewCell
			//set the data here
			cell.userInteractionEnabled = false
			cell.placeholderLabel.setTitle("No tasks in this section.", forState: .Normal)
						
			cell.layer.cornerRadius = 15
			cell.layer.masksToBounds = true
			cell.layer.borderWidth = 15
			cell.layer.borderColor = UIColor(hexString: "#202030").CGColor
			
			return cell
		}
			
		else {
			let cell = tasksTableView.dequeueReusableCellWithIdentifier("taskTableViewCell", forIndexPath: indexPath) as! TaskTableViewCell
			
			//			if taskExpanded[indexPath.section][indexPath.row] {
			//				expandCellAtIndexPath(indexPath)
			//			}
			//			else if !taskExpanded[indexPath.section][indexPath.row] {
			//				collapseCellAtIndexPath(indexPath)
			//			}
			//			else {
			//				print("************************************Something isn't right...**************************************")
			//			}
			
			// Configure the cell...
			let task = self.taskForIndexPath(indexPath)
			
			//configure left buttons
			cell.leftButtons = [MGSwipeButton(title: "", icon: UIImage(named:"completeTask.png"), backgroundColor: UIColor(red: 0, green: 0, blue: 0, alpha: 0), callback: {
				(sender: MGSwipeTableCell!) -> Bool in
				let realm = try! Realm()
				try! self.realm.write() {
					let task = self.taskForIndexPath(indexPath)
					self.taskForIndexPath(indexPath)?.completed = !(self.taskForIndexPath(indexPath)?.completed)!
					AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
					self.strikethroughCompleted(indexPath, cell: cell, task: task!)
					//					if self.expandedForIndexPath(indexPath) {
					//						self.collapseCellAtIndexPath(indexPath)
					//					}
				}
				RealmHelper.getTaskTitles()
				return true
			})]
			cell.leftSwipeSettings.transition = MGSwipeTransition.Border
            cell.leftExpansion.buttonIndex = 0
			cell.rightButtons = [MGSwipeButton(title: "", icon: UIImage(named:"deleteTask.png"), backgroundColor: UIColor(red: 0, green: 0, blue: 0, alpha: 0), callback: {
				(sender: MGSwipeTableCell!) -> Bool in
				//	if self.expandedForIndexPath(indexPath) {
 			//	}
				// self.tasksTableView.reloadData()
				//				self.taskExpanded[indexPath.section].removeAtIndex(indexPath.row)
				var app:UIApplication = UIApplication.sharedApplication()
				if let scheduled = app.scheduledLocalNotifications {
					for reminder in scheduled {
						var notification = reminder as UILocalNotification
						if notification.category == task!.uuid {
							//Cancelling local notification
							print("Cancelling notification with UUID: \(notification.category)")
							app.cancelLocalNotification(notification)
						}
					}
				}
				RealmHelper.deleteTask(self.taskForIndexPath(indexPath)!)
				// self.tasksTableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: UITableViewRowAnimation.Automatic)
				self.tasksTableView.reloadData()
				RealmHelper.getTaskTitles()
				
				//				for priority in self.taskExpanded {
				//					print(priority)
				//				}
				return true
			})]
			
            cell.rightSwipeSettings.transition = MGSwipeTransition.Border
            cell.rightExpansion.buttonIndex = 0
			
			cell.layer.cornerRadius = 8
			cell.layer.masksToBounds = true
			cell.layer.borderWidth = 5
			cell.layer.borderColor = UIColor(hexString: "#202030").CGColor

			
			
			
			
			//			if indexPath == currentIndexPath {
			//
			//				cell.backgroundColor = nil
			//			}
			//			else {
			//
			strikethroughCompleted(indexPath, cell: cell, task: task!)
			//			}
			
			//			cell.selectionCallback = {
			//				if self.expandedForIndexPath(indexPath) {
			//					self.collapseCellAtIndexPath(indexPath)
			//				}
			//				else if !self.expandedForIndexPath(indexPath) {
			//					self.expandCellAtIndexPath(indexPath)
			//				}
			//
			//			}
			
			cell.timeTaskCallBack = {
				let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
				if let tabBarController = appDelegate.window!.rootViewController as? UITabBarController {
					tabBarController.selectedIndex = 1
				}
				let taskDataDict:[String: Task] = ["task": task!]
				NSNotificationCenter.defaultCenter().postNotificationName("taskChosen", object: self, userInfo: taskDataDict)
				
			}
			
			//			if indexPath == currentIndexPath {
			//				cell.backgroundColor = UIColor.whiteColor()
			//				self.tasksTableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
			//			}
			//			else {
			//				strikethroughCompleted(indexPath, cell: cell, task: task!)
			//			}
			//
			//			cell.separatorInset = UIEdgeInsetsZero
			//			cell.layoutMargins = UIEdgeInsetsZero
			//			cell.timeElapsedLabel.text = self.formatSecondsAsTimeString(Double((task?.timeWorked)!))
			
			
			//			if task!.isBeingWorkedOn {
			//				cell.startAnimation()
			//				print("animating")
			//			}
			//			else {
			//				cell.stopAnimation()
			//			}
			
			if !task!.isBeingWorkedOn {
				cell.stopAnimation()
			}
				
			else if task!.isBeingWorkedOn {
				cell.startAnimation()
			}
			
			return cell
		}
		
	}
	
	//	func collapseCellAtIndexPath(indexPath: NSIndexPath) {
	//
	//		if let cell = tasksTableView.cellForRowAtIndexPath(indexPath) as? TaskTableViewCell{
	//			self.tasksTableView.beginUpdates()
	//			cell.changeCellStatus(true)
	//			self.tasksTableView.endUpdates()
	//			self.tasksTableView.beginUpdates()
	//			cell.changeCellStatus(false)
	//			self.tasksTableView.endUpdates()
	//			taskExpanded[indexPath.section][indexPath.row] = true
	//			taskExpanded[indexPath.section][indexPath.row] = false
	////			self.tasksTableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
	//			print("---------------------------------------------------")
	//			for priority in taskExpanded {
	//				print(priority)
	//			}
	//		}
	//	}
	//
	//	func expandCellAtIndexPath(indexPath: NSIndexPath) {
	//
	//		if let cell = tasksTableView.cellForRowAtIndexPath(indexPath) as? TaskTableViewCell{
	//			self.tasksTableView.beginUpdates()
	//			cell.changeCellStatus(false)
	//			self.tasksTableView.endUpdates()
	//			self.tasksTableView.beginUpdates()
	//			cell.changeCellStatus(true)
	//			self.tasksTableView.endUpdates()
	//			taskExpanded[indexPath.section][indexPath.row] = false
	//			taskExpanded[indexPath.section][indexPath.row] = true
	////			self.tasksTableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
	//			print("---------------------------------------------------")
	//			for priority in taskExpanded {
	//				print(priority)
	//			}
	//		}
	//	}
	
	// Get the Task at a given index path
	func taskForIndexPath(indexPath: NSIndexPath) -> Task? {
		return tasksByPriority.priorities[indexPath.section].tasks[indexPath.row]
	}
	
	//	func expandedForIndexPath(indexPath: NSIndexPath) -> Bool {
	//		return taskExpanded[indexPath.section][indexPath.row]
	//	}
	
	
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
		
		let itemCount = tasksByPriority.priorities[section].tasks.count
       
		var val = (CGFloat(row) / CGFloat(itemCount)) * 0.5
        
        if tasksByPriority.priorities[section].tasks.count == 0 { // placeholder
            val = 0
        }
		
		switch section {
		// urgent | important
		case 0:
			return UIColor(red: 190.0 / 255, green: val, blue: 50.0 / 255, alpha: 1.0)
			
		// urgent | not important
		case 1:
			return UIColor(red: 30.0 / 255, green: val, blue: 200.0 / 255, alpha: 1.0)
			
		// not urgent | important
		case 2:
			return UIColor(red: 60.0 / 255 + val, green: 60.0 / 255, blue: 115.0 / 255 , alpha: 1.0)
			
		// not urgent | not important
		case 3:
			return UIColor(red: 15.0 / 255 , green: 125.0 / 255 + val, blue: 125.0 / 255, alpha: 1.0)
			
		default:
			return UIColor(red: 1.0, green: val, blue: 0.0, alpha: 1.0)
		}
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		
		self.selectedIndexPath = indexPath
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		//		print("Old task expanded: \(taskExpanded[selectedIndexPath.section][selectedIndexPath.row]) ")
		
		self.performSegueWithIdentifier("editTaskDetailsSegue", sender: self)
	}
 
	func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell,
	               forRowAtIndexPath indexPath: NSIndexPath) {
		cell.backgroundColor = colorForIndexRow(indexPath.row, section: indexPath.section)
	}
	
	func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
		
		if let taskTableViewCell = cell as? TaskTableViewCell {
			//			taskTableViewCell.selectionCallback = nil
			//			taskTableViewCell.timeTaskCallBack = nil
			//			if expandedForIndexPath(indexPath) {
			//				collapseCellAtIndexPath(indexPath)
			//				taskExpanded[indexPath.section][indexPath.row] = false
			//			}
		}
		//		print("Did end displaying")
	}
	
	// Override to support conditional editing of the table view.
	func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		// Return false if you do not want the specified item to be editable.
		return true
	}
	
	
	// MARK: Segues
	
	@IBAction func unwindToTasksTableViewController(sender: UIStoryboardSegue) {
		if let sourceViewController = sender.sourceViewController as? DisplayTaskViewController, task = sourceViewController.task, priorityIndex = sourceViewController.priorityIndex {
			if let selectedIndexPath = self.selectedIndexPath {
				// Update an existing task.
				if selectedIndexPath.section == priorityIndex { // not changing priority
					RealmHelper.updateTask(taskForIndexPath(selectedIndexPath)!, newTask: task)
					// tasksTableView.reloadData()
					if task.isBeingWorkedOn {
						let taskDataDict:[String: Task] = ["task": task]
						NSNotificationCenter.defaultCenter().postNotificationName("taskChosen", object: self, userInfo: taskDataDict)
					}
				}
					
				else { // changing priority
					//		if expandedForIndexPath(selectedIndexPath) {
					//						collapseCellAtIndexPath(selectedIndexPath)
					//		}
					let newTask = Task(task: task)
					RealmHelper.addTask(newTask)
					if task.isBeingWorkedOn { // if task from old priority is being worked on, set the new one to also be timed
						let taskDataDict:[String: Task] = ["task": newTask]
						NSNotificationCenter.defaultCenter().postNotificationName("taskChosen", object: self, userInfo: taskDataDict)
					}
					
					
					//let oldTaskExpanded = expandedForIndexPath(selectedIndexPath)
					//print("Old task expanded: \(oldTaskExpanded)")
					//taskExpanded[priorityIndex].append(oldTaskExpanded)
					
					
					RealmHelper.deleteTask(taskForIndexPath(selectedIndexPath)!)
					//taskExpanded[selectedIndexPath.section].removeAtIndex(selectedIndexPath.row)
					
					// tasksTableView.reloadData()
				}
				self.selectedIndexPath = nil
				
			}
			else {
				RealmHelper.addTask(task)
				//taskExpanded[priorityIndex].append(false)
				
				// tasksTableView.reloadData()
			}
		}
		
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if let identifier = segue.identifier {
			
			if identifier == "editTaskDetailsSegue" {
				print("Selected index path: \(selectedIndexPath.section), \(selectedIndexPath.row)")
				
				let displayTaskViewController = (segue.destinationViewController as! UINavigationController).viewControllers[0] as! DisplayTaskViewController
				
				// set task of DisplayTaskViewController to task tapped on
				//				if let selectedTaskCell = sender as? TaskTableViewCell {
				let selectedTask = taskForIndexPath(self.selectedIndexPath)
				displayTaskViewController.task = selectedTask
				displayTaskViewController.priorityIndex = self.selectedIndexPath.section
				displayTaskViewController.completed = (selectedTask?.completed)!
				displayTaskViewController.timeWorked = (selectedTask?.timeWorked)!
				
				//				}
			}
				
			else if identifier == "addNewTaskSegue" {
				if let section = self.sectionTaskWillBeAddedTo {
					let displayTaskViewController = (segue.destinationViewController as! UINavigationController).viewControllers[0] as! DisplayTaskViewController
					displayTaskViewController.priorityIndex = section
					self.sectionTaskWillBeAddedTo = nil
				}
			}
		}
	}
	
	// MARK: Timer integration
	
	func formatSecondsAsTimeString(time: Double) -> String {
		let hours = Int(round(time)) / 3600
		let minutes = Int(round(time)) / 60 % 60
		let seconds = Int(round(time)) % 60
		return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
	}
	
	func resetAllWorkingOn() {
		let realm = try! Realm()
		let tasksByPriority = realm.objects(TasksByPriority.self).first!
		let priorities = tasksByPriority.priorities
		var section = 0
		for priority in priorities {
			for task in priority.tasks {
				try! realm.write() {
					task.isBeingWorkedOn = false
				}
			}
			section += 1
		}
		tasksTableView.reloadData()
	}
    
    @IBAction func infoButtonTapped(sender: AnyObject) {
        showEisenhowerInfo()
    }
    
    func showEisenhowerInfo() {
        
        // Prepare the popup assets
        let title = "Not all tasks are created equal."
        let message = "Utilize the Eisenhower method to carefully allocate valuable time and energy to the tasks that actually matter.  Assign a priority to each of your tasks, based on urgency and importance"
        let image = UIImage(named: "Eisenhower")
        
        // Create the dialog
        let popup = PopupDialog(title: title, message: message, image: image)
        
        // Create first button
        let buttonOne = CancelButton(title: "Okay") {
        }
        
        // Add buttons to dialog
        popup.addButtons([buttonOne])
        
        // Present dialog
        self.presentViewController(popup, animated: true, completion: nil)
    }
    
    func printNotifications() {
        let app:UIApplication = UIApplication.sharedApplication()
        if let scheduled = app.scheduledLocalNotifications {
            for reminder in scheduled {
                var notification = reminder as UILocalNotification
                print(notification.category)
            }
        }
    }
    
    
    @IBAction func printNotificationsButton(sender: AnyObject) {
        print("----------Notifications------------")
        printNotifications()
    }

	
}

extension TasksTableViewController: RearrangeDataSource {
	
	func moveObjectAtCurrentIndexPath(to indexPath: NSIndexPath) {
		
		guard let unwrappedCurrentIndexPath = currentIndexPath else { return }
		//		if let cell = tasksTableView.cellForRowAtIndexPath(unwrappedCurrentIndexPath) as? TaskTableViewCell{
		//				collapseCellAtIndexPath(unwrappedCurrentIndexPath)
		//		}
		
		let oldTask = taskForIndexPath(unwrappedCurrentIndexPath)
		var makeNewTaskActive = false
		if oldTask!.isBeingWorkedOn {
			makeNewTaskActive = true
		}
		
		let newTask = Task(task: oldTask!, index: indexPath.row)
		let realm = try! Realm()
		RealmHelper.deleteTask(oldTask!)
		//taskExpanded[unwrappedCurrentIndexPath.section].removeAtIndex(unwrappedCurrentIndexPath.row)
		try! realm.write() {
			tasksByPriority.priorities[indexPath.section].tasks.insert(newTask, atIndex: indexPath.row)
		}
		try! realm.write() {
			newTask.priorityIndex = indexPath.section
		}
		//		if let cell = tasksTableView.cellForRowAtIndexPath(indexPath) as? TaskTableViewCell{
		//			collapseCellAtIndexPath(indexPath)
		//		}
		//taskExpanded[indexPath.section].insert(false, atIndex: indexPath.row)
		
		if makeNewTaskActive {
			let taskDataDict:[String: Task] = ["task": newTask]
			NSNotificationCenter.defaultCenter().postNotificationName("taskChosen", object: self, userInfo: taskDataDict)
		}
		
	}
}