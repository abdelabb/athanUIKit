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
     let notificationImageView = UIImageView()
    var modeSelect: NotificationMode!
    
    @IBOutlet weak var notificationButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        let currentMode: NotificationMode = .silencieux
//        let currentMode = NotificationMode.desactiver
//                updateNotifMode(for: currentMode)
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
     

    }
    var modeSound: [UIAction]{
        return [
            UIAction(title: "normal", image: UIImage(systemName: "speaker.wave.3.fill"), handler: { _ in
                self.updateNotifMode(for: .normal)

            }),
            UIAction(title: "silencieux", image: UIImage(systemName: "speaker.slash.fill"), handler: { _ in
                self.updateNotifMode(for: .silencieux)

            }),
            UIAction(title: "desactiver", image: UIImage(systemName: "speaker.fill"), handler: { _ in
                self.updateNotifMode(for: .desactiver)

            })
        ]
    }
    
    var demoMenu: UIMenu {
        return UIMenu(title: "Sound menu", image: nil, identifier: nil, options: [], children: modeSound)
    }
    
    @IBAction func modeSelected(_ sender: UIButton) {

        notificationButton.menu = demoMenu
        notificationButton.showsMenuAsPrimaryAction = true
        
        
      
       
       }
    func updateNotifMode(for mode: NotificationMode){
        let iconName: String
        switch mode {
        case .normal:
            iconName = "speaker.wave.3.fill"
        case .silencieux:
            iconName = "speaker.slash.fill"
        case .desactiver:
        iconName = "speaker.fill"
        }
        //notificationImageView.image = UIImage(systemName: iconName)
        notificationButton.setImage(UIImage(systemName: iconName), for: .normal)

    }
}
