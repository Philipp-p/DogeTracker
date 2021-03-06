//
//  SettingsTabelTableViewController.swift
//  DogeTracker
//
//  Created by Philipp Pobitzer on 19.01.18.
//  Copyright © 2018 Philipp Pobitzer. All rights reserved.
//

import UIKit

class SettingsTabelTabelViewController: UITableViewController {
    
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var formatLabel: UILabel!
    @IBOutlet weak var logoSwitch: UISwitch!
    @IBOutlet weak var versionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        displayCurrentSettings()
        versionLabel.text = version()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func version() -> String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        return "\(version) build \(build)"
    }
    
    func displayCurrentSettings() {
        let defaults = UserDefaults.standard
        
        let currency = defaults.object(forKey: "currency") as? String ?? "USD"
        self.currencyLabel.text = currency
        
        let format = defaults.object(forKey: "format") as? Int ?? 0
        self.formatLabel.text = FormatUtil.shared.getAllFormats()[format]
        
        let logo = defaults.object(forKey: "logo") as? Int8 ?? 0
        if (logo != 1) {
            self.logoSwitch.isOn = true
        } else {
            self.logoSwitch.isOn = false
        }
    }
    
    @IBAction func switchToggled(_ sender: UISwitch) {
        let defaults = UserDefaults.standard
        
        if self.logoSwitch.isOn {
            defaults.set(0, forKey: "logo")
        } else {
            defaults.set(1, forKey: "logo")
        }
    }
    
}
