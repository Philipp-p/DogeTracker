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
    private var price: Double //private as setup for future upate for more currencies
    var priceBTC: Double
    var Volume24h: Double
    var marketCap: Double
    var availableSupply: Double
    var totalSupply: Double
    var maxSupply: Double?
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
    
    func getPrice() -> Double {
        return self.price
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
                        self.availableSupply = Double(json["available_supply"] as! String)!
                        self.totalSupply = Double(json["total_supply"] as! String)!
                        if (json["max_supply"] is NSNull) {
                            self.maxSupply = nil
                        } else {
                            self.maxSupply = Double(json["max_supply"] as! String)!
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

class FormatUtil {
    var styleGrouping = ","
    var styleDecimal = "."
    let minPrecision = 8
    
    let allFormats = ["1,000.00", "1.000,00", "1 000.00", "1 000,00", "1000.00", "1000,00"]
    
    private init() {
    }
    
    static let shared = FormatUtil()
    
    func getAllFormats() -> [String] {
        return allFormats
    }
    
    func setFormat(style: Int) {
        switch style {
        case 0:
            self.styleGrouping = ","
            self.styleDecimal = "."
        case 1:
            self.styleGrouping = "."
            self.styleDecimal = ","
        case 2:
            self.styleGrouping = " "
            self.styleDecimal = "."
        case 3:
            self.styleGrouping = " "
            self.styleDecimal = ","            
        case 4:
            self.styleGrouping = ""
            self.styleDecimal = "."
        case 5:
            self.styleGrouping = ""
            self.styleDecimal = ","
        default:
            self.styleGrouping = ","
            self.styleDecimal = "."
        }
    }
    
    func formatToInt(toFormat: Double) -> String {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = styleGrouping
        formatter.numberStyle = .decimal
        
        let testConvert = Int64(toFormat)
        return formatter.string(from: (NSNumber(value: testConvert))) ?? ""
    }
    
    func formatULong(toFormat: u_long) -> String {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = styleGrouping
        formatter.numberStyle = .decimal
        
        return formatter.string(from: (NSNumber(value: toFormat))) ?? ""
    }
    
    func format(toFormat: Double) -> String {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = styleGrouping
        formatter.decimalSeparator = styleDecimal
        formatter.numberStyle = .decimal
        
        return formatter.string(from: (NSNumber(value: toFormat))) ?? ""
    }
    
    func formatDoubleWithMinPrecision(toFormat: Double) -> String {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = styleGrouping
        formatter.decimalSeparator = styleDecimal
        formatter.numberStyle = .decimal
        
        formatter.minimumFractionDigits = minPrecision
        
        return formatter.string(from: (NSNumber(value: toFormat))) ?? ""
        
    }
    
}

