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
                
                // 현재 날짜와 시간을 가져오기
                let currentDate = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
                let dateString = dateFormatter.string(from: currentDate)
                
                // PriceData 객체 생성
                let priceData = PriceData(price: price, date: dateString, alertPrice: price)
                completion(.success(priceData))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
