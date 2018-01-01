//
//  AccountsViewController.swift
//  DogeTracker
//
//  Created by Philipp Pobitzer on 27.12.17.
//  Copyright © 2017 Philipp Pobitzer. All rights reserved.
//

import UIKit

class AccountsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var table: UITableView!
    //let model = AccountModel.shared
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let addButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(add))
        let refreshButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.refresh, target: self, action: #selector(reloadTable))
        self.navigationItem.setRightBarButtonItems([refreshButton, addButton], animated: true)
        loadList()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // deselect the selected row
        let selectedRow: IndexPath? = table.indexPathForSelectedRow
        if let selectedRowNotNill = selectedRow {
            table.deselectRow(at: selectedRowNotNill, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "load"), object: nil, queue: nil, using: loadList)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        
        table.refreshControl = refreshControl
    }
    
    @objc func add() {
        performSegue(withIdentifier: "add", sender: self)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AccountModel.shared.getAllAccount().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let allAccounts = AccountModel.shared.getAllAccount()
        
        let cell = table.dequeueReusableCell(withIdentifier: "accountCellTwo", for: indexPath) as! AccountTableViewCellTwo
        
        let account = allAccounts[indexPath.row]
        
        if account.getName() != nil {
            cell.nameOrAddressLabel.text = allAccounts[indexPath.row].getName()
        } else {
            cell.nameOrAddressLabel.text = allAccounts[indexPath.row].getAddress()
        }
        
        cell.balanceLabel.text = "Pending balance"
        
        if (account.getBalance() == -1 || account.getSuccess() != true) {
            account.updateBalance() { success, error in
                DispatchQueue.main.async {
                    if success {
                        cell.balanceLabel.text = "\(account.getBalance()) Ð"
                    } else {
                        cell.balanceLabel.text = error
                    }
                }
            }
        } else {
            cell.balanceLabel.text = "\(account.getBalance()) Ð"
        }
        
        return cell
    }
    
    var valueToPass: DogeAccount!
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Get Cell Label
        let indexPath = tableView.indexPathForSelectedRow!
        valueToPass = AccountModel.shared.getAllAccount()[indexPath.row]
        
        performSegue(withIdentifier: "accountDetail", sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "accountDetail") {
            let viewController = segue.destination as! AccountDetailViewController
            viewController.account = valueToPass
        }
    }
    
    @objc fileprivate func reloadTable() {
        for account in AccountModel.shared.getAllAccount() {
            account.setSuccess(success: false)
        }
        
        self.table.reloadData()
    }
    
    @objc func refresh(refreshControl: UIRefreshControl) {
        refreshControl.beginRefreshing()
        reloadTable()
        refreshControl.endRefreshing()
    }
    
    func loadList(){
        self.table.reloadData()
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

