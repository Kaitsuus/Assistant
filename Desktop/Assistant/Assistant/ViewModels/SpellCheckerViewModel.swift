//
//  SpellCheckerViewModel.swift
//  Assistant
//
//  Created by Kai Jukarainen on 10.6.2024.
//

import SwiftUI
import Foundation

class SpellCheckerViewModel: ObservableObject {
    @Published var textToCheck: String = ""
    @Published var checkedText: String = ""

    func checkSpelling(completion: @escaping () -> Void) {
        let originalText = textToCheck
        NetworkManager.checkText(text: originalText) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let correctedText):
                    var correctedText = correctedText
                    if !originalText.hasPrefix("\"") && !originalText.hasSuffix("\"") {
                        if correctedText.hasPrefix("\"") && correctedText.hasSuffix("\"") {
                            correctedText.removeFirst()
                            correctedText.removeLast()
                        }
                    }
                    self?.textToCheck = correctedText
                case .failure(let error):
                    self?.checkedText = "Error: \(error.localizedDescription)"
                }
                completion()
            }
        }
    }
}
