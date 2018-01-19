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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setLabels()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setLabels() {
        let defaults = UserDefaults.standard
        
        let currency = defaults.object(forKey: "currency") as? String ?? "USD"
        self.currencyLabel.text = currency
        
        let format = defaults.object(forKey: "format") as? Int ?? 0
        self.formatLabel.text = FormatUtil.shared.getAllFormats()[format]
    }



    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
