//
//  NewFocusViewController.swift
//  Prioto
//
//  Created by Kha Nguyen on 7/20/16.
//  Copyright © 2016 Kha. All rights reserved.

import Foundation
import UIKit
import MZTimerLabel
import SwiftyTimer
import CircleProgressView


class NewFocusViewController: UIViewController {
	
	enum TimerType : String {
		case Work = "Work"
		case Break = "Break"
	}
	
	@IBOutlet weak var timeLeftLabel: UILabel!
	
	
	@IBOutlet weak var circleProgressView: CircleProgressView!
	
	
	var timeRemaining: Int!
	var timeMax: Int!
	
	var breakTimeMax: Int = 5
	var workTimeMax: Int = 15
	
	var timer: NSTimer?
	var counting: Bool = false
	
	var timerType: TimerType!
	
	@IBOutlet weak var startPauseButton: UIButton!
	
	@IBAction func startPauseButtonPressed(sender: AnyObject) {
		if self.counting {
			self.timer?.invalidate()
			self.counting = false
			startPauseButton.setTitle("Resume", forState: .Normal)
		}
		else {
			self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(NewFocusViewController.countdown), userInfo: nil, repeats: true)
			self.counting = true
			startPauseButton.setTitle("Pause", forState: .Normal)
		}
	}
	
	@IBAction func restartButtonPressed(sender: AnyObject) {
		self.timer?.invalidate()
		self.timeRemaining = self.timeMax
		self.counting = false
		self.updateTimer()
		self.startPauseButton.setTitle("Start", forState: .Normal)
	}
	
	override func viewDidLoad() {
		timerType = TimerType.Work
		self.setTimeBasedOnTimerType(self.timerType)
		self.resetTimer()
	}
	
	func countdown() { // gets called by timer every second
		self.timeRemaining = timeRemaining - 1 // decrement timeRemaining integer
		self.updateTimer()
		if self.timeRemaining == 0 {
			if self.timerType == TimerType.Work {
				self.timerType = TimerType.Break
				self.circleProgressView.trackFillColor = UIColor.greenColor()
			}
			else if self.timerType == TimerType.Break {
				self.timerType = TimerType.Work
				self.circleProgressView.trackFillColor = UIColor.redColor()
			}
			setTimeBasedOnTimerType(self.timerType)
			resetTimer()
		}
	}
	
	func updateTimer() {
		self.timeLeftLabel.text = formatSecondsAsTimeString(timeRemaining)
		
		self.circleProgressView.progress = 1.0 - (Double(self.timeRemaining) / Double(self.timeMax))
	}
	
	func resetTimer() {
		self.timeLeftLabel.text = formatSecondsAsTimeString(timeMax)
		self.timeRemaining = self.timeMax
		
		self.circleProgressView.progress = 1.0 - (Double(self.timeRemaining) / Double(self.timeMax))
	}
	
	
	func formatSecondsAsTimeString(time: Int) -> String {
		let hours = Int(time) / 3600
		let minutes = Int(time) / 60 % 60
		let seconds = Int(time) % 60
		return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
	}
	
	func setTimeBasedOnTimerType(timerType: TimerType) {
		switch timerType {
		case TimerType.Work:
			self.timeMax = self.workTimeMax
		case TimerType.Break:
			self.timeMax = self.breakTimeMax
		}
	}
}
