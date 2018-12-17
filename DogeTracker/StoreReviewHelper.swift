//
//  StoreReviewHelper.swift
//  DogeTracker
//
//  Created by Philipp Pobitzer on 20.01.18.
//  Copyright © 2018 Philipp Pobitzer. All rights reserved.
//

import Foundation
import StoreKit
import UIKit

class StoreReviewHelper {
    static let appID: String = "id1331221523"
    
    static func incrementAppOpenedCount() { // called from appdelegate didfinishLaunchingWithOptions:
        guard var appOpenCount = UserDefaults.standard.value(forKey: "APP_OPENED_COUNT") as? Int else {
            UserDefaults.standard.set(1, forKey: "APP_OPENED_COUNT")
            return
        }
        appOpenCount += 1
        UserDefaults.standard.set(appOpenCount, forKey: "APP_OPENED_COUNT")
    }
    
    static func incrementAppOpenedCountTen() {
        guard var appOpenCount = UserDefaults.standard.value(forKey: "APP_OPENED_COUNT") as? Int else {
            UserDefaults.standard.set(1, forKey: "APP_OPENED_COUNT")
            return
        }
        appOpenCount += 10
        UserDefaults.standard.set(appOpenCount, forKey: "APP_OPENED_COUNT")
    }
    
    static func checkAndAskForReview(viewController: UIViewController) { // call this whenever appropriate
        // this will not be shown everytime. Apple has some internal logic on how to show this.
        guard let appOpenCount = UserDefaults.standard.value(forKey: "APP_OPENED_COUNT") as? Int else {
            UserDefaults.standard.set(1, forKey: "APP_OPENED_COUNT")
            return
        }
        
        switch appOpenCount {
        case _ where appOpenCount >= 15 && appOpenCount < 25:
            StoreReviewHelper.requestReview(viewController: viewController)
        case _ where appOpenCount >= 40 && appOpenCount < 50:
            StoreReviewHelper.requestReview(viewController: viewController)
        case _ where appOpenCount >= 90 && appOpenCount < 100:
            StoreReviewHelper.requestReview(viewController: viewController)
        case _ where appOpenCount >= 150:
            UserDefaults.standard.set(1, forKey: "APP_OPENED_COUNT")
        default:
            print("App run count: \(appOpenCount)")
        }
        
    }
    
    fileprivate static func requestReview(viewController: UIViewController) {
        incrementAppOpenedCountTen()//To make sure it doen't spam the request
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        } else {
            
            let deleteAlert = UIAlertController(
                title: nil,
                message: "If you like the app, do you want to rate it?",
                preferredStyle: UIAlertController.Style.alert
            )
            
            deleteAlert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
            
            deleteAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                rateApp(appId: appID) //DogeTracker app id
            }))
            
            viewController.present(deleteAlert, animated: true, completion: nil)
            //rateApp(appId: "id1331221523") //DogeTracker app id
        }
    }
    
    fileprivate static func rateApp(appId: String) {
        openUrl("itms-apps://itunes.apple.com/app/" + appId)
    }
    
    fileprivate static func openUrl(_ urlString:String) {
        let url = URL(string: urlString)!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
}
