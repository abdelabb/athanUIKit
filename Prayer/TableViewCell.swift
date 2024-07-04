//
//  TableViewCell.swift
//  Prayer
//
//  Created by abbas on 03/07/2024.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet var prayerName: UILabel!
    @IBOutlet var prayerTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
