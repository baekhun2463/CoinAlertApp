//
//  BitcoinService.swift
//  CoinAlert
//
//  Created by 백지훈 on 7/17/24.
//

import Foundation

class BitcoinPriceService {
    func fetchBitcoinPrice(completion: @escaping (Result<PriceData, Error>) -> Void) {
        let url = URL(string: "https://api.binance.com/api/v3/ticker/price?symbol=BTCUSDT")!

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "유효하지 않은 데이터", code: -1, userInfo: nil)))
                return
            }

            do {
                let binancePrice = try JSONDecoder().decode(BinancePrice.self, from: data)
                guard let price = Double(binancePrice.price) else {
                    completion(.failure(NSError(domain: "유효하지 않은 가격 데이터", code: -1, userInfo: nil)))
                    return
                }
                let priceData = PriceData(price: price ,date: Date())
                completion(.success(priceData))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
