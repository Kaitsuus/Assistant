//
//  OpenAIResponse.swift
//  Assistant
//
//  Created by Kai Jukarainen on 10.6.2024.
//

import Foundation

struct ChatGPTRequest: Codable {
    let model: String
    let prompt: String
    let temperature: Double
    let max_tokens: Int
    let top_p: Double
    let frequency_penalty: Double
    let presence_penalty: Double
}

struct ChatGPTResponse: Codable {
    var choices: [Choice]
    
    struct Choice: Codable {
        var text: String
    }
}
