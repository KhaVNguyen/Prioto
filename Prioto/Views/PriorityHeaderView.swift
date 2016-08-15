//
//  PriorityHeaderView.swift
//  Prioto
//
//  Created by Kha Nguyen on 7/26/16.
//  Copyright © 2016 Kha. All rights reserved.
//

import UIKit

class PriorityHeaderView: UITableViewHeaderFooterView {
	
	@IBOutlet weak var priorityLabel: UILabel!
	

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
	
	var addTaskToSectionCallback: (() -> Void)?
	
	@IBAction func addTaskToSectionButtonPressed(sender: AnyObject) {
		if let addTaskToSectionCallback = self.addTaskToSectionCallback {
			addTaskToSectionCallback()
		}
	}
		
}
