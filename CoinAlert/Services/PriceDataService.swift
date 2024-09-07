//
//  PriceDataService.swift
//  CoinAlert
//
//  Created by 백지훈 on 8/16/24.
//

import Foundation

class PriceDataService {
    
    func sendPriceDataToServer(_ priceData: PriceData, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "baseURL") as? String else {
            completion(.failure(NSError(domain: "Invalid baseURL", code: 400, userInfo: nil)))
            return
        }

        guard let url = URL(string: "\(baseURL)/api/savePriceData") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }

        guard let token = getJWTFromKeychain() else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601 // 서버에서 사용하는 날짜 포맷과 맞출 필요가 있음
            let data = try encoder.encode(priceData)
            request.httpBody = data
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
                completion(.failure(NSError(domain: "Invalid response from server", code: 500, userInfo: nil)))
                return
            }

            completion(.success(()))
        }.resume()
    }

    // JWT 토큰을 Keychain에서 가져오는 함수
    func getJWTFromKeychain() -> String? {
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

