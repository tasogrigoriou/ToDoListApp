//
//  ToDoTableViewCell.swift
//  ToDoListApp
//
//  Created by Anastasios Grigoriou on 9/19/18.
//  Copyright © 2018 Grigoriou. All rights reserved.
//

import UIKit

protocol ToDoTableViewCellDelegate: class {
    func setTaskToCompleted(_ sender: ToDoTableViewCell)
}

class ToDoTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var circleImageView: UIImageView!
    
    weak var delegate: ToDoTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    @IBAction func circleButtonPressed() {
        delegate?.setTaskToCompleted(self)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
