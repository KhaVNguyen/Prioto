//
//  DisplayTaskViewController.swift
//  Prioto
//
//  Created by Kha Nguyen on 7/13/16.
//  Copyright © 2016 Kha. All rights reserved.
//

import UIKit
import AudioToolbox
import Spring
import RealmSwift
import DatePickerDialog
import PermissionScope

class DisplayTaskViewController: UIViewController {
	
	@IBOutlet weak var taskTitleTextField: UITextField!
	@IBOutlet weak var importanceSelector: UISegmentedControl!
	@IBOutlet weak var urgencySelector: UISegmentedControl!
//	@IBOutlet weak var dueDatePicker: UIDatePicker!
	
    func addDueDate() {
        let currentDate = NSDate()
        
        DatePickerDialog().show("Due Date", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", minimumDate: currentDate, datePickerMode: .DateAndTime) {
            (date) -> Void in
            if let dt = date {
                self.dueDateLabel.text = "Due Date: \(self.formatDateAsString(dt))"
                self.dueDate = dt
                self.removeDueDateButton.hidden = false
            } else {
                print("Due Date:")
            }
        }
    }
    
	@IBAction func dueDateButtonPressed(sender: AnyObject) {
		
        addDueDate()
	}
    
    
    @IBOutlet weak var removeDueDateButton: UIButton!
    
    @IBAction func removeDueDateButtonPressed(sender: AnyObject) {
        self.dueDateLabel.text = "Due Date: "
        self.dueDate = nil
        removeDueDateButton.hidden = true
    }
	
	let singlePscope = PermissionScope()
	
    
    func addReminderDate() {
        let currentDate = NSDate()
        
        DatePickerDialog().show("Reminder Date", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", minimumDate: currentDate, datePickerMode: .DateAndTime) {
            (date) -> Void in
            if let dt = date {
                self.reminderDateLabel.text = "Reminder Date: \(self.formatDateAsString(dt))"
                self.reminderDate = dt
                self.removeReminderButton.hidden = false
                self.singlePscope.show(
                    { finished, results in
                        print("got results \(results)")
                    },
                    cancelled: { results in
                        print("thing was cancelled")
                    }
                )
            } else {
                print("Reminder Date:")
            }
        }
    }
	@IBAction func remindButtonPressed(sender: AnyObject) {
		addReminderDate()
		
	}
    
    
    @IBOutlet weak var removeReminderButton: UIButton!
    
    @IBAction func removeRemindButtonPressed(sender: AnyObject) {
        self.reminderDateLabel.text = "Reminder Date: "
        self.reminderDate = nil

//        let realm = try! Realm()
//        try! realm.write {
//            task?.reminderDate = nil
//        }
        removeReminderButton.hidden = true
        
    }
	
	@IBOutlet weak var reminderDateLabel: UILabel!
    
	var reminderDate: NSDate?
	
	@IBOutlet weak var dueDateLabel: UILabel!
	var dueDate: NSDate?
	
	@IBOutlet weak var taskDetails: UITextView!
	
	@IBAction func detailsButtonPressed(sender: AnyObject) {
view.endEditing(true)
		taskDetails.becomeFirstResponder()
	}
	var priorityIndex: Int!
	var completed: Bool = false
	var timeWorked: Int!
	var previousPriorityIndex: Int!
	var task: Task?
	
	var setupPriorityCallback: (() -> Void)?
    override func viewDidLoad() {
        super.viewDidLoad()
		
		let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DisplayTaskViewController.dismissKeyboard))
        
        let tapReminderDateLabel = UITapGestureRecognizer(target: self, action: #selector(DisplayTaskViewController.addReminderDate))
        reminderDateLabel.addGestureRecognizer(tapReminderDateLabel)
        let tapDueDateLabel = UITapGestureRecognizer(target: self, action: #selector(DisplayTaskViewController.addDueDate))
        dueDateLabel.addGestureRecognizer(tapDueDateLabel)
        
        
		view.addGestureRecognizer(tap)

        // Do any additional setup after loading the view.
//		 dueDatePicker.addTarget(self, action: #selector(self.datePickerValueChanged), forControlEvents: UIControlEvents.ValueChanged)
//		dueDatePicker.minimumDate = NSDate()
		
		
		let bottomLine = CALayer()
		bottomLine.frame = CGRectMake(0.0, taskTitleTextField.frame.height - 1, taskTitleTextField.frame.width, 1.0)
		bottomLine.backgroundColor = UIColor.whiteColor().CGColor
		taskTitleTextField.borderStyle = UITextBorderStyle.None
		taskTitleTextField.layer.addSublayer(bottomLine)
		
		// set up the task details if it already exists
		if let task = task {
			taskTitleTextField.text = task.text
			if task.dueDate != nil {
//				dueDatePicker.date = task.dueDate!
				dueDateLabel.text = "Due Date: \(formatDateAsString(task.dueDate!))"
                self.dueDate = task.dueDate!
                removeDueDateButton.hidden = false
			}
            else {
                removeDueDateButton.hidden = true
            }
			if task.reminderDate != nil {
				reminderDateLabel.text = "Reminder Date: \(formatDateAsString(task.reminderDate!))"
                self.reminderDate = task.reminderDate!
                removeReminderButton.hidden = false
			}
            else {
                removeReminderButton.hidden = true
            }
			self.previousPriorityIndex = priorityIndex
			
			taskDetails.text = task.details
		}
		
		else {
			taskDetails.resignFirstResponder()
			taskTitleTextField.becomeFirstResponder()
            removeDueDateButton.hidden = true
            removeReminderButton.hidden = true
		}
		if let priorityIndex = self.priorityIndex {
			switch priorityIndex {
			case 0: // Urgent - Important
				importanceSelector.selectedSegmentIndex = 0
				urgencySelector.selectedSegmentIndex = 0
			case 1: // Urgent - Not Important
				importanceSelector.selectedSegmentIndex = 1
				urgencySelector.selectedSegmentIndex = 0
			case 2: // Not Urgent - Important
				importanceSelector.selectedSegmentIndex = 0
				urgencySelector.selectedSegmentIndex = 1
			case 3: // Not Urgent - Not Important
				importanceSelector.selectedSegmentIndex = 1
				urgencySelector.selectedSegmentIndex = 1
			default:
				importanceSelector.selectedSegmentIndex = 0
				urgencySelector.selectedSegmentIndex = 0
			}
		}
		
		singlePscope.addPermission(NotificationsPermission(notificationCategories: nil),
		                           message: "Prioto uses this to remind you \r\nabout the task you are procrastinating")
		
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
		
//		dueDateLabel.text = "Due Date:  \(formatDateAsString(dueDatePicker.date))"
//		if dueDatePicker.date < dueDatePicker.minimumDate {
//			AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
//			print("incorrect date")
//		}
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
				if let taskToBeEdited = self.task {
					let text = self.taskTitleTextField.text
					let realm = try! Realm()
					try! realm.write {
						taskToBeEdited.text = text!
						taskToBeEdited.completed = self.completed
						taskToBeEdited.details = self.taskDetails.text
						taskToBeEdited.timeWorked = self.timeWorked
						if taskToBeEdited.uuid == "" {
							taskToBeEdited.uuid = NSUUID().UUIDString
						}
						setTaskPriority(taskToBeEdited)
						}
				}
				else {
					task = Task()
					task!.text = self.taskTitleTextField.text!
					task!.completed = self.completed
					task!.details = self.taskDetails.text
					task!.timeWorked = 0
					task!.uuid = NSUUID().UUIDString
					print("UUID: \(task!.uuid)")
					setTaskPriority(task!)

				}
				
			}
		}
	}
	
	func setTaskPriority(task: Task) {
		if let dueDate = self.dueDate {
			if dueDate >= NSDate() {
				task.dueDate = dueDate
			}
		}
        
        else {
            task.dueDate = nil
        }
		
		if let reminderDate = self.reminderDate {
			print(reminderDate)
			if reminderDate >= NSDate() {
				let app:UIApplication = UIApplication.sharedApplication()
				if let scheduled = app.scheduledLocalNotifications {
					for reminder in scheduled {
						var notification = reminder as UILocalNotification
						if notification.category == task.uuid {
							//Cancelling local notification
							print("Cancelling notification with UUID: \(notification.category)")
							app.cancelLocalNotification(notification)
						}
					}
				}
				task.reminderDate = self.reminderDate
				let reminderNotification = UILocalNotification()
				let alertBody = task.text
				let alertTitle = "Prioto Task Reminder"
				reminderNotification.fireDate = task.reminderDate
				print(reminderNotification.fireDate)
				reminderNotification.alertBody = alertBody
				reminderNotification.alertTitle = alertTitle
				reminderNotification.soundName = UILocalNotificationDefaultSoundName
				reminderNotification.category = task.uuid
				
				UIApplication.sharedApplication().scheduleLocalNotification(reminderNotification)
			}
            else {
                task.reminderDate = nil
                
                let app:UIApplication = UIApplication.sharedApplication()
                if let scheduled = app.scheduledLocalNotifications {
                    for reminder in scheduled {
                        var notification = reminder as UILocalNotification
                        if let task = self.task {
                            if notification.category == task.uuid {
                                //Cancelling local notification
                                print("Cancelling notification with UUID: \(notification.category)")
                                app.cancelLocalNotification(notification)
                            }
                        }
                    }
                }
                
            }

        }
		
        else {
            task.reminderDate = nil
            
            let app:UIApplication = UIApplication.sharedApplication()
            if let scheduled = app.scheduledLocalNotifications {
                for reminder in scheduled {
                    var notification = reminder as UILocalNotification
                    if let task = self.task {
                        if notification.category == task.uuid {
                            //Cancelling local notification
                            print("Cancelling notification with UUID: \(notification.category)")
                            app.cancelLocalNotification(notification)
                        }
                    }
                }
            }

        }
        
		// Important
		if importanceSelector.selectedSegmentIndex == 0 {
			// Important - Urgent
			if urgencySelector.selectedSegmentIndex == 0 {
				task.priorityIndex = 0
				priorityIndex = 0

			}
				// Important - Not Urgent
			else if urgencySelector.selectedSegmentIndex == 1 {
				task.priorityIndex = 2
				priorityIndex = 2
			}
		}
			// Not Important
		else if importanceSelector.selectedSegmentIndex == 1 {
			if urgencySelector.selectedSegmentIndex == 0 {
				task.priorityIndex = 1
				priorityIndex = 1
			}
				// Important - Not Urgent
			else if urgencySelector.selectedSegmentIndex == 1 {
				task.priorityIndex = 3
				priorityIndex = 3
			}
		}
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
    
    @IBAction func notificationsButtonPressed(sender: AnyObject) {
        print("----------Notifications------------")
        printNotifications()
    }
    
    
    
}



