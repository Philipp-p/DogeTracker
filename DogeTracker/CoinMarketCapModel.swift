//
//  CoinMarketCapModel.swift
//  DogeTracker
//
//  Created by Philipp Pobitzer on 01.01.18.
//  Copyright © 2018 Philipp Pobitzer. All rights reserved.
//

import Foundation

// Uses the CoinMarketCap JSON API Documentation Version 2
class CoinMarketCap {
    static let shared = CoinMarketCap()
    
    private var currency: Currency // private because when you change it it needs to be invalidated
    let coin: String
    let id: uint
    
    var responseFiat: CoinMarketCapV2?
    var quotesBTC: Quotes?
    
    //response mapping
    private var successFiat = false
    private var successBTC = false
    
    struct CoinMarketCapV2: Decodable {
        let data: Data?
        let metadata: MetaData
    }
    
    struct Data: Decodable {
        let id: uint
        let name: String
        let symbol: String
        let website_slug: String
        let rank: uint
        let circulating_supply: Double
        let total_supply: Double
        let max_supply: Double?
        let quotes: Dictionary<String,Quotes>
        let last_updated: time_t
    }
    
    struct Quotes: Decodable {
        let price: Double
        let volume_24h: Double
        let market_cap: Double
        let percent_change_1h: Double
        let percent_change_24h: Double
        let percent_change_7d: Double
        
    }
    
    struct MetaData: Decodable {
        let timestamp: time_t
        let error: String?
    }
    
    
    private init() {
        self.coin = "dogecoin"
        self.id = 74
        self.currency = Currency.USD
        
        self.responseFiat = nil
        self.quotesBTC = nil
    }
    
    func getSuccess() -> Bool {
        return successFiat && successBTC
    }
    
    func setSuccess(newValue: Bool) {
        self.successFiat = newValue
        self.successBTC = newValue
    }
    
    func getPriceFiat() -> Double {
        if successFiat {
            return responseFiat!.data!.quotes[self.currency.rawValue]!.price
        } else {
            return -1.0;
        }
    }
    
    func getPriceBTC() -> Double {
        if successBTC {
            return quotesBTC!.price
        } else {
            return -1.0;
        }
    }
    
    func getVolume24hFiat() -> Double {
        if successBTC {
            return responseFiat!.data!.quotes[self.currency.rawValue]!.volume_24h
            
        } else {
            return -1.0;
        }
    }
    
    func getMarketCap() -> Double {
        if successBTC {
            return responseFiat!.data!.quotes[self.currency.rawValue]!.price * responseFiat!.data!.total_supply
            
        } else {
            return -1.0;
        }
    }
    
    func getCirculatingSupply() -> Double {
        if successBTC {
            return responseFiat!.data!.circulating_supply
            
        } else {
            return -1.0;
        }
    }
    
    func getTotalSupply() -> Double {
        if successBTC {
            return responseFiat!.data!.total_supply
            
        } else {
            return -1.0;
        }
    }
    
    // nil indicates unlimited supply
    func getMaxSupply() -> Double? {
        if successBTC {
            return responseFiat!.data!.max_supply
            
        } else {
            return -1;
        }
    }
    
    
    func getPercentChange1hFiat() -> Double {
        if successFiat {
            return responseFiat!.data!.quotes[self.currency.rawValue]!.percent_change_1h
        } else {
            return -1.0;
        }
    }
    
    func getPercentChange24hFiat() -> Double {
        if successFiat {
            return responseFiat!.data!.quotes[self.currency.rawValue]!.percent_change_24h
        } else {
            return -1.0;
        }
    }
    
    func getPercentChange7dFiat() -> Double {
        if successFiat {
            return responseFiat!.data!.quotes[self.currency.rawValue]!.percent_change_7d
        } else {
            return -1.0;
        }
    }
    
    
    func setCurrency(currency: Currency) {
        self.currency = currency
        self.successFiat = false
        self.successBTC = false
    }
    
    func getCurrencySymbol() -> String{
        return currency.getSymbol()
    }
    
    private func getApiUrlFiat() -> String {
        return "https://api.coinmarketcap.com/v2/ticker/\(self.id)/?convert=\(currency.rawValue)"
    }
    
    private func getApiUrlBTC() -> String {
        return "https://api.coinmarketcap.com/v2/ticker/\(self.id)/?convert=BTC"
    }
    
    // function to update with callback
    func update(completionHandler: @escaping (Bool, String) -> Void) {
        let urlAddressFiat = self.getApiUrlFiat()
        let urlAddressBTC = self.getApiUrlBTC()
        
        let group = DispatchGroup.init()
        
        
        // Asynchronous Http call to your api url, using NSURLSession:
        guard let urlFiat = URL(string: urlAddressFiat) else {
            print("Url conversion issue.")
            return
        }
        group.enter()
        URLSession.shared.dataTask(with: urlFiat, completionHandler: { (data, response, error) -> Void in
            // Check if data was received successfully
            var out: String = ""
            if error == nil && data != nil {                
                do {
                    let decoder = JSONDecoder()
                    self.responseFiat =  try decoder.decode(CoinMarketCapV2.self, from: data!)
                    self.successFiat = true
                    print(self.responseFiat!)
                } catch let jsonErr {
                    out = "error in json decoding: \(jsonErr)"
                    self.successFiat = false
                    print(out)
                }
                
            } else if error != nil {
                self.successFiat = false
                print(error!)
            }
            
            group.leave()
            
        }).resume()
        
        guard let urlBTC = URL(string: urlAddressBTC) else {
            print("Url conversion issue.")
            return
        }
        group.enter()
        URLSession.shared.dataTask(with: urlBTC, completionHandler: { (data, response, error) -> Void in
            // Check if data was received successfully
            var out: String = ""
            if error == nil && data != nil {
                do {
                    let decoder = JSONDecoder()
                    self.quotesBTC =  try decoder.decode(CoinMarketCapV2.self, from: data!).data?.quotes["BTC"]
                    self.successBTC = true
                    print(self.quotesBTC!)
                } catch let jsonErr {
                    out = "error in json decoding: \(jsonErr)"
                    self.successBTC = false
                    print(out)
                }
                
            } else if error != nil {
                self.successBTC = false
                print(error!)
            }
            
            group.leave()
            
        }).resume()
        
        group.notify(queue: DispatchQueue.main) {
            completionHandler(self.getSuccess(), "This is never used")
        }
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

