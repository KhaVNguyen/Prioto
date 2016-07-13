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
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		 dueDatePicker.addTarget(self, action: #selector(self.datePickerValueChanged), forControlEvents: UIControlEvents.ValueChanged)
		dueDatePicker.minimumDate = NSDate()
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
		
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
		dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
		
		let strDate = dateFormatter.stringFromDate(dueDatePicker.date)
		
		dueDateLabel.text = "Due Date:  \(strDate)"
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
			if identifier == "Cancel" {
				
			}
			else if identifier == "Save" {
				let task = Task(text: taskTitleTextField.text ?? "")
				if dueDatePicker.date != NSDate() {
					task.dueDate = dueDatePicker.date
				}
				
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
				
				let tasksTableViewController = segue.destinationViewController as! TasksTableViewController
				tasksTableViewController.tasks[priorityIndex].tasksInPriority.append(task)
				tasksTableViewController.tableView.reloadData()
			}
		}
	}

}
