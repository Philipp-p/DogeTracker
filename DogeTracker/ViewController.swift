//
//  ViewController.swift
//  DogeTracker
//
//  Created by Philipp Pobitzer on 18.12.17.
//  Copyright © 2017 Philipp Pobitzer. All rights reserved.
//

import UIKit

//Global to disable print if not in DEBUG
func print(_ items: Any...) {
    #if DEBUG
        Swift.print(items[0])
    #endif
}

class ViewController: UIViewController {
    
    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    
    
    var totalBalance: Double = 0
    var totalError: Int = 0
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let reloadButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(loadTotal))
        self.navigationItem.rightBarButtonItem = reloadButton
        
        loadTotal()
    }
    
    @objc func loadTotal() {
        errorLabel.isHidden = true
        let model = AccountModel.shared
        
        let allAccounts = model.getAllAccount()
        if allAccounts.count > 0 {
            self.displayLabel.text = "Pending balance"
        } else {
            self.displayLabel.text = "0.0 Ð"
            self.errorLabel.text = "There are no accounts"
            self.errorLabel.isHidden = false
            return
        }
        
        totalBalance = 0
        totalError = 0
        
        
        for account in allAccounts {
            account.updateBalance() { success, error in
                DispatchQueue.main.sync { // sync for thread safty
                    if success {
                        self.totalBalance += account.getBalance()
                        self.displayLabel.text = "\(self.totalBalance) Ð"
                    } else {
                        self.totalError += 1
                        if (self.totalError > 1) {
                            self.errorLabel.text = "Errors in \(self.totalError) accounts"
                        } else {
                            self.errorLabel.text = "Error in one account"
                        }
                        self.errorLabel.isHidden = false
                        
                    }
                }
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    @IBAction func showAccounts(sender: UIButton) {
        performSegue(withIdentifier: "accounts", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

