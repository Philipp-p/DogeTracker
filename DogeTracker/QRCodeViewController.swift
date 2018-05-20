//
//  QRCodeViewController.swift
//  DogeTracker
//
//  Created by Philipp Pobitzer on 29.12.17.
//  Copyright © 2017 Philipp Pobitzer. All rights reserved.
//

import UIKit

class QRCodeViewController: UIViewController {
    
    @IBOutlet weak var qrImage: UIImageView!
    var address: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        qrImage.image = generateQRCode(from: address)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        
        return nil
    }
}

