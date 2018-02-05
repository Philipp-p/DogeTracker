//
//  CoinMarketViewController.swift
//  DogeTracker
//
//  Created by Philipp Pobitzer on 02.01.18.
//  Copyright © 2018 Philipp Pobitzer. All rights reserved.
//

import UIKit

class CoinMarketViewController: SameBackgroundViewController {
    
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
    let util = FormatUtil.shared
    
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
        self.fiatRateLabel.text = "\(self.market.getPrice()) \(self.market.getCurrencySymbol())"
        if #available(iOS 10.0, *) {
            self.btcRateLabel.text = String(format: "%.8f ₿", self.market.priceBTC)
        } else {
            self.btcRateLabel.text = String(format: "%.8f BTC", self.market.priceBTC)
        }
        
        let red = UIColor(red: 215/255, green: 25/255, blue: 28/255, alpha: 1)
        let green = UIColor(red: 26/255, green: 150/255, blue: 65/255, alpha: 1)
        
        let oneHourPer = self.market.percentChange1h
        if oneHourPer > 0 {
            self.oneHourPerLabel.textColor = green
        } else {
            self.oneHourPerLabel.textColor = red
        }
        oneHourPerLabel.text = "1 Hour: \(oneHourPer) %"
        
        let oneDayPer = self.market.percentChange24h
        if oneDayPer > 0 {
            self.oneDayPerLabel.textColor = green
        } else {
            self.oneDayPerLabel.textColor = red
        }
        oneDayPerLabel.text = "1 Day: \(oneDayPer) %"
        
        let sevenDayPer = self.market.percentChange7d
        if sevenDayPer > 0 {
            self.sevenDayPerLabel.textColor = green
        } else {
            self.sevenDayPerLabel.textColor = red
        }
        sevenDayPerLabel.text = "7 Days: \(sevenDayPer) %"
        
        self.marketCapLabel.text = "Market cap: \(self.util.formatToInt(toFormat: self.market.marketCap)) \(self.market.getCurrencySymbol())"
        self.volume24hLabel.text = "Volume 24h: \(self.util.formatToInt(toFormat: self.market.Volume24h)) \(self.market.getCurrencySymbol())"
        self.totalSupplyLabel.text = "Total supply: \(self.util.formatToInt(toFormat: self.market.totalSupply))"
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
