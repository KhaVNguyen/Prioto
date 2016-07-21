//
//  TimerView.swift
//  Tomate
//
//  Created by dasdom on 29.06.14.
//  Copyright (c) 2014 Dominik Hauser. All rights reserved.
//

import UIKit
import QuartzCore

final class FocusView: UIView {
  let timerView: TimerView
  let workButton: UIButton
  let settingsButton: UIButton
	
  let sidePadding = CGFloat(10)
  
  override init(frame: CGRect) {
    timerView = TimerView(frame: CGRectZero)
    timerView.translatesAutoresizingMaskIntoConstraints = false
    
    let makeButton = { (title: String) -> UIButton in
      let button = UIButton(type: .System)
      button.translatesAutoresizingMaskIntoConstraints = false
      button.layer.cornerRadius = 40
      button.layer.borderWidth = 1.0
      button.layer.borderColor = UIColor.blackColor().CGColor
      button.setTitle(title, forState: .Normal)
      button.titleLabel?.font = UIFont(name: "HelveticaNeue-Thin", size: 22)
      return button
    }
    
    settingsButton = {
      let button = UIButton(type: .System)
      button.translatesAutoresizingMaskIntoConstraints = false

      button.setImage(TimerStyleKit.imageOfSettings, forState: .Normal)
      button.accessibilityLabel = NSLocalizedString("Settings", comment: "")
      return button
      }()
	
    
    workButton = makeButton(NSLocalizedString("Work", comment: "Start working button title"))
	super.init(frame: frame)
    
    backgroundColor = UIColor.whiteColor()
    tintColor = UIColor.blackColor()
    
    addSubview(timerView)
    addSubview(workButton)
    addSubview(settingsButton)
	
    let views = ["settingsButton" : settingsButton, "timerView" : timerView, "workButton" : workButton]
    let metrics = ["workWidth": 80, "settingsWidth": 44, "sidePadding": sidePadding]
    
    var constraints = [NSLayoutConstraint]()
	constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|-30-[settingsButton(settingsWidth)]", options: [], metrics: metrics, views: views)
	    
//    constraints.append(timerView.widthAnchor.constraintEqualToConstant(CGFloat(metrics["timerWidth"]!)))
    
    constraints += NSLayoutConstraint.constraintsWithVisualFormat("|-(>=sidePadding)-[timerView]-(>=sidePadding)-|", options: [], metrics: metrics, views: views)
    constraints += NSLayoutConstraint.constraintsWithVisualFormat("|-(==sidePadding@751)-[timerView]-(==sidePadding@751)-|", options: [], metrics: metrics, views: views)
    constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|-(>=sidePadding)-[timerView]-(>=sidePadding)-|", options: [], metrics: metrics, views: views)
    constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|-(==sidePadding@750)-[timerView]-(==sidePadding@750)-|", options: [], metrics: metrics, views: views)
    constraints.append(timerView.widthAnchor.constraintEqualToAnchor(timerView.heightAnchor))
	
    constraints.append(timerView.centerYAnchor.constraintEqualToAnchor(centerYAnchor, constant: -50))
	    
    NSLayoutConstraint.activateConstraints(constraints)
	}
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setDuration(duration: CGFloat, maxValue: CGFloat) {
    timerView.durationInSeconds = duration
    timerView.maxValue = maxValue
    timerView.updateTimer()
  }
  
}
