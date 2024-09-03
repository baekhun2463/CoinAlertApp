//
//  PriceDataService.swift
//  CoinAlert
//
//  Created by 백지훈 on 8/16/24.
//

import Foundation

class PriceDataService {
    
    
    // PriceData를 서버에 추가하는 함수
    func addPriceData(_ priceData: PriceData, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "baseURL") as? String else {
            print("baseURL 가져오기 실패")
            return
        }
        guard let url = URL(string: "\(baseURL)/priceData") else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let jsonData = try JSONEncoder().encode(priceData)
            request.httpBody = jsonData
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                return
            }

            completion(.success(()))
        }.resume()
    }

    func fetchPriceData(completion: @escaping (Result<[PriceData], Error>) -> Void) {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "baseURL") as? String else {
            print("baseURL 가져오기 실패")
            return
        }
        guard let url = URL(string: "\(baseURL)/priceData") else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data"])))
                return
            }

            do {
                let priceDataList = try JSONDecoder().decode([PriceData].self, from: data)
                completion(.success(priceDataList))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

