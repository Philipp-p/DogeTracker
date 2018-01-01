//
//  AccountDetailViewController.swift
//  DogeTracker
//
//  Created by Philipp Pobitzer on 28.12.17.
//  Copyright © 2017 Philipp Pobitzer. All rights reserved.
//

import UIKit

class AccountDetailViewController: UIViewController {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var balance: UILabel!
    @IBOutlet weak var qrButton: UIButton!
    
    weak var account: DogeAccount?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let refreshButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.refresh, target: self, action: #selector(reload))
        let editButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.edit, target: self, action: #selector(edit))
        self.navigationItem.setRightBarButtonItems([refreshButton, editButton], animated: true)
        
        prepareView()
    }
    
    fileprivate func prepareView() {
        let name = self.account?.getName()
        
        if name != nil {
            self.name.text = name
            self.address.text = self.account?.getAddress()
            self.address.isHidden = false
        } else {
            self.address.isHidden = true
            self.name.text = self.account?.getAddress()
        }
        
        if (account?.getBalance() ?? 0 == -1 || account?.getSuccess() ?? true != true) {
            self.balance.text = "Pending balance"
            account?.updateBalance() { success, error in
                DispatchQueue.main.async {
                    if success {
                        self.balance.text = "\(self.account?.getBalance() ?? 0) Ð"
                    } else {
                        self.balance.text = error
                    }
                }
            }
        } else {
            self.balance.text = "\(account?.getBalance() ?? 0) Ð"
        }
    }
    
    @IBAction func delete (sender: UIButton) {
        if self.account != nil {
            let refreshAlert = UIAlertController(
                title: "Delete",
                message: "Are you sure you want to delete this account?",
                preferredStyle: UIAlertControllerStyle.alert
            )
            
            refreshAlert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (action: UIAlertAction!) in
                AccountModel.shared.removeAccount(account: self.account!)
                //dissmis view
                self.navigationController?.popViewController(animated: true)
                //refresh tabel view in accounts
                NotificationCenter.default.post(name: Notification.Name(rawValue: "load"), object: nil)
                
            }))
            
            refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            }))
            
            present(refreshAlert, animated: true, completion: nil)
        }
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func reload() {
        if self.account != nil {
            self.balance.text = "Pending balance"
            account!.updateBalance() { success, error in
                DispatchQueue.main.async {
                    if success {
                        self.balance.text = "\(self.account!.getBalance()) Ð"
                    } else {
                        self.balance.text = error
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
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

