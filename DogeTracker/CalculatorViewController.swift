//
//  CalculatorViewController.swift
//  DogeTracker
//
//  Created by Philipp Pobitzer on 19.01.18.
//  Copyright © 2018 Philipp Pobitzer. All rights reserved.
//

import UIKit

class CalculatorViewController: SameBackgroundWithCheckViewController, UITextFieldDelegate {

    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var switchButton: UIButton!
    var fiatToDoge: Bool = true
    
    let market = CoinMarketCap.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.inputTextField.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.switchButton.setTitle("\(market.getCurrencySymbol()) -> Ð", for: .normal)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //change calculation mode
    @IBAction func switchMode() {
        fiatToDoge = !fiatToDoge
        
        if fiatToDoge {
            self.switchButton.setTitle("\(market.getCurrencySymbol()) -> Ð", for: .normal)
        } else {
            self.switchButton.setTitle("Ð -> \(market.getCurrencySymbol())", for: .normal)
        }
    }
    
    @IBAction func refreshMarket() {
        self.errorLabel.isHidden = true
        self.refreshButton.isEnabled = false
        
        market.update() { success, error in
            if success {
                DispatchQueue.main.async {
                    self.refreshButton.isEnabled = true
                    self.updateResult()
                }
            } else {
                DispatchQueue.main.async {
                    self.refreshButton.isEnabled = true
                    self.resultLabel.text = "1 Ð = 1 Ð"
                    self.errorLabel.text = "Failed to get rates"
                    self.errorLabel.isHidden = false
                }
            }
        }
    }
    
    func updateResult() {
        self.errorLabel.isHidden = true
        guard let amount = Double(self.inputTextField.text!.replacingOccurrences(of: ",", with: ".")) else {
            self.errorLabel.text = "Invalid input"
            self.errorLabel.isHidden = false
            return
        }
        
        if fiatToDoge {
            let amountDoge = amount / market.getPriceFiat()
            self.resultLabel.text = "\(FormatUtil.shared.formatDoubleWithMinPrecision(toFormat: amountDoge)) Ð"
        } else {
            let amountFiat = amount * market.getPriceFiat()
            self.resultLabel.text = "\(FormatUtil.shared.format(toFormat: amountFiat)) \(market.getCurrencySymbol())"
        }
    }
    
    
    //touch to close keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
        if market.getSuccess() {
            updateResult()
        } else {
            self.refreshMarket()
        }
    }
    
    //Limit to a decimala either with . or , and 8 decimal digits
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = (textField.text ?? "") as NSString
        let newText = text.replacingCharacters(in: range, with: string)
        if let regex = try? NSRegularExpression(pattern: "^[0-9]*((\\.|,)[0-9]{0,8})?$", options: .caseInsensitive) {
            return regex.numberOfMatches(in: newText, options: .reportProgress, range: NSRange(location: 0, length: (newText as NSString).length)) > 0
        }
        return false
    }

}
