//
//  NetworkManager.swift
//  Assistant
//
//  Created by Kai Jukarainen on 10.6.2024.
//

import Foundation

struct NetworkManager {
    static let apiKey = ""
    static let maxRetries = 3

    static func checkText(text: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "https://api.openai.com/v1/completions") else {
            print("Error: Invalid URL")
            completion(.failure(NetworkError.urlError))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ChatGPTRequest(
            model: "gpt-3.5-turbo-instruct",
            prompt: "Correct the following sentence and provide only the corrected version: \(text)\n",
            temperature: 1,
            max_tokens: 256,
            top_p: 1,
            frequency_penalty: 0,
            presence_penalty: 0
        )
        
        let encoder = JSONEncoder()
        guard let jsonData = try? encoder.encode(body) else {
            print("Error: Failed to encode JSON body")
            completion(.failure(NetworkError.encodingError))
            return
        }
        request.httpBody = jsonData

        performRequest(request: request, retries: 0, completion: completion)
    }

    private static func performRequest(request: URLRequest, retries: Int, completion: @escaping (Result<String, Error>) -> Void) {
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: Network request failed with error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 429 {
                    if retries < maxRetries {
                        let delay = pow(2.0, Double(retries))
                        print("Error: Rate limit exceeded. Retrying in \(delay) seconds...")
                        DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
                            performRequest(request: request, retries: retries + 1, completion: completion)
                        }
                    } else {
                        print("Error: Rate limit exceeded after \(maxRetries) retries")
                        completion(.failure(NetworkError.httpError(httpResponse.statusCode)))
                    }
                    return
                } else if !(200...299).contains(httpResponse.statusCode) {
                    print("Error: HTTP error with status code: \(httpResponse.statusCode)")
                    completion(.failure(NetworkError.httpError(httpResponse.statusCode)))
                    return
                }
            }
            guard let data = data else {
                print("Error: Invalid response, no data received")
                completion(.failure(NetworkError.invalidResponse))
                return
            }

            do {
                let response = try JSONDecoder().decode(ChatGPTResponse.self, from: data)
                if let correctedText = response.choices.first?.text.trimmingCharacters(in: .whitespacesAndNewlines) {
                    completion(.success(correctedText))
                } else {
                    print("Error: Invalid response, no corrected text found")
                    completion(.failure(NetworkError.invalidResponse))
                }
            } catch {
                print("Error: Failed to decode JSON response with error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }.resume()
    }
}

enum NetworkError: Error {
    case urlError, invalidResponse, httpError(Int), encodingError
}
