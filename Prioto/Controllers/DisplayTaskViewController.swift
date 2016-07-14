//
//  DisplayTaskViewController.swift
//  Prioto
//
//  Created by Kha Nguyen on 7/13/16.
//  Copyright © 2016 Kha. All rights reserved.
//

import UIKit

class DisplayTaskViewController: UIViewController {

	@IBOutlet weak var taskTitleTextField: UITextField!
	@IBOutlet weak var importanceSelector: UISegmentedControl!
	@IBOutlet weak var urgencySelector: UISegmentedControl!
	@IBOutlet weak var dueDatePicker: UIDatePicker!
	
	@IBOutlet weak var dueDateLabel: UILabel!
	
	var priorityIndex: Int!
	var task: Task?
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DisplayTaskViewController.dismissKeyboard))
		view.addGestureRecognizer(tap)

        // Do any additional setup after loading the view.
		 dueDatePicker.addTarget(self, action: #selector(self.datePickerValueChanged), forControlEvents: UIControlEvents.ValueChanged)
		dueDatePicker.minimumDate = NSDate()
		
		// set up the task details if it already exists
		if let task = task {
			taskTitleTextField.text = task.text
			if task.dueDate != nil {
				dueDatePicker.date = task.dueDate!
				dueDateLabel.text = "Due Date: \(formatDateAsString(task.dueDate!))"
			}
			switch priorityIndex {
			case 0: // Urgent - Important
				importanceSelector.selectedSegmentIndex = 0
				urgencySelector.selectedSegmentIndex = 0
			case 1: // Urgent - Not Important
				importanceSelector.selectedSegmentIndex = 0
				urgencySelector.selectedSegmentIndex = 1
			case 2: // Not Urgent - Important
				importanceSelector.selectedSegmentIndex = 1
				urgencySelector.selectedSegmentIndex = 0
			case 3: // Not Urgent - Not Important
				importanceSelector.selectedSegmentIndex = 1
				urgencySelector.selectedSegmentIndex = 1
			default:
				importanceSelector.selectedSegmentIndex = 0
				urgencySelector.selectedSegmentIndex = 0
			}
			
		}
    }
	
	//Calls this function when the tap is recognized.
	func dismissKeyboard() {
		//Causes the view (or one of its embedded text fields) to resign the first responder status.
		view.endEditing(true)
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		// 1
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	func datePickerValueChanged(sender:UIDatePicker) {
		
		dueDateLabel.text = "Due Date:  \(formatDateAsString(dueDatePicker.date))"
	}
	
	func formatDateAsString(date: NSDate) -> String {
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
		dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
		
		let strDate = dateFormatter.stringFromDate(date)
		return strDate
	}
	

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
	
	// MARK: - Segue
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if let identifier = segue.identifier {
			if identifier == "Save" {
				let text = self.taskTitleTextField.text
				task = Task(text: text ?? "")
				setTaskDetails(task!)
			}
		}
	}
//			if identifier == "Save" {
//				let tasksTableViewController = segue.destinationViewController as! TasksTableViewController
//
//				if let existingTask = self.task { // task exists
//					setTaskDetails(existingTask)
//					existingTask.text = taskTitleTextField.text ?? ""
//				}
//				
//				else { // task does not exist
//					task = Task(text: taskTitleTextField.text ?? "")
//					setTaskDetails(task!) // assigns priority to task
//					tasksTableViewController.tasks[priorityIndex].tasksInPriority.append(task!)
//				}
//				tasksTableViewController.tableView.reloadData()
//			}
	
	func setTaskDetails(task: Task) {
//		if dueDatePicker.date != NSDate() {
//			task.dueDate = dueDatePicker.date
//		}
		
		task.dueDate = dueDatePicker.date
		
		// Important
		if importanceSelector.selectedSegmentIndex == 0 {
			// Important - Urgent
			if urgencySelector.selectedSegmentIndex == 0 {
				priorityIndex = 0
			}
				// Important - Not Urgent
			else if urgencySelector.selectedSegmentIndex == 1 {
				priorityIndex = 2
			}
		}
			// Not Important
		else if importanceSelector.selectedSegmentIndex == 1 {
			if urgencySelector.selectedSegmentIndex == 0 {
				priorityIndex = 1
			}
				// Important - Not Urgent
			else if urgencySelector.selectedSegmentIndex == 1 {
				priorityIndex = 3
			}
		}
	}

}
