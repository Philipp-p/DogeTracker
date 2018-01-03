//
//  CurrencySelectViewController.swift
//  DogeTracker
//
//  Created by Philipp Pobitzer on 02.01.18.
//  Copyright © 2018 Philipp Pobitzer. All rights reserved.
//

import UIKit

class CurrencySelectViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var currencyPicker: UIPickerView!
    let allCurrencies = ["AUD", "BRL", "CAD", "CHF", "CLP", "CNY", "CZK", "DKK", "EUR", "GBP", "HKD", "HUF", "IDR", "ILS", "INR", "JPY", "KRW", "MXN", "MYR", "NOK", "NZD", "PHP", "PKR", "PLN", "RUB", "SEK", "SGD", "THB", "TRY", "TWD", "USD", "ZAR"]
    
    var selectedCurrency:String = "AUD" //Needs this init since AUD is start value and slection doesn't trigger at start
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.currencyPicker.dataSource = self;
        self.currencyPicker.delegate = self;
        
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
        self.navigationItem.setRightBarButton(saveButton, animated: true)
        

        // Do any additional setup after loading the view.
    }
    
    @objc func save () {
        let defaults = UserDefaults.standard
        defaults.set(self.selectedCurrency, forKey: "currency")
        CoinMarketCap.shared.setCurrency(currency: Currency(rawValue: self.selectedCurrency) ?? Currency.USD)
        
        navigationController?.popViewController(animated: true)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedCurrency = self.allCurrencies[row]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return allCurrencies.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return allCurrencies[row]
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
