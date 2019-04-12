//
//  BackgroundPictureViewController.swift
//  DogeTracker
//
//  Created by Philipp Pobitzer on 05.02.18.
//  Copyright © 2018 Philipp Pobitzer. All rights reserved.
//

import UIKit

class SameBackgroundWithCheckViewController: UIViewController {
    
    var background: UIImageView!
    var backgroundPicture: Int8 = -1 // Declares the current background picture
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addBackground()
        
    }
    
    func addBackground() {
        
        let defaults = UserDefaults.standard
        
        let logoSettings = defaults.object(forKey: "logo") as? Int8 ?? 0
        
        if backgroundPicture == -1 || logoSettings != backgroundPicture {
            
            if logoSettings == 1 && backgroundPicture == -1 { // no logo case with no old logo
                self.backgroundPicture = 1
                return
            } else if logoSettings == 1 && backgroundPicture != -1 { // no logo case with old logo
                self.background.removeFromSuperview()
                self.backgroundPicture = 1
                return
            }
            
            if backgroundPicture != -1 && backgroundPicture != 1 { // not init and there is a old background case
                self.background.removeFromSuperview()
                print("I got called")
            }
            
            self.background = {
                let theImageView = UIImageView()
                switch logoSettings { // a switch statement for future logo change function
                    
                default:
                    theImageView.image = UIImage(named: "Background")
                    self.backgroundPicture = 0
                }
                
                theImageView.translatesAutoresizingMaskIntoConstraints = false
                theImageView.alpha = CGFloat.init(0.0500000007450581)
                return theImageView
            }()
            
            self.view.addSubview(background)
            
            let aspectRatioConstraint = NSLayoutConstraint(item: background!, attribute: .height,relatedBy: .equal, toItem: background, attribute: .width, multiplier: 1, constant: 0)
            background.addConstraint(aspectRatioConstraint)
            
            //view.addConstraint(NSLayoutConstraint(item: someImageView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 16))
            view.addConstraint(NSLayoutConstraint(item: background!, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 16))
            
            background.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            background.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            
        }
    }
    
}

class SameBackgroundViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addBackground()
        
    }
    
    func addBackground() {
        
        let defaults = UserDefaults.standard
        
        let logoSettings = defaults.object(forKey: "logo") as? Int8 ?? 0
        
        if logoSettings == 1 {
            return
        }
        
        let background: UIImageView = {
            let theImageView = UIImageView()
            switch logoSettings { // a switch statement for future logo change function
                
            default:
                theImageView.image = UIImage(named: "Background")
            }
            
            theImageView.translatesAutoresizingMaskIntoConstraints = false
            theImageView.alpha = CGFloat.init(0.0500000007450581)
            return theImageView
        }()
        
        self.view.addSubview(background)
        
        let aspectRatioConstraint = NSLayoutConstraint(item: background, attribute: .height,relatedBy: .equal, toItem: background, attribute: .width, multiplier: 1, constant: 0)
        background.addConstraint(aspectRatioConstraint)
        
        //view.addConstraint(NSLayoutConstraint(item: someImageView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 16))
        view.addConstraint(NSLayoutConstraint(item: background, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 16))
        
        background.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        background.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
    }
}

