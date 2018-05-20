//
//  AccountDetailViewController.swift
//  DogeTracker
//
//  Created by Philipp Pobitzer on 28.12.17.
//  Copyright © 2017 Philipp Pobitzer. All rights reserved.
//

import UIKit

class AccountDetailViewController: SameBackgroundViewController {
    
    @IBOutlet weak var nameLabel: CopyableLabel!
    @IBOutlet weak var addressLabel: CopyableLabel!
    @IBOutlet weak var balanceLabel: CopyableLabel!
    @IBOutlet weak var fiatBalanceLabel: CopyableLabel!
    
    
    
    @IBOutlet weak var qrButton: UIButton!
    
    weak var account: DogeAccount?
    
    weak var refreshButton: UIBarButtonItem!
    let market = CoinMarketCap.shared
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let refreshButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.refresh, target: self, action: #selector(reload))
        self.refreshButton = refreshButton
        let editButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.edit, target: self, action: #selector(edit))
        self.navigationItem.setRightBarButtonItems([refreshButton, editButton], animated: true)
        
        prepareView()
    }
    
    fileprivate func setFiatWithDispatch() { //set amout of fiat
        DispatchQueue.main.async {
            let util = FormatUtil.shared
            self.fiatBalanceLabel.text = "\(util.format(toFormat: ((self.account?.getBalance() ?? 0)  * self.market.getPriceFiat()))) \(self.market.getCurrencySymbol())"
            self.refreshButton.isEnabled = true
        }
    }
    
    fileprivate func checkForMarket() {
        if !self.market.getSuccess() { //check for market
            self.market.update() { success, error in
                if success {
                    self.setFiatWithDispatch()
                } else {
                    DispatchQueue.main.async {
                        self.fiatBalanceLabel.text = "Error retrieving rates, but 1 Ð = 1 Ð"
                        self.refreshButton.isEnabled = true
                    }
                }
            }
        } else {
            self.setFiatWithDispatch()
        }
    }
    
    fileprivate func prepareView() { //initial setup of the view
        let name = self.account?.getName()
        self.refreshButton.isEnabled = false
        
        self.fiatBalanceLabel.text = ""
        
        if name != nil {
            self.nameLabel.text = name
            self.addressLabel.text = self.account?.getAddress()
            self.addressLabel.isHidden = false
        } else {
            self.addressLabel.isHidden = true
            self.nameLabel.text = self.account?.getAddress()
        }
        
        if (account?.getBalance() ?? 0 == -1 || account?.getSuccess() ?? true != true) { //account not succesful
            self.balanceLabel.text = "Pending balance"
            account?.updateBalance() { success, error in
                DispatchQueue.main.async {
                    if success {
                        self.balanceLabel.text = "\(FormatUtil.shared.formatDoubleWithMinPrecision(toFormat: (self.account?.getBalance() ?? 0))) Ð"
                        self.checkForMarket()
                        
                    } else {
                        self.balanceLabel.text = "Failed to get balance"
                        self.refreshButton.isEnabled = true
                    }
                }
            }
        } else { //acount successful
            self.balanceLabel.text = "\(FormatUtil.shared.formatDoubleWithMinPrecision(toFormat: (self.account?.getBalance() ?? 0))) Ð"
            
            checkForMarket()
            
        }
    }
    
    @IBAction func delete (sender: UIButton) { //delete current account
        if self.account != nil {
            let deleteAlert = UIAlertController(
                title: "Delete",
                message: "Are you sure you want to delete this account?",
                preferredStyle: UIAlertControllerStyle.alert
            )
            
            deleteAlert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (action: UIAlertAction!) in
                AccountModel.shared.removeAccount(account: self.account!)
                //dissmis view
                self.navigationController?.popViewController(animated: true)
            }))
            
            deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            }))
            
            present(deleteAlert, animated: true, completion: nil)
        }
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func reload() {
        self.refreshButton.isEnabled = false
        self.fiatBalanceLabel.text = ""
        if self.account != nil {
            self.balanceLabel.text = "Pending balance"
            self.market.setSuccess(newValue: false)
            account!.updateBalance() { success, error in
                DispatchQueue.main.async {
                    if success {
                        self.balanceLabel.text = "\(FormatUtil.shared.formatDoubleWithMinPrecision(toFormat: (self.account?.getBalance() ?? 0))) Ð"
                        self.checkForMarket()
                    } else {
                        self.balanceLabel.text = "Failed to get balance"
                        self.refreshButton.isEnabled = true
                    }
                }
            }
        }
    }
    
    @IBAction func viewQR (sender: UIButton) {
        if self.account != nil {
            performSegue(withIdentifier: "viewQRCode", sender: self)
        }
    }
    
    // MARK: - Navigation
    
    @objc func edit () {
        if self.account != nil {
            performSegue(withIdentifier: "edit", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "edit") {
            let targetController = segue.destination as! EditViewController
            targetController.oldAccount = account
        } else if (segue.identifier == "viewQRCode") {
            let targetController = segue.destination as! QRCodeViewController
            targetController.address = account!.getAddress()
        }
    }
    
}

