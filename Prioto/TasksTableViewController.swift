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
import AudioToolbox

class Task: Object {
	dynamic var text: String = ""
	dynamic var details: String = ""
	dynamic var completed: Bool = false
	dynamic var dueDate: NSDate? = nil
	dynamic var priorityIndex: Int = 0
	dynamic var dateCreated = NSDate()
	
	convenience init(text: String) {
		self.init()
		self.text = text
	}
	
	convenience init(text: String, priority: Int) {
		self.init()
		self.text = text
		self.priorityIndex = priority
	}
	
	convenience init(task: Task, index: Int) {
		self.init()
		self.text = task.text
		self.priorityIndex = index
		self.details = task.details
		self.completed = task.completed
		self.dueDate = task.dueDate
		self.dateCreated = task.dateCreated
	}
}

class Priority: Object {
	dynamic var name = ""
	dynamic var shouldNotAddPlaceholderCell = false
	let tasks = List<Task>()
}

class TasksByPriority: Object {
	let priorities = List<Priority>()
}

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

	}
	
	
	@IBAction func deleteAllButtonTapped(sender: AnyObject) {
		
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
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		realm = try! Realm()
		
		notificationToken = realm.addNotificationBlock { [unowned self] note, realm in
			self.tasksTableView.reloadData()
		}
		
		
		RealmHelper.addPriorities()
		
		tasksTableView.backgroundColor = UIColor.grayColor()
//		tasksTableView.estimatedRowHeight = CGFloat(90)
		tasksTableView.rowHeight = UITableViewAutomaticDimension
//		tasksTableView.rowHeight = 90
		
		tasksTableView.layoutMargins = UIEdgeInsetsZero
		tasksTableView.separatorInset = UIEdgeInsetsZero
		
		tasksTableView.delegate = self
		tasksTableView.dataSource = self
		tasksTableView.tableFooterView = UIView()
		
		tasksTableView.setRearrangeOptions([.hover], dataSource: self)
		
		let nib = UINib(nibName: "PriorityHeaderView", bundle: nil)
		tasksTableView.registerNib(nib, forHeaderFooterViewReuseIdentifier: "PriorityHeaderView")
		
		tasksTableView.reloadData()
		
}
	
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

   //  MARK: - Table view data source
	
	func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return CGFloat(90)
	}
	
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
	
	
	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		// return priorityTitles[section]
		switch section {
		case 0:
			return "Section 0"
		case 1:
			return "Section 1"
		case 2:
			return "Section 2"
		default:
			return "Unknown"
		}

	}
	
	func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		
		// Here, we use NSFetchedResultsController
		// And we simply use the section name as title
		let title = priorityTitles[section]
		
		// Dequeue with the reuse identifier
		let cell = self.tasksTableView.dequeueReusableHeaderFooterViewWithIdentifier("PriorityHeaderView")
		let header = cell as! PriorityHeaderView
		header.priorityLabel.text = title
		
		return cell
	}
	

     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		if tasksByPriority.priorities[indexPath.section].tasks.count == 0 {
			let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "placeholderCell")
			//set the data here
			cell.setHeight(1.0)
			return cell
		}
		
		else {
			let cell = tasksTableView.dequeueReusableCellWithIdentifier("taskTableViewCell", forIndexPath: indexPath) as! TaskTableViewCell
			
			// Configure the cell...
			let task = self.taskForIndexPath(indexPath)
			
			//configure left buttons
			cell.leftButtons = [MGSwipeButton(title: "", icon: UIImage(named:"completeTask.png"), backgroundColor: UIColor(red: 0, green: 0, blue: 0, alpha: 0), callback: {
				(sender: MGSwipeTableCell!) -> Bool in
				try! self.realm.write() {
					let task = self.taskForIndexPath(indexPath)
					self.taskForIndexPath(indexPath)?.completed = !(self.taskForIndexPath(indexPath)?.completed)!
					AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
					self.strikethroughCompleted(indexPath, cell: cell, task: task!)
					self.collapseCellAtIndexPath(indexPath)
				}
				return true
			})]
			cell.leftSwipeSettings.transition = MGSwipeTransition.Border
			cell.rightButtons = [MGSwipeButton(title: "", icon: UIImage(named:"deleteTask.png"), backgroundColor: UIColor(red: 0, green: 0, blue: 0, alpha: 0), callback: {
				(sender: MGSwipeTableCell!) -> Bool in
				self.collapseCellAtIndexPath(indexPath)
				RealmHelper.deleteTask(self.taskForIndexPath(indexPath)!)
				return true
			})]
			
			self.strikethroughCompleted(indexPath, cell: cell, task: task!)
			
			cell.contentView.layer.cornerRadius = 8
			cell.contentView.layer.masksToBounds = true
			cell.layer.borderColor = UIColor.whiteColor().CGColor
			cell.layer.borderWidth = 2
			cell.layer.cornerRadius = 5
			
			cell.selectionCallback = {
				//print("Cell expanded: \(cell.expanded)")
				self.tasksTableView.beginUpdates()
				cell.switchCellStatus()
				self.tasksTableView.endUpdates()
				//print("Cell expanded: \(cell.expanded)")
			}
			
//			if indexPath == currentIndexPath {
//				
//				cell.backgroundColor = nil
//			}
//			else {
//				
//				cell.textLabel?.text = taskForIndexPath(indexPath)!.text
//			}
//			
//			cell.separatorInset = UIEdgeInsetsZero
//			cell.layoutMargins = UIEdgeInsetsZero
			
			return cell
		}

    }
	
	func collapseCellAtIndexPath(indexPath: NSIndexPath) {
		
		if let cell = tasksTableView.cellForRowAtIndexPath(indexPath) as? TaskTableViewCell{
			self.tasksTableView.beginUpdates()
			cell.changeCellStatus(true)
			cell.changeCellStatus(false)
			self.tasksTableView.endUpdates()
		}
		
	}
	
	// Get the Task at a given index path
	func taskForIndexPath(indexPath: NSIndexPath) -> Task? {
		return tasksByPriority.priorities[indexPath.section].tasks[indexPath.row]
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
		let itemCount = tasksByPriority.priorities[section].tasks.count - 1
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
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}
 
	func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell,
	                        forRowAtIndexPath indexPath: NSIndexPath) {
		cell.backgroundColor = colorForIndexRow(indexPath.row, section: indexPath.section)
	}
	
	// Override to support conditional editing of the table view.
	func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		// Return false if you do not want the specified item to be editable.
		return true
	}
	
	
	// MARK: Segues
	
	@IBAction func unwindToTasksTableViewController(sender: UIStoryboardSegue) {
		if let sourceViewController = sender.sourceViewController as? DisplayTaskViewController, task = sourceViewController.task, priorityIndex = sourceViewController.priorityIndex {
			if let selectedIndexPath = tasksTableView.indexPathForSelectedRow {
				// Update an existing task.
				if selectedIndexPath.section == priorityIndex { // not changing priority
					RealmHelper.updateTask(taskForIndexPath(selectedIndexPath)!, newTask: task)
				}
				
				else { // changing priority
					collapseCellAtIndexPath(selectedIndexPath)
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
					let indexPath = tasksTableView.indexPathForCell(selectedTaskCell)!
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

extension TasksTableViewController: RearrangeDataSource {
	
	func moveObjectAtCurrentIndexPath(to indexPath: NSIndexPath) {
		
		guard let unwrappedCurrentIndexPath = currentIndexPath else { return }
		
		let oldTask = taskForIndexPath(unwrappedCurrentIndexPath)
		collapseCellAtIndexPath(unwrappedCurrentIndexPath)
		collapseCellAtIndexPath(indexPath)
		
		let newTask = Task(task: oldTask!, index: indexPath.row)
		
		RealmHelper.deleteTask(oldTask!)
		try! realm.write() {
			tasksByPriority.priorities[indexPath.section].tasks.insert(newTask, atIndex: indexPath.row)
		}
		
		
	}
}