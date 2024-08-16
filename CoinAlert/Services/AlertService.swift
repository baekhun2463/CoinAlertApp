//
//  AlertService.swift
//  CoinAlert
//
//  Created by 백지훈 on 8/16/24.
//

import Foundation

class AlertService {
    private let baseURL = "http://localhost:8080" // 서버 주소로 변경하세요

    func fetchAlerts(completion: @escaping (Result<[PriceData], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/alerts") else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                return
            }

            do {
                let alerts = try JSONDecoder().decode([PriceData].self, from: data)
                completion(.success(alerts))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    func deleteAlert(id: Int64, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/alerts/\(id)") else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        URLSession.shared.dataTask(with: request) { _, response, error in
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
}

