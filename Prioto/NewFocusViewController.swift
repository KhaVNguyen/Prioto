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
import ConcentricProgressRingView
import LionheartExtensions


class NewFocusViewController: UIViewController {
	
	enum TimerType : String {
		case Work = "Work"
		case Break = "Break"
	}
	
	@IBOutlet weak var timeLeftLabel: UILabel!
	
	var progressRingView: ConcentricProgressRingView!

	var timeRemaining: Int!
	var timeMax: Int!
	
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
		let margin: CGFloat = 1
		let radius: CGFloat = 130
		
		let rings = [
			ProgressRing(color: UIColor(.RGB(232, 11, 45)), backgroundColor: UIColor(.RGB(255, 255, 255))),
			ProgressRing(color: UIColor(.RGB(137, 242, 0)), backgroundColor: UIColor(.RGB(255, 255, 255)))]

		progressRingView = try! ConcentricProgressRingView(center: view.center, radius: radius, margin: margin, rings: rings, defaultColor: UIColor.clearColor(), defaultWidth: 18)
		
		for ring in progressRingView {
			ring.progress = 0.0
		}
		
		view.backgroundColor = UIColor.whiteColor()
		view.addSubview(progressRingView)
		
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
			}
			else if self.timerType == TimerType.Break {
				self.timerType = TimerType.Work
			}
			setTimeBasedOnTimerType(self.timerType)
			resetTimer()
		}
	}
	
	func updateTimer() {
		self.timeLeftLabel.text = formatSecondsAsTimeString(timeRemaining)
		
//		self.circleProgressView.progress = 1.0 - (Double(self.timeRemaining) / Double(self.timeMax))
		self.progressRingView[1].progress = 1.0 - (CGFloat(self.timeRemaining) / CGFloat(self.timeMax))
		if (timeRemaining <= timeMax && timeRemaining % 60 == 0) {
			self.progressRingView[0].progress = 1.0 - (CGFloat(self.timeRemaining) / CGFloat(self.timeMax))
		}
	}
	
	func resetTimer() {
		self.timeLeftLabel.text = formatSecondsAsTimeString(timeMax)
		self.timeRemaining = self.timeMax
		
//		self.circleProgressView.progress = 1.0 - (Double(self.timeRemaining) / Double(self.timeMax))
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
