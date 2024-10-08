//
//  LoginService.swift
//  CoinAlert
//
//  Created by 백지훈 on 8/13/24.
//

import Foundation

class LoginService {
    

    func validateLoginDetails(user: LoginModel, completion: @escaping (Result<JwtResponse, Error>) -> Void) {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "baseURL") as? String else {
            print("baseURL 가져오기 실패")
            return
        }
        
        guard let url = URL(string: "\(baseURL)/auth/login") else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let jsonData = try JSONEncoder().encode(user)
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

            guard let httpResponse = response as? HTTPURLResponse,
                  let data = data else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                return
            }

            print("HTTP Response Code: \(httpResponse.statusCode)")
            print("Response Data: \(String(data: data, encoding: .utf8) ?? "No Data")")

            do {
                let loginResponse = try JSONDecoder().decode(JwtResponse.self, from: data)
                completion(.success(loginResponse))
            } catch {
                completion(.failure(error))
            }
        }.resume()

    }
}
