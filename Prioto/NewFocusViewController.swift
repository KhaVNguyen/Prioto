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

var newFocusViewControllerLoaded: Bool = false
var timerInterrupted: Bool = false

class NewFocusViewController: UIViewController, BSForegroundNotificationDelegate {
	
	enum TimerType : String {
		case Work = "Work"
		case Break = "Break"
	}
	
	@IBOutlet weak var timeLeftLabel: UILabel!
	
	var progressRingView: ConcentricProgressRingView!

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
	
	@IBOutlet weak var startPauseButton: UIButton!
	
	@IBAction func startPauseButtonPressed(sender: AnyObject) {
		if self.counting {
			pauseTimer()
		}
		else {
			startTimer()
		}
	}
	
	func pauseTimer() {
		self.timer.invalidate()
		UIApplication.sharedApplication().cancelAllLocalNotifications()
		self.willDisplayForegroundNotification = false
		self.counting = false
		startPauseButton.setTitle("Resume", forState: .Normal)
		startPauseButton.setImage(UIImage(named: "Play.png"), forState: .Normal)
	}
	
	func startTimer() {
		setupLocalNotifications()
		self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(NewFocusViewController.countdown), userInfo: nil, repeats: true)
		self.willDisplayForegroundNotification = true
		self.counting = true
		startPauseButton.setTitle("Pause", forState: .Normal)
		startPauseButton.setImage(UIImage(named: "Pause.png"), forState: .Normal)
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
	}
	
	
	
	@IBAction func restartButtonPressed(sender: AnyObject) {
		if let timer = self.timer {
			if timeRemaining == timeMax { // if already reset, then change type
				switchTimerType()
			}
			self.timer.invalidate()
			UIApplication.sharedApplication().cancelAllLocalNotifications()
			self.timeRemaining = Double(self.timeMax)
			self.counting = false
			self.willDisplayForegroundNotification = false
			self.updateTimer()
			self.startPauseButton.setTitle("Start", forState: .Normal)
			startPauseButton.setImage(UIImage(named: "Play.png"), forState: .Normal)
		}
	}
	
	
	
	override func viewDidLoad() {
		
		newFocusViewControllerLoaded = true
		
		let settings = UIUserNotificationSettings(forTypes: [.Badge, .Sound, .Alert], categories: nil)
		UIApplication.sharedApplication().registerUserNotificationSettings(settings)
		
		let margin: CGFloat = 1
		let radius: CGFloat = 130
		
		let rings = [
			ProgressRing(color: UIColor(.RGB(192,57,43)), backgroundColor: UIColor(.RGB(255, 255, 255))),
			ProgressRing(color: UIColor(.RGB(231,76,60)), backgroundColor: UIColor(.RGB(255, 255, 255)))]

		progressRingView = try! ConcentricProgressRingView(center: view.center, radius: radius, margin: margin, rings: rings, defaultColor: UIColor.clearColor(), defaultWidth: 18)
		
		for ring in progressRingView {
			ring.progress = 0.0
		}
		
		view.backgroundColor = UIColor.whiteColor()
		view.addSubview(progressRingView)
		
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
		view.frame = CGRectMake(0, 44.0, CGRectGetWidth(UIScreen.mainScreen().bounds), CGRectGetHeight(UIScreen.mainScreen().bounds))

		
		let taskTitles = RealmHelper.getTaskTitles()
		self.dropdownMenu = AZDropdownMenu(titles: taskTitles)
		self.dropdownMenu!.menuTopOffset = 44.0
		self.dropdownMenu!.itemHeight = 44
		
		
	}
	
	deinit {
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	
	func didReopenApp() {
		viewWillAppear(true)
	}
	
	
	override func viewWillAppear(animated: Bool) {
		print("View appeared")
		if hasExitedAppAndGoBack && self.counting {
			
//			if let lastDate = Defaults["dateAppExited"].date {
//				let timeElapsed = Double(NSDate().timeIntervalSinceDate(lastDate))
//				self.timeRemaining = self.timeRemaining - timeElapsed
//				print("Time elapsed: \(timeElapsed)")
//
//			}
			self.updateTimer()
			hasExitedAppAndGoBack = false
			Defaults[DefaultsKeys.dateAppExited._key] = nil
		}
		updateTasksInMenu()


	}
	
	override func viewWillDisappear(animated: Bool) {
		self.dropdownMenu?.hideMenu()
		// navigationController?.navigationBar.translucent = true

	}
	
	@IBAction func unwindToNewFocusViewController(segue: UIStoryboardSegue) {
		if segue.identifier == "save" {
			self.workTimeMax = Defaults[.workDuration]
			self.breakTimeMax = Defaults[.breakDuration]
			self.setTimeBasedOnTimerType(self.timerType)
			self.timer.invalidate()
			self.counting = false
			self.willDisplayForegroundNotification = false
			self.resetTimer()
			self.timerType = TimerType.Work
			self.startPauseButton.setTitle("Start", forState: .Normal)
			startPauseButton.setImage(UIImage(named: "Play.png"), forState: .Normal)
		}
	}
	
	func countdown() { // gets called by timer every second
		self.timeRemaining = timeRemaining - 1 // decrement timeRemaining integer
		self.updateTimer()
		if self.timeRemaining == 0 {
			AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
		}
		if self.timeRemaining < 0 {
			self.switchTimerType()
			setupLocalNotifications()
		}
		print("counting down")
		
		if self.timerType == TimerType.Work { // add time to task
			if let task = self.task {
				let realm = try! Realm()
				try! realm.write {
					task.timeWorked += 1
					print("Time worked: \(task.timeWorked)")
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
		let alertBody = "Time for " + self.typeName + " is up!"
		let alertTitle = ""
		self.localNotification!.fireDate = self.localNotificationEndDate
		self.localNotification!.alertBody = alertBody
		self.localNotification!.alertTitle = alertTitle
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
		showDropdown()
	}
	
	var dropdownMenu: AZDropdownMenu?
	
	@IBOutlet weak var taskLabel: UILabel!
	
	func showDropdown() {

		if (self.dropdownMenu?.isDescendantOfView(self.view) == true) {
			print("is decendent")
			self.dropdownMenu?.hideMenu()
			// navigationController?.navigationBar.translucent = true

		} else {
			self.dropdownMenu?.showMenuFromView(self.view)
			// navigationController?.navigationBar.translucent = false

		}
		
		self.dropdownMenu?.cellTapHandler = { [weak self] (indexPath: NSIndexPath) -> Void in
			
		}
	}
	
	func updateTasksInMenu() {
		let taskTitles = RealmHelper.getTaskTitles()
		self.dropdownMenu = AZDropdownMenu(titles: taskTitles)
	}
	
	func assignTask(notification: NSNotification) {
		if let task = notification.userInfo?["task"] as? Task {
			self.task = task
			taskLabel.text = self.task!.text
		}
	}
	
	func addObserver() {
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NewFocusViewController.assignTask(_:)), name: "taskChosen", object: nil)
	}
}
