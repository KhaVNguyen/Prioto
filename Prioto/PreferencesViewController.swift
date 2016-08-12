//
//  PreferencesViewController.swift
//  Prioto
//
//  Created by Kha Nguyen on 7/21/16.
//  Copyright © 2016 Kha. All rights reserved.
//

import Foundation
import UIKit
import SwiftyUserDefaults

extension DefaultsKeys {
	static let workDuration = DefaultsKey<Int>("workDuration")
	static let breakDuration = DefaultsKey<Int>("breakDuration")
}

class PreferencesViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
	
	@IBOutlet weak var workDurationLabel: UILabel!
	@IBOutlet weak var breakDurationLabel: UILabel!

	@IBOutlet weak var workDurationPickerView: UIPickerView!
	@IBOutlet weak var breakDurationPickerView: UIPickerView!

//	var workDurations: [Int] = [20, 25, 30, 35, 40, 45, 50, 55, 60, 70, 80, 90, 120] // in minutes
//	var breakDurations:[Int] = [1, 2, 3, 4, 5, 10, 15, 20, 25, 30, 60, 90, 120]
	
	var workDurations: [Int] = [1200, 1500, 1800, 2100, 2400, 2700, 3000, 3300, 3600, 4200, 4800, 5400, 7200] // in seconds
	var breakDurations: [Int] = [120, 180, 240, 300, 600, 900, 1200, 1500, 1800, 3600, 5400, 7200]
	
	var selectedWorkDuration: Int = 1500
	var selectedBreakDuration: Int = 300
		
	override func viewDidLoad() {
		super.viewDidLoad()
		breakDurationPickerView.delegate = self
		breakDurationPickerView.dataSource = self
		
		workDurationPickerView.delegate = self
		workDurationPickerView.dataSource = self
		
		selectedWorkDuration = Defaults[.workDuration]
		selectedBreakDuration = Defaults[.breakDuration]
		
		workDurationPickerView.selectRow(workDurations.indexOf(selectedWorkDuration) ?? 1, inComponent: 0, animated: true)
		breakDurationPickerView.selectRow(breakDurations.indexOf(selectedBreakDuration) ?? 4, inComponent: 0, animated: true)
		workDurationPickerView.tintColor = UIColor.whiteColor()
		breakDurationPickerView.tintColor = UIColor.whiteColor()

		
		workDurationLabel.text = "Work Duration: \(selectedWorkDuration/60) minutes"
		breakDurationLabel.text = "Break Duration: \(selectedBreakDuration/60) minutes"
	}
	
	// The number of columns of data
	func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
		return 1
	}
	
	// The number of rows of data
	func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		if pickerView == workDurationPickerView {
			return workDurations.count
		}
		else if pickerView == breakDurationPickerView {
			return breakDurations.count
		}
		
		return 5
	}
	
	func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		if pickerView == workDurationPickerView {
			return "\(String(workDurations[row]/60)) minutes"
		}
		else if pickerView == breakDurationPickerView {
			return "\(String(breakDurations[row]/60)) minutes"
		}
		
		return "Something broke"
	}
	
	func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
		
		if pickerView == workDurationPickerView {
			return (NSAttributedString(string: "\(String(workDurations[row]/60)) minutes", attributes: [NSForegroundColorAttributeName:UIColor.whiteColor()]))
		}
		else if pickerView == breakDurationPickerView {
			return (NSAttributedString(string: "\(String(breakDurations[row]/60)) minutes", attributes: [NSForegroundColorAttributeName:UIColor.whiteColor()]))
		}
		
		return (NSAttributedString(string: "Something went wrong..", attributes: [NSForegroundColorAttributeName:UIColor.whiteColor()]))
	}
	
	func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		if pickerView == workDurationPickerView {
			selectedWorkDuration = workDurations[row]
			workDurationLabel.text = "Work Duration: \(workDurations[row]/60) minutes"
			
		}
		else if pickerView == breakDurationPickerView {
			selectedBreakDuration = breakDurations[row]
			breakDurationLabel.text = "Break Duration: \(breakDurations[row]/60) minutes"
		}
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "cancel" {
			// don't save anything
		}
		else if segue.identifier == "save" {
			Defaults[.workDuration] = selectedWorkDuration
			Defaults[.breakDuration] = selectedBreakDuration
		}
	}
}