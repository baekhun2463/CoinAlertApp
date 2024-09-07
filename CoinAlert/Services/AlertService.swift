//
//  AlertService.swift
//  CoinAlert
//
//  Created by 백지훈 on 8/16/24.
//

import Foundation

class AlertService {
    private let baseURL = Bundle.main.object(forInfoDictionaryKey: "baseURL") as? String
    
    
    func fetchAlerts(completion: @escaping (Result<[AlertData], Error>) -> Void) {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "baseURL") as? String else {
            completion(.failure(NSError(domain: "Invalid baseURL", code: 400, userInfo: nil)))
            return
        }
        
        guard let url = URL(string: "\(baseURL)/api/priceData") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }
        
        guard let token = getJWTFromKeychain() else {
            completion(.failure(NSError(domain: "JWT missing", code: 401, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: 500, userInfo: nil)))
                return
            }
            
            do {
                let alerts = try JSONDecoder().decode([AlertData].self, from: data)
                completion(.success(alerts))
            } catch {
                print("Decoding error: \(error.localizedDescription)")
                print(String(data: data, encoding: .utf8) ?? "No readable data")
                completion(.failure(error))
            }
        }.resume()
    }
    
    
    func deleteAlert(id: Int64, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let baseURL = baseURL else {
            completion(.failure(NSError(domain: "Invalid baseURL", code: 400, userInfo: nil)))
            return
        }
        
        guard let url = URL(string: "\(baseURL)/api/deletePriceData/\(id)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }
        
        guard let token = getJWTFromKeychain() else {
            completion(.failure(NSError(domain: "JWT missing", code: 401, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(NSError(domain: "Failed to delete alert", code: 500, userInfo: nil)))
                return
            }
            
            completion(.success(()))
        }.resume()
    }
    
    private func getJWTFromKeychain() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "authToken",
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        if status == errSecSuccess, let data = item as? Data {
            return String(data: data, encoding: .utf8)
        } else {
            print("JWT 가져오기 실패: \(status)")
            return nil
        }
    }
}
