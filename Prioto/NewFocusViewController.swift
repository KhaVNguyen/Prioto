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

class NewFocusViewController: UIViewController {
	
	enum TimerType : String {
		case Work = "Work"
		case Break = "Break"
	}
	
	@IBOutlet weak var timeLeftLabel: UILabel!
	
	var progressRingView: ConcentricProgressRingView!

	var timeRemaining: Double!
	var timeMax: Double!
	
	@IBAction func preferencesButtonPressed(sender: AnyObject) {
		
	}
	
	var breakTimeMax: Int = 300
	var workTimeMax: Int = 1500
	
	var timer: NSTimer?
	var counting: Bool = false
	
	var timerType: TimerType!
	
	@IBOutlet weak var startPauseButton: UIButton!
	
	@IBAction func startPauseButtonPressed(sender: AnyObject) {
		if self.counting {
			self.timer?.invalidate()
			self.counting = false
			startPauseButton.setTitle("Resume", forState: .Normal)
			startPauseButton.setImage(UIImage(named: "Play.png"), forState: .Normal)
		}
		else {
			self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(NewFocusViewController.countdown), userInfo: nil, repeats: true)
			self.counting = true
			startPauseButton.setTitle("Pause", forState: .Normal)
			startPauseButton.setImage(UIImage(named: "Pause.png"), forState: .Normal)

		}
	}
	
	@IBAction func restartButtonPressed(sender: AnyObject) {
		self.timer?.invalidate()
		self.timeRemaining = Double(self.timeMax)
		self.counting = false
		self.updateTimer()
		self.startPauseButton.setTitle("Start", forState: .Normal)
		startPauseButton.setImage(UIImage(named: "Play.png"), forState: .Normal)
	}
	
	override func viewDidLoad() {
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
		self.setTimeBasedOnTimerType(self.timerType)
		self.resetTimer()
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NewFocusViewController.didReopenApp), name: "didReopenApp", object: nil)
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

	}
	
	@IBAction func unwindToNewFocusViewController(segue: UIStoryboardSegue) {
		if segue.identifier == "save" {
			self.workTimeMax = Defaults[.workDuration]
			self.breakTimeMax = Defaults[.breakDuration]
			self.setTimeBasedOnTimerType(self.timerType)
			self.resetTimer()
			self.timer?.invalidate()
			self.counting = false
			self.updateTimer()
			self.startPauseButton.setTitle("Start", forState: .Normal)
			startPauseButton.setImage(UIImage(named: "Play.png"), forState: .Normal)
		}
	}
	
	func countdown() { // gets called by timer every second
		self.timeRemaining = timeRemaining - 1 // decrement timeRemaining integer
		self.updateTimer()
		if self.timeRemaining <= 0 {
			self.switchTimerType()
		}
	}
	
	func switchTimerType() {
		if self.timerType == TimerType.Work {
			self.timerType = TimerType.Break
		}
		else if self.timerType == TimerType.Break {
			self.timerType = TimerType.Work
		}
		setTimeBasedOnTimerType(self.timerType)
		resetTimer()
	}
	
	func updateTimer() {
		self.timeLeftLabel.text = formatSecondsAsTimeString(timeRemaining)

		self.progressRingView[1].progress = 1.0 - ((CGFloat(self.timeRemaining) % 60.0) / 60.0)
		
		if timeRemaining == timeMax {
			self.progressRingView[1].progress = 0.0
		}
	}
	
	func resetTimer() {
		self.timeLeftLabel.text = formatSecondsAsTimeString(timeMax)
		self.timeRemaining = self.timeMax
	}
	
	
	func formatSecondsAsTimeString(time: Double) -> String {
		let hours = Int(time) / 3600
		let minutes = Int(time) / 60 % 60
		let seconds = Int(time) % 60
		return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
	}
	
	func setTimeBasedOnTimerType(timerType: TimerType) {
		switch timerType {
		case TimerType.Work:
			self.timeMax = Double(self.workTimeMax)
		case TimerType.Break:
			self.timeMax = Double(self.breakTimeMax)
		}
	}
}
