//
//  CoinMarketViewController.swift
//  DogeTracker
//
//  Created by Philipp Pobitzer on 02.01.18.
//  Copyright © 2018 Philipp Pobitzer. All rights reserved.
//

import UIKit

class CoinMarketViewController: UIViewController {
    
    @IBOutlet weak var fiatRateLabel: UILabel!
    @IBOutlet weak var btcRateLabel: UILabel!
    @IBOutlet weak var oneHourPerLabel: UILabel!
    @IBOutlet weak var oneDayPerLabel: UILabel!
    @IBOutlet weak var sevenDayPerLabel: UILabel!
    
    @IBOutlet weak var marketCapLabel: UILabel!
    @IBOutlet weak var volume24hLabel: UILabel!
    @IBOutlet weak var totalSupplyLabel: UILabel!
    @IBOutlet weak var maxSupplyLabel: UILabel!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    let market = CoinMarketCap.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !self.market.success {
            reload()
        } else {
            updateLabels()
        }

        // Do any additional setup after loading the view.
    }
    
    fileprivate func updateLabels () {
        self.fiatRateLabel.text = "\(self.market.price) \(self.market.getCurrencySymbol())"
        self.btcRateLabel.text = String(format: "%.8f ₿", self.market.priceBTC)
        
        let oneHourPer = self.market.percentChange1h
        if oneHourPer > 0 {
            self.oneHourPerLabel.textColor = UIColor.green
        } else {
            self.oneHourPerLabel.textColor = UIColor.red
        }
        oneHourPerLabel.text = "1 Hour: \(oneHourPer) %"
        
        let oneDayPer = self.market.percentChange24h
        if oneDayPer > 0 {
            self.oneDayPerLabel.textColor = UIColor.green
        } else {
            self.oneDayPerLabel.textColor = UIColor.red
        }
        oneDayPerLabel.text = "1 Day: \(oneDayPer) %"
        
        let sevenDayPer = self.market.percentChange7d
        if sevenDayPer > 0 {
            self.sevenDayPerLabel.textColor = UIColor.green
        } else {
            self.sevenDayPerLabel.textColor = UIColor.red
        }
        sevenDayPerLabel.text = "7 Days: \(sevenDayPer) %"
        
        self.marketCapLabel.text = "Market cap: \(self.market.marketCap) \(self.market.getCurrencySymbol())"
        self.volume24hLabel.text = "Volume 24h: \(self.market.Volume24h) \(self.market.getCurrencySymbol())"
        self.totalSupplyLabel.text = "Total supply: \(self.market.totalSupply)"
        let maxSupply: String
        if self.market.maxSupply != nil {
            maxSupply = String(self.market.maxSupply!)
        } else {
            maxSupply = "Unlimited"
        }
        self.maxSupplyLabel.text = "Max supply: \(maxSupply)"
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let refreshButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.refresh, target: self, action: #selector(reload))
        self.navigationItem.setRightBarButton(refreshButton, animated: true)
        
    }
    
    @objc func reload() {
        
        errorLabel.isHidden = true
        
        fiatRateLabel.text = "Pending"
        btcRateLabel.text = nil
        oneHourPerLabel.text = nil
        oneDayPerLabel.text = nil
        sevenDayPerLabel.text = nil
        
        marketCapLabel.text = nil
        volume24hLabel.text = nil
        totalSupplyLabel.text = nil
        maxSupplyLabel.text = nil
        
        market.update() { success, error in
            if success {
                DispatchQueue.main.async {
                    self.updateLabels()
                }
            } else {
                DispatchQueue.main.async {
                    self.errorLabel.text = "Failed to get data"
                    self.errorLabel.isHidden = false
                    
                    self.fiatRateLabel.text = "1 Ð = 1 Ð"
                    
                }
                
            }
            
        }
        
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
