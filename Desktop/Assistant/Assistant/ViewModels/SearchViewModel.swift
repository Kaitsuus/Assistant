//
//  SearchViewModel.swift
//  Assistant
//
//  Created by Kai Jukarainen on 11.6.2024.
//

import Foundation
import AppKit

class SearchViewModel: ObservableObject {
    @Published var query: String = ""

    func refineQuery(_ query: String, exclusions: [String] = ["ad", "sponsored"]) -> String {
        var refinedQuery = query
        for exclusion in exclusions {
            refinedQuery += " -inurl:\(exclusion)"
        }
        return refinedQuery
    }

    func createSearchURL(from query: String, for engine: String) -> URL? {
        // URL encode the query
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return nil }

        // Create the search URL based on the selected search engine
        let urlString: String
        switch engine {
        case "Google":
            urlString = "https://www.google.com/search?q=\(encodedQuery)"
        case "Bing":
            urlString = "https://www.bing.com/search?q=\(encodedQuery)"
        case "DuckDuckGo":
            urlString = "https://duckduckgo.com/?q=\(encodedQuery)"
        default:
            return nil
        }

        return URL(string: urlString)
    }

    func performSearch(engine: String) {
        let refinedQuery = refineQuery(query)
        if let url = createSearchURL(from: refinedQuery, for: engine) {
            openURLInBrowser(url)
        }
    }

    private func openURLInBrowser(_ url: URL) {
        // Open the URL in the default web browser
        NSWorkspace.shared.open(url)
    }
}
