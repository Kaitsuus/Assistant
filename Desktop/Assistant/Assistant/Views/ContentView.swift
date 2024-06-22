//  ContentView.swift
//  Assistant
//
//  Created by Kai Jukarainen on 8.6.2024.
//
import SwiftUI
import AppKit

struct ContentView: View {
    @ObservedObject var spellCheckerViewModel = SpellCheckerViewModel()
    @ObservedObject var searchViewModel = SearchViewModel()
    @State private var selectedAction = "Checker"
    @State private var isLoading = false
    let actions = ["Checker", "Google", "Bing", "DuckDuckGo"]

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                TextField("Enter text here", text: $spellCheckerViewModel.textToCheck)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onChange(of: spellCheckerViewModel.textToCheck) { newText, _ in
                        searchViewModel.query = newText
                    }
                    .onSubmit {
                        performAction()
                    }

                Picker("", selection: $selectedAction) {
                    ForEach(actions, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 120)

                if isLoading {
                    ProgressView()
                } else {
                    Button(selectedAction == "Checker" ? "Check" : "Search") {
                        performAction()
                    }
                }

                if !isLoading && selectedAction == "Checker" && !spellCheckerViewModel.textToCheck.isEmpty {
                    Button(action: {
                        let pasteboard = NSPasteboard.general
                        pasteboard.clearContents()
                        pasteboard.setString(spellCheckerViewModel.textToCheck, forType: .string)
                    }) {
                        Image(systemName: "doc.on.doc")
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(KeyHandlingView(onKeyDown: handleKeyDown))
    }

    private func performAction() {
        if selectedAction == "Checker" {
            isLoading = true
            spellCheckerViewModel.checkSpelling {
                isLoading = false
            }
        } else {
            searchViewModel.performSearch(engine: selectedAction)
        }
    }

    private func handleKeyDown(event: NSEvent) {
        if event.keyCode == 36 { // 36 is the key code for the Enter key
            performAction()
        }
    }
}

#Preview {
    ContentView()
}

