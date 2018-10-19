//
//  ShowCompletedTableViewCell.swift
//  ToDoListApp
//
//  Created by Anastasios Grigoriou on 9/19/18.
//  Copyright © 2018 Grigoriou. All rights reserved.
//

import UIKit

protocol ShowCompletedCellDelegate: class {
    func didTapShowCompletedButton(_ button: UIButton)
}

class ShowCompletedTableViewCell: UITableViewCell {

    @IBOutlet weak var showCompletedButton: UIButton!
    
    weak var delegate: ShowCompletedCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        showCompletedButton.setTitle("Show Completed", for: .normal)
        showCompletedButton.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func showCompletedTapped(_ sender: UIButton) {
        delegate?.didTapShowCompletedButton(showCompletedButton)
    }
}
