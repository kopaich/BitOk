//
//  CoinManager.swift
//  BitOk
//
//  Created by Ilya on 11.04.2021.
//

import Foundation

protocol CoinManagerDelegate {
    func didUpdateCurrency(price: String, currency: String)
    func didFailWithError(error: Error)
}

struct CoinManager {
    var delegate: CoinManagerDelegate?
    
    let currencyArray = ["USD", "EUR"]
    let cryptoCurrencyID = "BTC"
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/"
    let apiKey = "" // Enter key
    
    
    func getCoinPrice(for currency: String) {
        let urlString = "\(baseURL)\(cryptoCurrencyID)/\(currency)?apikey=\(apiKey)"
        
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            
            let task = session.dataTask(with: url) { (data, response, error) in
                if let safeError = error {
                    delegate?.didFailWithError(error: safeError)
                    return
                }
                
                if let safeData = data {
                    if let coin = self.parseJSON(safeData) {
                        let priceString = String(format: "%.4f", coin)
                        delegate?.didUpdateCurrency(price: priceString, currency: currency)
                    }
                }
            }
            
            task.resume()
        }
    }
    
    
    func parseJSON(_ data: Data) -> Double? {
        let decoder = JSONDecoder()
        
        do {
            let decodedData = try decoder.decode(CurrencyData.self, from: data)
            let lastPrice = decodedData.rate
            return lastPrice
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
