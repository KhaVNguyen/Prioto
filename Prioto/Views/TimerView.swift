//
//  TimerView.swift
//  Prioto
//
//  Created by Kha Nguyen on 7/20/16.
//  Copyright © 2016 Kha. All rights reserved.
//

import Foundation
import UIKit
import MKRingProgressView

@IBDesignable class TimerView: UIView {
	override func viewDidLoad() {
		let ringProgressView = MKRingProgressView(frame: CGRect(x: 0, y: 100, width: 100, height: 100))
		ringProgressView.startColor = UIColor.redColor()
		ringProgressView.endColor = UIColor.magentaColor()
		ringProgressView.ringWidth = 25
		ringProgressView.progress = 0.0
		ringProgressView.allowsAntialiasing = true
		view.addSubview(ringProgressView)
	}
}