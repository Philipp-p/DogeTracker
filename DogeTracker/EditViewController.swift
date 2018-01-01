//
//  EditViewController.swift
//  DogeTracker
//
//  Created by Philipp Pobitzer on 29.12.17.
//  Copyright © 2017 Philipp Pobitzer. All rights reserved.
//

import UIKit

class EditViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    
    var oldAccount: DogeAccount!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.nameField.delegate = self
        self.addressField.delegate = self
        
        let name = oldAccount.getName()
        if name != nil {
            self.nameField.text = name
        }
        
        self.addressField.text = oldAccount.getAddress()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelButton() {
        self.view.endEditing(true)
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveButton(_ sender: UIBarButtonItem) {
        let model = AccountModel.shared
        //close keyboard
        self.view.endEditing(true)
        
        let address = self.addressField.text
        let name = self.nameField.text
        
        if (address == oldAccount.getAddress() &&  name != oldAccount.getName()) || (address != nil && address != "" && address != oldAccount.getAddress()) {
            
            if (name != "") {
                model.updateAccount(oldAccount: oldAccount, address: address!, name: name)
            } else {
                model.updateAccount(oldAccount: oldAccount, address: address!, name: nil)
            }
            
            navigationController?.popViewController(animated: true)
            
        } else {
            let alertController = UIAlertController(title: "Error", message: "Invalid address or address duplicate", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
        
        
    }
    
    
    //touch to close keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    //return click
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
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

