//
//  NewFocusViewController.swift
//  Prioto
//
//  Created by Kha Nguyen on 7/20/16.
//  Copyright © 2016 Kha. All rights reserved.

import Foundation
import UIKit
import SwiftyTimer
import ConcentricProgressRingView
import LionheartExtensions
import SwiftyUserDefaults
import BSForegroundNotification
import AudioToolbox
import AZDropdownMenu
import RealmSwift
import UIColor_Hex_Swift
import PopupDialog
import Device_swift
import PermissionScope

var newFocusViewControllerLoaded: Bool = false
var timerInterrupted: Bool = false

class NewFocusViewController: UIViewController, BSForegroundNotificationDelegate {
	
	enum TimerType : String {
		case Work = "Work"
		case Break = "Break"
	}
	
	@IBOutlet weak var timeLeftLabel: UILabel!
	
  var progressRingView: ConcentricProgressRingView!

	
	@IBOutlet weak var timerView: UIView!
	
	@IBOutlet weak var typeLabel: UILabel!
	
	var timer: NSTimer!
	var timeRemaining: Double!
	var timeMax: Double!
	
	var breakTimeMax: Int = 300
	var workTimeMax: Int = 1500
	
	var counting: Bool = false
	
	var timerType: TimerType!
	var typeName: String!
	
	var localNotification: UILocalNotification?
	var localNotificationEndDate: NSDate!
	var willDisplayForegroundNotification: Bool = true
	
	lazy var tasksByPriority: TasksByPriority = {
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
	
	@IBOutlet weak var startPauseButton: UIButton!
	
	@IBOutlet weak var restartButton: UIButton!
	
	@IBAction func startPauseButtonPressed(sender: AnyObject) {
		if self.counting {
			pauseTimer()

		}
		else {
			startTimer()
			singlePscope.show(
				{ finished, results in
					print("got results \(results)")
				},
				cancelled: { results in
					print("thing was cancelled")
				}
			)
		}
	}
	
	func pauseTimer() {
        UIApplication.sharedApplication().idleTimerDisabled = false
        if self.timer != nil {
            self.timer.invalidate()
        }
		UIApplication.sharedApplication().cancelAllLocalNotifications()
		self.willDisplayForegroundNotification = false
		self.counting = false
//		startPauseButton.setTitle("Resume", forState: .Normal)
		startPauseButton.setImage(UIImage(named: "Play.png"), forState: .Normal)
//		NSNotificationCenter.defaultCenter().postNotificationName("pausedTiming", object: self)
		
	}
	
	func startTimer() {
        UIApplication.sharedApplication().idleTimerDisabled = true
		setupLocalNotifications()
		self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(NewFocusViewController.countdown), userInfo: nil, repeats: true)
		self.willDisplayForegroundNotification = true
		self.counting = true
//		startPauseButton.setTitle("Pause", forState: .Normal)
		startPauseButton.setImage(UIImage(named: "Pause.png"), forState: .Normal)
//		NSNotificationCenter.defaultCenter().postNotificationName("startedTiming", object: self)
		
	}
	
	func pauseTimerIfRunning() { // called upon app exit.
		if self.counting {
			pauseTimer()
			timerInterrupted = true
			let timerPausedNotification = UILocalNotification()
			timerPausedNotification.alertTitle = "Prioto"
			timerPausedNotification.alertBody = "Timer has been paused. Reenter Prioto to continue."
			timerPausedNotification.soundName = UILocalNotificationDefaultSoundName
			timerPausedNotification.category = "STOP_TIMER"
			
			UIApplication.sharedApplication().scheduleLocalNotification(timerPausedNotification)
			// NSNotificationCenter.defaultCenter().postNotificationName("pausedTiming", object: self)
			
		}
	}
	
	func unpauseTimerIfInterrupted() { // called upon app reenter
		if timerInterrupted {
			startTimer()
			timerInterrupted = false
			let notification = BSForegroundNotification(userInfo: NotificationHelper.userInfoForCategory("START_TIMER"))
			notification.delegate = self
			notification.timeToDismissNotification = NSTimeInterval(5)
			notification.presentNotification()
		}
//		NSNotificationCenter.defaultCenter().postNotificationName("startedTiming", object: self)
	}
	
	
	
	@IBAction func restartButtonPressed(sender: AnyObject) {
		if let timer = self.timer {
			if timeRemaining == timeMax { // if already reset, then change type
				switchTimerType()
			}
            if self.timer != nil {
                self.timer.invalidate()
            }
			UIApplication.sharedApplication().cancelAllLocalNotifications()
			self.timeRemaining = Double(self.timeMax)
			self.counting = false
			self.willDisplayForegroundNotification = false
			self.updateTimer()
//			self.startPauseButton.setTitle("Start", forState: .Normal)
			startPauseButton.setImage(UIImage(named: "Play.png"), forState: .Normal)
		}
	}
	
	
		
	@IBOutlet weak var timeWorkedLabel: UILabel!
	
	let singlePscope = PermissionScope()
	
	override func viewDidLoad() {
		
		newFocusViewControllerLoaded = true
		
//		let settings = UIUserNotificationSettings(forTypes: [.Badge, .Sound, .Alert], categories: nil)
//		UIApplication.sharedApplication().registerUserNotificationSettings(settings)
		
        var bounds = UIScreen.mainScreen().bounds
        var width = bounds.size.width
		
		let margin: CGFloat = 1
		let radius: CGFloat = width * 0.65 / 2
		
		let rings = [
            ProgressRing(color: UIColor(.RGB(192,57,43)), backgroundColor: UIColor(.RGB(33, 33, 48)), width: 16),
            ProgressRing(color: UIColor(.RGB(231,76,60)), backgroundColor: UIColor(.RGB(33, 33, 48))),
            ]
		
        
		progressRingView = try! ConcentricProgressRingView(center: view.center, radius: radius, margin: margin, rings: rings, defaultColor: UIColor.clearColor(), defaultWidth: 12)
        
		
		for ring in progressRingView {
			ring.progress = 0.0
		}
		
		view.addSubview(progressRingView)
		progressRingView.tag = 100
		
		view.backgroundColor = UIColor(.RGB(33, 33, 48))
		
		if (Defaults[.workDuration] == 0 && Defaults[.breakDuration] == 0) {
			Defaults[.workDuration] = 1500
			Defaults[.breakDuration] = 300
		}
        

		
		self.workTimeMax = Defaults[.workDuration]
		self.breakTimeMax = Defaults[.breakDuration]
		timerType = TimerType.Work
		self.typeName = "Work"
		self.typeLabel.text = self.typeName
		self.setTimeBasedOnTimerType(self.timerType)
		self.resetTimer()
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NewFocusViewController.didReopenApp), name: "didReopenApp", object: nil)
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NewFocusViewController.pauseTimerIfRunning), name: "appExited", object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NewFocusViewController.unpauseTimerIfInterrupted), name: "appEntered", object: nil)
		addObserver()
		
		
//		view.frame = CGRectMake(0, 44.0, CGRectGetWidth(UIScreen.mainScreen().bounds), CGRectGetHeight(UIScreen.mainScreen().bounds))
		
		
		//let taskTitles = RealmHelper.getTaskTitles()
		//self.dropdownMenu = AZDropdownMenu(titles: taskTitles)
		//var topOffset = (self.navigationController?.navigationBar.frame.height)! + UIApplication.sharedApplication().statusBarFrame.height
		//print("Top bar height: \(topOffset)")
		//		self.dropdownMenu!.menuTopOffset = topOffset
		//		self.dropdownMenu!.itemHeight = 44
		
		taskLabel.adjustsFontSizeToFitWidth = true
		taskLabel.minimumScaleFactor = 0.4
		taskLabel.numberOfLines = 1
		typeLabel.adjustsFontSizeToFitWidth = true
		typeLabel.minimumScaleFactor = 0.4
		typeLabel.numberOfLines = 1
		timeLeftLabel.adjustsFontSizeToFitWidth = true
		timeLeftLabel.minimumScaleFactor = 0.4
		timeLeftLabel.numberOfLines = 1
        
        // print("Timer view frame width from viewload: \(timerView.frame.width / 2)")
		
		singlePscope.addPermission(NotificationsPermission(notificationCategories: nil),
		                           message: "Prioto uses this to remind you \r\nwhen to work and break")

	}
	
	deinit {
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	
	func didReopenApp() {
		viewWillAppear(true)
	}
	
	
	override func viewWillAppear(animated: Bool) {
	// 	print("View appeared")
        
//		if hasExitedAppAndGoBack && self.counting {
//			
//			//			if let lastDate = Defaults["dateAppExited"].date {
//			//				let timeElapsed = Double(NSDate().timeIntervalSinceDate(lastDate))
//			//				self.timeRemaining = self.timeRemaining - timeElapsed
//			//				print("Time elapsed: \(timeElapsed)")
//			//
//			//			}
//			self.updateTimer()
//			hasExitedAppAndGoBack = false
//			Defaults[DefaultsKeys.dateAppExited._key] = nil
//		}
//		// updateTasksInMenu()
//		if let task = self.task {
//			if task.invalidated {
//				taskLabel.text = "No task being tracked"
//				taskLabel.textColor = UIColor.redColor()
//			}
//		}
//		else {
//			taskLabel.text = "No task being tracked"
//			taskLabel.textColor = UIColor.redColor()
//		}
		
		guard let task = self.task else {
			taskLabel.text = "No task being tracked"
			taskLabel.textColor = UIColor.redColor()
			NSNotificationCenter.defaultCenter().postNotificationName("appClosed", object: nil)
			return
		}

		
        print("Radius from view appear: \(timerView.frame.width / 2)")
		
	}
	
	override func viewWillDisappear(animated: Bool) {
	//	self.dropdownMenu?.hideMenu()
		// navigationController?.navigationBar.translucent = true
        print("Radius from view disappear: \(timerView.frame.width / 2)")

	}
	
	@IBAction func unwindToNewFocusViewController(segue: UIStoryboardSegue) {
		if segue.identifier == "save" {
			self.workTimeMax = Defaults[.workDuration]
			self.breakTimeMax = Defaults[.breakDuration]
			self.setTimeBasedOnTimerType(self.timerType)
			if self.timer != nil {
				self.timer.invalidate()
			}
			self.counting = false
			self.willDisplayForegroundNotification = false
			self.resetTimer()
			self.timerType = TimerType.Work
//			self.startPauseButton.setTitle("Start", forState: .Normal)
			startPauseButton.setImage(UIImage(named: "Play.png"), forState: .Normal)
		}
	}
	
	
		func countdown() { // gets called by timer every second
		self.timeRemaining = timeRemaining - 1 // decrement timeRemaining integer
		self.updateTimer()
//		if self.timeRemaining == 0 {
//			AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
//		}
		if self.timeRemaining < 0 {
			self.switchTimerType()
			setupLocalNotifications()
		}
		// print("counting down")
		
		if self.timerType == TimerType.Work { // add time to task
			if let task = self.task {
				if task.invalidated != true {
					let realm = try! Realm()
					try! realm.write {
						task.timeWorked += 1
						//print("Time worked: \(task.timeWorked)")
					}
					timeWorkedLabel.text = "Time Worked On Task: \(formatSecondsAsTimeString(Double(task.timeWorked)))"
				}
				else {
					taskLabel.text = "No task being tracked"
				}
			}
		}
	}
	
	func switchTimerType() {
		if self.timerType == TimerType.Work {
			self.timerType = TimerType.Break
			self.typeName = "Break"
		}
		else if self.timerType == TimerType.Break {
			self.timerType = TimerType.Work
			self.typeName = "Work"
		}
		setTimeBasedOnTimerType(self.timerType)
		resetTimer()
	}
	
	func updateTimer() {
		self.timeLeftLabel.text = formatSecondsAsTimeString(self.timeRemaining)
		
		self.progressRingView[1].progress = 1.0 - ((CGFloat(self.timeRemaining) % 60.0) / 60.0)
		
		
		if timeRemaining == timeMax {
			self.progressRingView[1].progress = 0.0
		}
		
		self.progressRingView[0].progress = 1.0 - (CGFloat(self.timeRemaining) / CGFloat(self.timeMax))
	}
	
	func resetTimer() {
		self.timeLeftLabel.text = formatSecondsAsTimeString(timeMax)
		self.timeRemaining = self.timeMax
		self.typeLabel.text = self.typeName
		updateTimer()
	}
	
	
	func formatSecondsAsTimeString(time: Double) -> String {
		let hours = Int(round(time)) / 3600
		let minutes = Int(round(time)) / 60 % 60
		let seconds = Int(round(time)) % 60
		return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
	}
	
	
	func setTimeBasedOnTimerType(timerType: TimerType) {
		switch timerType {
		case TimerType.Work:
			self.timeMax = Double(self.workTimeMax)
			self.typeName = "Work"
			
		case TimerType.Break:
			self.timeMax = Double(self.breakTimeMax)
			self.typeName = "Break"
		}
	}
	
	func setupLocalNotifications() {
		self.localNotification = UILocalNotification()
		self.localNotificationEndDate = NSDate().dateByAddingTimeInterval(self.timeRemaining)
		print("Current date: \(NSDate())")
//		let alertBody = "Time for " + self.typeName + " is up!"
//		let alertTitle = ""
		self.localNotification!.fireDate = self.localNotificationEndDate
//		self.localNotification!.alertBody = alertBody
//		self.localNotification!.alertTitle = alertTitle
		self.localNotification!.soundName = UILocalNotificationDefaultSoundName
		if self.timerType == TimerType.Work {
			self.localNotification!.category = "WORKTIME_UP"
		}
		else if self.timerType == TimerType.Break {
			self.localNotification!.category = "BREAKTIME_UP"
		}
		
		UIApplication.sharedApplication().scheduleLocalNotification(self.localNotification!)
	}
	
	func setupMultipleLocalNotifications() {
		
	}
	
	// MARK: Timer - Todo List Integration
	var task: Task?
	
	@IBAction func dropdownMenuButtonPressed(sender: AnyObject) {
	//	showDropdown()
	}
	
	//var dropdownMenu: AZDropdownMenu?
	
	@IBOutlet weak var taskLabel: UILabel!
	
//	func showDropdown() {
//		
//		if (self.dropdownMenu?.isDescendantOfView(self.view) == true) {
//			print("is decendent")
//			self.dropdownMenu?.hideMenu()
//			// navigationController?.navigationBar.translucent = true
//			
//		} else {
//			self.dropdownMenu?.showMenuFromViewOffset(self.view)
//			// navigationController?.navigationBar.translucent = false
//			
//		}
//		
//		self.dropdownMenu?.cellTapHandler = { [weak self] (indexPath: NSIndexPath) -> Void in
//			
//		}
//	}
//	
//	func updateTasksInMenu() {
//		let taskTitles = RealmHelper.getTaskTitles()
//		self.dropdownMenu = AZDropdownMenu(titles: taskTitles)
//	}
	
	func assignTask(notification: NSNotification) {
		if let oldTask = self.task {
			if oldTask.invalidated != true {
				let realm = try! Realm()
				try! realm.write {
					oldTask.isBeingWorkedOn = false
				}
			}
		}
		if let task = notification.userInfo?["task"] as? Task {
			setupTask(task)
		}
		
		var outerRingColor: UIColor = UIColor()
		var innerRingColor: UIColor = UIColor()
		if let priorityIndex = task?.priorityIndex {
			switch priorityIndex {
			case 0:
				outerRingColor = UIColor(.RGB(190,0,50))
				innerRingColor = UIColor(.RGB(190,50,50))
//				startPauseButton.backgroundColor = UIColor(.RGB(192,57,43))
//				restartButton.backgroundColor = UIColor(.RGB(192,57,43))
//				taskLabel.textColor = UIColor(.RGB(190,0,50))
			case 1:
				outerRingColor = UIColor(.RGB(30,0,200))
				innerRingColor = UIColor(.RGB(30,50,200))
//				startPauseButton.backgroundColor = UIColor(.RGB(30,99,214))
//				restartButton.backgroundColor = UIColor(.RGB(30,99,214))
//				taskLabel.textColor = UIColor(.RGB(30,0,200))

			case 2:
				outerRingColor = UIColor(.RGB(60,60,115))
				innerRingColor = UIColor(.RGB(110,60, 115))
//				startPauseButton.backgroundColor = UIColor(.RGB(36,123,160))
//				restartButton.backgroundColor = UIColor(.RGB(36,123,160))
//				taskLabel.textColor = UIColor(.RGB(60,60,115))

			case 3:
				outerRingColor = UIColor(.RGB(15,125,125))
				innerRingColor = UIColor(.RGB(15,175,125))
//				startPauseButton.backgroundColor = UIColor(.RGB(13,171,118))
//				restartButton.backgroundColor = UIColor(.RGB(13,171,118))
//				taskLabel.textColor = UIColor(.RGB(15,125,125))


			default:
				outerRingColor = UIColor(.RGB(190,0,50))
				innerRingColor = UIColor(.RGB(190,50,50))
//				startPauseButton.backgroundColor = UIColor(.RGB(192,57,43))
//				restartButton.backgroundColor = UIColor(.RGB(192,57,43))
			}
		}
		
		if let viewWithTag = self.view.viewWithTag(100) {
			viewWithTag.removeFromSuperview()
		}
		
        var bounds = UIScreen.mainScreen().bounds
        var width = bounds.size.width

        
		let margin: CGFloat = 1
		let radius: CGFloat = width * 0.65 / 2
    
		let rings = [
			ProgressRing(color: outerRingColor, backgroundColor: UIColor(.RGB(33, 33, 48))),
			ProgressRing(color: innerRingColor, backgroundColor: UIColor(.RGB(33, 33, 48)))]
		progressRingView = try! ConcentricProgressRingView(center: view.center, radius: radius, margin: margin, rings: rings, defaultColor: UIColor.clearColor(), defaultWidth: 14)
        print("Radius: \(radius)")
		updateTimer()
		progressRingView.tag = 100
		view.addSubview(progressRingView)
	}
	
	func setupTask(task: Task) {
		self.task = task
		let realm = try! Realm()
		try! realm.write {
			self.task!.isBeingWorkedOn = true
		}
		taskLabel.text = self.task!.text
		taskLabel.textColor = UIColor.whiteColor()
		timeWorkedLabel.text = "Time Worked On Task: \(formatSecondsAsTimeString(Double(task.timeWorked)))"
		print("Assigned task elapsed time: \(self.task?.timeWorked))")
	}
	
	func resetWorkingOn() {
		let realm = try! Realm()
		if let task = self.task {
			try! realm.write {
				task.isBeingWorkedOn = false
			}
		}
	}
	
	
	
	// Get the Task at a given index path
	func taskForIndexPath(indexPath: NSIndexPath) -> Task? {
		return tasksByPriority.priorities[indexPath.section].tasks[indexPath.row]
	}
	
	func addObserver() {
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NewFocusViewController.assignTask(_:)), name: "taskChosen", object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NewFocusViewController.startTimer), name: "swipeEnded", object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NewFocusViewController.pauseTimer), name: "swipeStarted", object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NewFocusViewController.resetWorkingOn), name: "appClosed", object: nil)
	}
    
    @IBAction func infoButtonTapped(sender: AnyObject) {
        showPomodoroInfo()
    }
    
    func showPomodoroInfo() {
        let deviceType = UIDevice.currentDevice().deviceType
        
        switch deviceType {
        case .IPhone4:
            // Prepare the popup assets
            let title = "Work in bursts."
            let message = "Use the Pomodoro Technique to combat burnout by working in intervals, taking breaks in between. For example, work for 25 minutes fully focused, then break for 5 minutes."
            
            // Create the dialog
            let popup = PopupDialog(title: title, message: message, transitionStyle: .ZoomIn, buttonAlignment: .Horizontal)
            
            // Create first button
            let buttonOne = CancelButton(title: "Okay") {
            }
            
            // Add buttons to dialog
            popup.addButtons([buttonOne])
            
            // Present dialog
            self.presentViewController(popup, animated: true, completion: nil)

        case .IPhone4S:
            // Prepare the popup assets
            let title = "Work in bursts."
            let message = "Use the Pomodoro Technique to combat burnout by working in intervals, taking breaks in between. For example, work for 25 minutes fully focused, then break for 5 minutes."
            
            // Create the dialog
            let popup = PopupDialog(title: title, message: message, transitionStyle: .ZoomIn, buttonAlignment: .Horizontal)
            
            // Create first button
            let buttonOne = CancelButton(title: "Okay") {
            }
            
            // Add buttons to dialog
            popup.addButtons([buttonOne])
            
            // Present dialog
            self.presentViewController(popup, animated: true, completion: nil)

        default:
            // Prepare the popup assets
            let title = "Work in bursts."
            let message = "Use the Pomodoro Technique to combat burnout by working in intervals, taking breaks in between. For example, work for 25 minutes fully focused, then break for 5 minutes."
            let image = UIImage(named: "Pomodoro")
            
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
        
    }
    
}
