//
//  accountModel.swift
//  DogeTracker
//
//  Created by Philipp Pobitzer on 22.12.17.
//  Copyright © 2017 Philipp Pobitzer. All rights reserved.
//

import CoreData
import UIKit

class AccountModel {
    private var allAccounts: [DogeAccount]
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context: NSManagedObjectContext
    
    
    
    private init() {
        context = appDelegate.persistentContainer.viewContext
        context.undoManager = nil // undo functionallity not needed
        self.allAccounts = AccountModel.getAllAccountFromCoreData(context: context)
    }
    
    static let shared = AccountModel()
    
    func isUniqueAddress(address: String) -> Bool {
        
        for account in allAccounts {
            if account.getAddress() == address {
                return false
            }
        }
        
        return true
    }
    
    func getAccountFromCoreData(_ address: String) -> Account? {
        
        let accountFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Account")
        accountFetch.fetchLimit = 1
        accountFetch.predicate = NSPredicate(format: "address = %@", address)
        
        
        do {
            let result = try context.fetch(accountFetch)
            
            let resultAccount: Account = result.first as! Account
            print("Address: \(resultAccount.address!)")
            return resultAccount
        } catch {
            print("Could not retriev. \(error), \(error.localizedDescription)")
            return nil
        }
    }
    
    func addNewAccount(address: String, name: String?) {
        
        let entity = NSEntityDescription.entity(forEntityName: "Account", in: context)
        let newAccount = NSManagedObject(entity: entity!, insertInto: context)
        
        newAccount.setValue(address, forKey: "address")
        newAccount.setValue(name, forKey: "name")
        
        do {
            try context.save()
            self.allAccounts.append(DogeAccount(address: address, name: name))
        } catch {
            print("Could not save. \(error), \(error.localizedDescription)")
        }
    }
    
    func updateAccount(oldAccount: DogeAccount, address: String, name: String?) {
        
        let oldAccountCoreData = getAccountFromCoreData(oldAccount.getAddress())!
        
        do {
            print("oldname: \(oldAccount.getName() ?? "nil")")
            oldAccountCoreData.setValue(address, forKey: "address")
            oldAccountCoreData.setValue(name, forKey: "name")
            
            try context.save()
            
            
            oldAccount.setName(name: name)
            print("newname: \(oldAccount.getName() ?? "nil")")
            oldAccount.setAddress(address: address)
            if (oldAccount.getAddress() != address) {
                oldAccount.setSuccess(success: false)
            }
            
        } catch {
            print("Could not update. \(error), \(error.localizedDescription)")
        }
    }
    
    func updateAll () {
        
        self.allAccounts.forEach({account in
            account.updateBalance()
        })
    }
    
    func getAccountIndex (of: Int) -> DogeAccount{
        return self.allAccounts[of]
    }
    
    func removeAccount(account: DogeAccount) {
        
        let accountToDel = getAccountFromCoreData(account.getAddress())!
        
        context.delete(accountToDel)
        
        do {
            try context.save()
            self.allAccounts = self.allAccounts.filter {$0 != account}
        } catch {
            print("Could not save. \(error), \(error.localizedDescription)")
        }
        
    }
    
    func getAllAccount() -> [DogeAccount]{
        return self.allAccounts
    }
    
    private static func getAllAccountFromCoreData(context: NSManagedObjectContext) -> [DogeAccount] {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Account")
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            var resultArray = [DogeAccount]()
            for data in result as! [Account] {
                resultArray.append(DogeAccount(account: data))
            }
            return resultArray
            
        } catch {
            print("Could not get all. \(error), \(error.localizedDescription)")
            return [DogeAccount]()
        }
        
    }
    
    
}

class DogeAccount : Equatable {
    
    private var name: String?
    private var address: String
    private var balance: Double
    private var success: Bool
    
    init (account: Account) {
        self.address = account.address!
        self.name = account.name
        self.balance = -1
        self.success = false
        
    }
    
    init (address: String, name: String?) {
        self.address = address
        self.name = name
        self.balance = -1
        self.success = false
        
    }
    
    static func ==(lhs: DogeAccount, rhs: DogeAccount) -> Bool {
        return lhs.address == rhs.address && lhs.name == rhs.name
    }
    
    func getSuccess() -> Bool {
        return self.success
    }
    
    func setSuccess(success: Bool) {
        self.success = success
    }
    
    fileprivate func setAddress(address: String) {
        self.address = address
    }
    
    fileprivate func setName(name: String?) {
        self.name = name
    }
    
    func getBalance() -> Double {
        return self.balance
    }
    
    func getAddress() -> String {
        return self.address
    }
    
    func getName() -> String? {
        return self.name
    }
    
    func updateBalance() {
        let urlAddress = "https://dogechain.info/api/v1/address/balance/" + self.getAddress()
        // Asynchronous Http call to your api url, using NSURLSession:
        guard let url = URL(string: urlAddress) else {
            print("Url conversion issue.")
            return
        }
        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) -> Void in
            // Check if data was received successfully
            if error == nil && data != nil {
                do {
                    // Convert NSData to Dictionary where keys are of type String, and values are of any type
                    let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String:AnyObject]
                    print(json)
                    if json["success"] as! Int != 0 {
                        self.balance = Double(json["balance"] as! String)!
                        self.success = true
                    } else {
                        self.success = false
                    }
                    // let str = json["key"] as! String
                } catch {
                    print(error)
                    // Something went wrong
                }
            }
            else if error != nil {
                print(error!)
            }
        }).resume()
    }
    
    // function to udata balance with callback
    func updateBalance(completionHandler: @escaping (Bool, String) -> Void) {
        let urlAddress = "https://dogechain.info/api/v1/address/balance/" + self.getAddress()
        // Asynchronous Http call to your api url, using NSURLSession:
        guard let url = URL(string: urlAddress) else {
            print("Url conversion issue.")
            return
        }
        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) -> Void in
            // Check if data was received successfully
            var out: String = ""
            if error == nil && data != nil {
                do {
                    // Convert NSData to Dictionary where keys are of type String, and values are of any type
                    let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String:AnyObject]
                    print(json)
                    
                    
                    if json["success"] as! Int != 0 {
                        self.balance = Double(json["balance"] as! String)!
                        self.success = true
                    } else {
                        self.success = false
                        out = json["error"] as! String
                    }
                    // let str = json["key"] as! String
                } catch {
                    print(error)
                    // Something went wrong
                }
            }
            else if error != nil {
                print(error!)
            }
            
            let success = (error == nil) && self.success
            completionHandler(success, out)
            
        }).resume()
    }
    
    
}
