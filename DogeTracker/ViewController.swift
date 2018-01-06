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
    
    //Singeltons init to keep them always in memory
    let model = AccountModel.shared
    let market = CoinMarketCap.shared
    let util = FormatUtil.shared
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)        
        loadTotal()
    }
    
    fileprivate func updateMarketLabel(_ success: Bool) {
        DispatchQueue.main.async {
            if success {
                self.rateFIATLabel.text = "\(self.market.price) \(self.market.getCurrencySymbol())"
                if #available(iOS 10.0, *) {
                    self.rateBTCLabel.text = String(format: "%.8f ₿", self.market.priceBTC)
                } else {
                    self.rateBTCLabel.text = String(format: "%.8f BTC", self.market.priceBTC)
                }
                
            } else {
                self.errorRatesLabel.text = "Failed to get rates"
                self.errorRatesLabel.isHidden = false
                self.market.success = false //just to be sure
            }
        }
    }
    
    @IBAction func loadTotal() {
        //Setup
        errorRatesLabel.isHidden = true
        errorAccountsLabel.isHidden = true
        self.amountFIATLabel.text = nil
        self.rateBTCLabel.text = nil
        
        let allAccounts = model.getAllAccount()
        if allAccounts.count > 0 {
            self.amountCoinsLabel.text = "Pending balance"
        } else {
            self.amountCoinsLabel.text = "0.0 Ð"
            self.errorAccountsLabel.text = "There are no accounts"
            self.errorAccountsLabel.isHidden = false
            
            let market = CoinMarketCap.shared
            market.update() { success, error in
                self.updateMarketLabel(success)
            }
            return
        }
        
        let group = DispatchGroup()
        

        self.rateFIATLabel.text = "Pending rates"
        
        //market
        
        group.enter()
        market.update() { success, error in
            DispatchQueue.main.sync {
                self.updateMarketLabel(success)
                group.leave()
            }
        }
        
        //accounts
        var totalBalance: Double = 0
        var totalError: Int = 0
        
        
        for account in allAccounts {
            group.enter()
            account.updateBalance() { success, error in
                DispatchQueue.main.sync { // sync for thread safty
                    if success {
                        totalBalance += account.getBalance()
                        self.amountCoinsLabel.text = "\(self.util.formatDoubleWithMinPrecision(toFormat: totalBalance)) Ð"
                    } else {
                        totalError += 1
                        if (totalError > 1) {
                            self.errorAccountsLabel.text = "Errors in \(totalError) accounts"
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
                if self.market.success {
                    self.amountFIATLabel.text = "\(self.util.format(toFormat: totalBalance * self.market.price)) \(self.market.getCurrencySymbol())"
                }
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Load user settings for config
        let defaults = UserDefaults.standard
        
        let currency = defaults.object(forKey: "currency") as? String ?? "USD"
        market.setCurrency(currency: Currency(rawValue: currency) ?? Currency.USD)
        let format = defaults.object(forKey: "format") as? Int ?? 0
        util.setFormat(style: format)
        
        //TODO USEFULL
        
        
    }
    
    
    @IBAction func showAccounts(sender: UIButton) {
        performSegue(withIdentifier: "accounts", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

