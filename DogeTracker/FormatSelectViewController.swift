//
//  FormatSelectViewController.swift
//  DogeTracker
//
//  Created by Philipp Pobitzer on 03.01.18.
//  Copyright © 2018 Philipp Pobitzer. All rights reserved.
//

import UIKit

class FormatSelectViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    
    @IBOutlet weak var formatTable: UITableView!
    let allFormats = FormatUtil.shared.getAllFormats()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.formatTable.delegate = self
        self.formatTable.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allFormats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "formatCell")
        
        cell?.textLabel?.text = allFormats[indexPath.row]
        cell?.textLabel?.textAlignment = .center
        
        return cell ?? UITableViewCell()
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Get Cell row
        let indexPathRow = tableView.indexPathForSelectedRow!.row
        
        let defaults = UserDefaults.standard
        defaults.set(indexPathRow, forKey: "format")
        
        FormatUtil.shared.setFormat(style: indexPathRow)
        
        navigationController?.popViewController(animated: true)
    }
    
}
