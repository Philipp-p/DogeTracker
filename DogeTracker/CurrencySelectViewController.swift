//
//  CurrencySelectViewController.swift
//  DogeTracker
//
//  Created by Philipp Pobitzer on 02.01.18.
//  Copyright © 2018 Philipp Pobitzer. All rights reserved.
//

import UIKit

class CurrencySelectViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var currencyTableView: UITableView!
    
    let allCurrencies = Currency.getAllCurrencies()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.currencyTableView.delegate = self
        self.currencyTableView.dataSource = self
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allCurrencies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "currencyCell")
        
        cell?.textLabel?.text = allCurrencies[indexPath.row]
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
        let indexPath = tableView.indexPathForSelectedRow!
        
        let selectedCurrency: String = allCurrencies[indexPath.row]
        let defaults = UserDefaults.standard
        defaults.set(selectedCurrency, forKey: "currency")
        CoinMarketCap.shared.setCurrency(currency: Currency(rawValue: selectedCurrency) ?? Currency.USD)
        
        navigationController?.popViewController(animated: true)
    }
    
    
}
