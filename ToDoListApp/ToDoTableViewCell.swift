//
//  ToDoTableViewCell.swift
//  ToDoListApp
//
//  Created by Anastasios Grigoriou on 9/19/18.
//  Copyright © 2018 Grigoriou. All rights reserved.
//

import UIKit

class ToDoTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
