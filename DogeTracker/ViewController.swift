//
//  ViewController.swift
//  DogeTracker
//
//  Created by Philipp Pobitzer on 18.12.17.
//  Copyright © 2017 Philipp Pobitzer. All rights reserved.
//

import UIKit

//Global to disable print if not in DEBUG
func print(_ item: @autoclosure () -> Any, separator: String = " ", terminator: String = "\n") {
    #if DEBUG
        Swift.print(item(), separator:separator, terminator: terminator)
    #endif
}

class ViewController: UIViewController {
    
    @IBOutlet weak var amountCoinsLabel: UILabel!
    @IBOutlet weak var errorAccountsLabel: UILabel!
    
    @IBOutlet weak var amountFIATLabel: UILabel!
    
    @IBOutlet weak var rateFIATLabel: UILabel!
    @IBOutlet weak var rateBTCLabel: UILabel!
    @IBOutlet weak var errorRatesLabel: UILabel!
    
    
    
    var totalBalance: Double = 0
    var totalError: Int = 0
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)        
        loadTotal()
    }
    
    @objc func settings() {
        
    }
    
    @IBAction func loadTotal() {
        //Setup
        errorRatesLabel.isHidden = true
        errorAccountsLabel.isHidden = true
        self.amountFIATLabel.text = nil
        self.rateBTCLabel.text = nil
        
        let model = AccountModel.shared
        
        let allAccounts = model.getAllAccount()
        if allAccounts.count > 0 {
            self.amountCoinsLabel.text = "Pending balance"
        } else {
            self.amountCoinsLabel.text = "0.0 Ð"
            self.errorAccountsLabel.text = "There are no accounts"
            self.errorAccountsLabel.isHidden = false
            
            let market = CoinMarketCap.shared
            market.update() { success, error in
                DispatchQueue.main.sync {
                    if success {
                        self.rateFIATLabel.text = "\(market.price) \(market.getCurrencySymbol())"
                        self.rateBTCLabel.text = String(format: "%.8f ₿", market.priceBTC)
                        
                    } else {
                        self.errorRatesLabel.text = "Failed to get rates"
                        self.errorRatesLabel.isHidden = false
                        market.success = false //just to be sure
                    }
                }
            }
            return
        }
        
        let group = DispatchGroup()
        

        self.rateFIATLabel.text = "Pending rates"
        
        //market
        let market = CoinMarketCap.shared
        
        group.enter()
        market.update() { success, error in
            DispatchQueue.main.sync {
                if success {
                    self.rateFIATLabel.text = "\(market.price) \(market.getCurrencySymbol())"
                    self.rateBTCLabel.text = String(format: "%.8f ₿", market.priceBTC)
                    
                } else {
                    self.errorRatesLabel.text = "Failed to get rates"
                    self.errorRatesLabel.isHidden = false
                    market.success = false //just to be sure
                }
                group.leave()
            }
        }
        
        //accounts
        totalBalance = 0
        totalError = 0
        
        
        for account in allAccounts {
            group.enter()
            account.updateBalance() { success, error in
                DispatchQueue.main.sync { // sync for thread safty
                    if success {
                        self.totalBalance += account.getBalance()
                        self.amountCoinsLabel.text = "\(self.totalBalance) Ð"
                    } else {
                        self.totalError += 1
                        if (self.totalError > 1) {
                            self.errorAccountsLabel.text = "Errors in \(self.totalError) accounts"
                        } else {
                            self.errorAccountsLabel.text = "Error in one account"
                        }
                        self.errorAccountsLabel.isHidden = false
                    }
                    group.leave()
                }
            }
        }
        
        //Final stuff
        group.notify(queue: DispatchQueue.main) {
            DispatchQueue.main.async {
                if market.success {
                    self.amountFIATLabel.text = "\(self.totalBalance * market.price) \(market.getCurrencySymbol())"
                }
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let defaults = UserDefaults.standard
        let currency = defaults.object(forKey: "currency") as? String ?? "USD"
        CoinMarketCap.shared.setCurrency(currency: Currency(rawValue: currency) ?? Currency.USD)
    }
    
    
    @IBAction func showAccounts(sender: UIButton) {
        performSegue(withIdentifier: "accounts", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

