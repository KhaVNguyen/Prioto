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

class TasksTableViewController: UITableViewController{
	
	
	@IBOutlet weak var stackView: UIStackView!
	
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

	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		tableView.estimatedRowHeight = 80
		tableView.rowHeight = UITableViewAutomaticDimension
		
		realm = try! Realm()
		
		notificationToken = realm.addNotificationBlock { [unowned self] note, realm in
			self.tableView.reloadData()
		}
		
		tableView.backgroundColor = UIColor.whiteColor()
		
//		for priority in priorityIndexes {
//			let unsortedObjects = realm.objects(Task.self).filter("priorityIndex == \(priority)")
//			let sortedObjects = unsortedObjects.sorted("dateCreated", ascending: true)
//			tasksByPriority.append(sortedObjects)
//		}
		
		RealmHelper.addPriorities()
		
//		var leftButton = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("showEditing:"))
//		self.navigationItem.leftBarButtonItem = leftButton
		
		let nib = UINib(nibName: "PriorityHeaderView", bundle: nil)
		tableView.registerNib(nib, forHeaderFooterViewReuseIdentifier: "PriorityHeaderView")
		
		tableView.reloadData()
		
		// long press drag and drop gesture recognizer
		let longpress = UILongPressGestureRecognizer(target: self, action: "longPressGestureRecognized:")
		tableView.addGestureRecognizer(longpress)
	}
	
//	func showEditing(sender: UIBarButtonItem) {
//		if(self.tableView.editing == true)
//		{
//			self.tableView.editing = false
//			self.navigationItem.leftBarButtonItem?.title = "Done"
//		}
//		else
//		{
//			self.tableView.editing = true
//			self.navigationItem.leftBarButtonItem?.title = "Edit"
//		}
//	}
	
//	override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
//		if editingStyle == .Delete {
//			// Delete the row from the data source
//			RealmHelper.deleteTask(self.taskForIndexPath(indexPath)!)
//		} else if editingStyle == .Insert {
//			// Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//		}
//	}
	
	// MARK: Realm
		
	
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
				let cell = tableView.cellForRowAtIndexPath(indexPath!) as! TaskTableViewCell
				
				// collapseCellAtIndexPath(indexPath!)
				
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
					// itemsArray.insert(itemsArray.removeAtIndex(Path.initialIndexPath!.row), atIndex: indexPath!.row)
					
					let oldTask = taskForIndexPath(Path.initialIndexPath!)
					let newTask = Task(task: oldTask!, index: indexPath!.row)
					
					RealmHelper.deleteTask(oldTask!)
					try! realm.write() {
						tasksByPriority.priorities[indexPath!.section].tasks.insert(newTask, atIndex: indexPath!.row)
					}
					
					// collapseCellAtIndexPath(indexPath!)
					
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
//	override func tableView(tableView: UITableView, heightForRowAtIndexPath
//		indexPath: NSIndexPath) -> CGFloat {
//		return tableView.rowHeight
//	}
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return priorityIndexes.count
    }
	

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
		if(tasksByPriority.priorities[section].tasks.count == 0) {
//			if tasksByPriority.priorities[section].shouldNotAddPlaceholderCell  {
////				let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
////				dispatch_after(delayTime, dispatch_get_main_queue()) {
////					try! self.realm.write {
////						self.tasksByPriority.priorities[section].shouldNotAddPlaceholderCell = true
////					}
////					self.tableView.insertRowsAtIndexPaths([self.lastIdenPath], withRowAnimation: UITableViewRowAnimation.Automatic)
////				}
//				return 0
//			} else {
			
				return 1
				
//			}
		}
		else {
			return tasksByPriority.priorities[section].tasks.count
		}

    }
	
	
	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return priorityTitles[section]
	}
	
	override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		
		// Here, we use NSFetchedResultsController
		// And we simply use the section name as title
		let title = priorityTitles[section]
		
		// Dequeue with the reuse identifier
		let cell = self.tableView.dequeueReusableHeaderFooterViewWithIdentifier("PriorityHeaderView")
		let header = cell as! PriorityHeaderView
		header.priorityLabel.text = title
		
		return cell
	}
	

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		print("Section: \(indexPath.section) count is: \(tasksByPriority.priorities[indexPath.section].tasks.count)")
		if tasksByPriority.priorities[indexPath.section].tasks.count == 0 {
			let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "placeholderCell")
			//set the data here
			cell.setHeight(1.0)
			return cell
		}
		
		else {
			let cell = tableView.dequeueReusableCellWithIdentifier("taskTableViewCell", forIndexPath: indexPath) as! TaskTableViewCell
			
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
					let cell = tableView.cellForRowAtIndexPath(indexPath) as! TaskTableViewCell
					cell.changeCellStatus(false)
					cell.expanded = false
					tableView.beginUpdates()
					tableView.endUpdates()
				}
				return true
			})]
			cell.leftSwipeSettings.transition = MGSwipeTransition.Border
			cell.rightButtons = [MGSwipeButton(title: "", icon: UIImage(named:"deleteTask.png"), backgroundColor: UIColor(red: 0, green: 0, blue: 0, alpha: 0), callback: {
				(sender: MGSwipeTableCell!) -> Bool in
				let cell = tableView.cellForRowAtIndexPath(indexPath) as! TaskTableViewCell
				cell.changeCellStatus(false)
				cell.expanded = false
				tableView.beginUpdates()
				tableView.endUpdates()
				RealmHelper.deleteTask(self.taskForIndexPath(indexPath)!)
				if self.tasksByPriority.priorities[indexPath.section].tasks.count == 0 {
//					try! self.realm.write {
//						self.tasksByPriority.priorities[indexPath.section].shouldNotAddPlaceholderCell = false
//					}
					
				}
				return true
			})]
			
			self.strikethroughCompleted(indexPath, cell: cell, task: task!)
			
			cell.contentView.layer.cornerRadius = 8
			cell.contentView.layer.masksToBounds = true
			cell.layer.borderColor = UIColor.whiteColor().CGColor
			cell.layer.borderWidth = 2
			cell.layer.cornerRadius = 5
			
			cell.selectionCallback = {
				print("Cell expanded: \(cell.expanded)")
				cell.switchCellStatus()
				tableView.beginUpdates()
				tableView.endUpdates()
				print("Cell expanded: \(cell.expanded)")

			}
			
			return cell
		}
    }
	
	func collapseCellAtIndexPath(indexPath: NSIndexPath) {
		
		let cell = tableView.cellForRowAtIndexPath(indexPath) as! TaskTableViewCell
			cell.changeCellStatus(false)
			cell.expanded = false
			tableView.beginUpdates()
			tableView.endUpdates()
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