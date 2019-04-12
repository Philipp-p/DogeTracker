//
//  AddViewController.swift
//  DogeTracker
//
//  Created by Philipp Pobitzer on 27.12.17.
//  Copyright © 2017 Philipp Pobitzer. All rights reserved.
//

import UIKit
import AVFoundation


class AddViewController: SameBackgroundViewController, UITextFieldDelegate, QRScannerDelegate {
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var addressField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nameField.delegate = self
        self.addressField.delegate = self
        
        // Do any additional setup after loading the view.
    }
    
    func setAddress(address: String) {
        self.addressField.text = address
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let cameraButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.camera, target: self, action: #selector(cameraView))
        let safeButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.save, target: self, action: #selector(saveButton))
        self.navigationItem.setRightBarButtonItems([safeButton, cameraButton], animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelButtonTapped() {
        NotificationCenter.default.removeObserver(self)
        
        self.view.endEditing(true)
        navigationController?.popViewController(animated: true)
    }
    
    @objc func cameraView() {
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch authStatus {
        case .authorized:
            performSegue(withIdentifier: "cameraView", sender: self)
        case .denied:
            alertPromptToAllowCameraAccessViaSetting()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                if granted {
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "cameraView", sender: self)
                    }
                }
            })
        case .restricted:
            let alert = UIAlertController(
                title: "Sorry",
                message: "Your user is restriced from the camera",
                preferredStyle: UIAlertController.Style.alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            
        @unknown default:
            let alert = UIAlertController(
                title: "Sorry",
                message: "This should not happen, please report this",
                preferredStyle: UIAlertController.Style.alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        }
        
        
    }
    
    func alertPromptToAllowCameraAccessViaSetting() {
        
        let alert = UIAlertController(
            title: nil,
            message: "Camera access required for QR scanner!",
            preferredStyle: UIAlertController.Style.alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Allow Camera", style: .default, handler: { (alert) -> Void in
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            } else {
                UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    
    @objc func saveButton() {
        let model = AccountModel.shared
        //close keyboard
        self.view.endEditing(true)
        
        let address = self.addressField.text
        let name = self.nameField.text
        if address != nil && address != "" && model.isUniqueAddress(address: address!){
            if name != nil && name != "" {
                model.addNewAccount(address: address!, name: name)
            } else {
                model.addNewAccount(address: address!, name: nil)
            }
            
            navigationController?.popViewController(animated: true)
        } else {
            let alertController = UIAlertController(title: "Error", message: "Invalid address or address duplicate", preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
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
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? QRScannerViewController {
            destination.delegate = self
        }
    }
    
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
