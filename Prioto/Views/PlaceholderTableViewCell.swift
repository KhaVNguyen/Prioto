//
//  PlaceholderTableViewCell.swift
//  Prioto
//
//  Created by Kha Nguyen on 7/27/16.
//  Copyright © 2016 Kha. All rights reserved.
//

import UIKit

class PlaceholderTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

	@IBOutlet weak var placeholderLabel: UIButton!
	
	@IBAction func placeolderLabelTapped(sender: AnyObject) {
	}
}
