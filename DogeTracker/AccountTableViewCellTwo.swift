//
//  AccountTableViewCellTwo.swift
//  DogeTracker
//
//  Created by Philipp Pobitzer on 27.12.17.
//  Copyright © 2017 Philipp Pobitzer. All rights reserved.
//

import UIKit

class AccountTableViewCellTwo: UITableViewCell {
    
    @IBOutlet weak var nameOrAddressLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
