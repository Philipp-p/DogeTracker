//
//  CoinMarketCapModel.swift
//  DogeTracker
//
//  Created by Philipp Pobitzer on 01.01.18.
//  Copyright © 2018 Philipp Pobitzer. All rights reserved.
//

import Foundation

// Uses the CoinMarketCap JSON API Documentation Version 1
class CoinMarketCap {
    private var currency: Currency // private because when you change it it needs to be invalidated
    let coin: String
    
    //response mapping
    var success = false
    var price: Double
    var priceBTC: Double
    var Volume24h: Double
    var marketCap: Double
    var availableSupply: u_long
    var totalSupply: u_long
    var maxSupply: u_long?
    var percentChange1h: Float
    var percentChange24h: Float
    var percentChange7d: Float
    var lastUpdate: time_t
    
    
    private init() {
        self.coin = "dogecoin"
        self.currency = Currency.USD
        
         self.price = 0
         self.priceBTC = 0
         self.Volume24h = 0
         self.marketCap = 0
         self.availableSupply = 0
         self.totalSupply = 0
         self.maxSupply = nil
         self.percentChange1h = 0
         self.percentChange24h = 0
         self.percentChange7d = 0
         self.lastUpdate = time_t()
    }
    
    static let shared = CoinMarketCap()
    
    func setCurrency(currency: Currency) {
        self.currency = currency
        self.success = false
    }
    
    //TODO get currencies symbol
    func getCurrencySymbol() -> String{
       return currency.getSymbol()
    }
    
    private func getApiUrl () -> String {
        return "https://api.coinmarketcap.com/v1/ticker/\(self.coin)/?convert=\(currency.rawValue)"
    }
    
    // function to udata balance with callback
    func update(completionHandler: @escaping (Bool, String) -> Void) {
        let urlAddress = self.getApiUrl()
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
                    // Convert NSDArray to [Dictionary] where keys are of type String, and values are of any type
                    let jsonArray = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! [Dictionary<String, AnyObject>]
                    print(jsonArray)
                    //get first (and only Dictionary)
                    let json = jsonArray.first!
                    
                    if (json["id"] != nil) {
                        //self.balance = Double(json["balance"] as! String)!
                        
                        self.price = Double(json["price_\(self.currency.rawValue.lowercased())"] as! String)!
                        self.priceBTC = Double(json["price_btc"] as! String)!
                        self.Volume24h = Double(json["24h_volume_\(self.currency.rawValue.lowercased())"] as! String)!
                        self.marketCap = Double(json["market_cap_\(self.currency.rawValue.lowercased())"] as! String)!
                        self.availableSupply = u_long(json["available_supply"] as! String)!
                        self.totalSupply = u_long(json["total_supply"] as! String)!
                        if (json["max_supply"] is NSNull) {
                            self.maxSupply = nil
                        } else {
                            self.maxSupply = u_long(json["max_supply"] as! String)!
                        }
                        self.percentChange1h = Float(json["percent_change_1h"] as! String)!
                        self.percentChange24h = Float(json["percent_change_24h"] as! String)!
                        self.percentChange7d = Float(json["percent_change_7d"] as! String)!
                        self.lastUpdate = time_t(json["last_updated"] as! String)!
                        
                        
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


enum Currency: String {
    case AUD, BRL, CAD, CHF, CLP, CNY, CZK, DKK, EUR, GBP, HKD, HUF, IDR, ILS, INR, JPY, KRW, MXN, MYR, NOK, NZD, PHP, PKR, PLN, RUB, SEK, SGD, THB, TRY, TWD, USD, ZAR
    
    static func getAllCurrencies() -> [String] {
        return ["AUD", "BRL", "CAD", "CHF", "CLP", "CNY", "CZK", "DKK", "EUR", "GBP", "HKD", "HUF", "IDR", "ILS", "INR", "JPY", "KRW", "MXN", "MYR", "NOK", "NZD", "PHP", "PKR", "PLN", "RUB", "SEK", "SGD", "THB", "TRY", "TWD", "USD", "ZAR"]
    }
    
    func getSymbol() -> String {
        switch self {
        case .AUD:
            return "A$"
        case .BRL:
            return "R$"
        case .CAD:
            return "C$"
        case .CHF:
            return "CHF"
        case .CLP:
            return "$"
        case .CNY:
            return "￥"
        case .CZK:
            return "Kč"
        case .DKK:
            return "kr."
        case .EUR:
            return "€"
        case .GBP:
            return "£"
        case .HKD:
            return "HK$"
        case .HUF:
            return "Ft"
        case .IDR:
            return "Rp"
        case .ILS:
            return "₪"
        case .INR:
            return "₹"
        case .JPY:
            return "¥"
        case .KRW:
            return "₩"
        case .MXN:
            return "Mex$"
        case .MYR:
            return "RM"
        case .NOK:
            return "kr"
        case .NZD:
            return "NZ$"
        case .PHP:
            return "₱"
        case .PKR:
            return "₨"
        case .PLN:
            return "zł"
        case .RUB:
            return "₽"
        case .SEK:
            return "kr"
        case .SGD:
            return "S$"
        case .THB:
            return "฿"
        case .TRY:
            return "₺"
        case .TWD:
            return "NT$"
        case .USD:
            return "$"
        case .ZAR:
            return "R"
        }
    }
}
