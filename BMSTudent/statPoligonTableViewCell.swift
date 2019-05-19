//
//  statPoligonTableViewCell.swift
//  BMSTudent
//
//  Created by Сергей Алехин on 19/05/2019.
//  Copyright © 2019 Sergei. All rights reserved.
//

import UIKit

class statPoligonTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func fillNameAndTimeCell(with name: String, with time: Int) {
        nameLabel.text = name
        timeLabel.text = String(time) + " C"
    }
}
