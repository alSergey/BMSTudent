//
//  myTableViewCell.swift
//  BMSTudent
//
//  Created by Сергей Алехин on 11/05/2019.
//  Copyright © 2019 Sergei. All rights reserved.
//

import UIKit

class myTableViewCell: UITableViewCell {

    @IBOutlet weak var groupLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func fillCellGreen() {
        contentView.backgroundColor = .green
    }
    
    func fillCell(with group: String){
        groupLabel.text = group
        
    }
    
}
