//
//  KeyHandlingView.swift
//  Assistant
//
//  Created by Kai Jukarainen on 11.6.2024.
//

import Foundation
import SwiftUI
import AppKit

struct KeyHandlingView: NSViewRepresentable {
    typealias NSViewType = KeyHandlingNSView

    var onKeyDown: (NSEvent) -> Void

    func makeNSView(context: Context) -> KeyHandlingNSView {
        let nsView = KeyHandlingNSView()
        nsView.onKeyDown = onKeyDown
        return nsView
    }

    func updateNSView(_ nsView: KeyHandlingNSView, context: Context) {
    }

    class KeyHandlingNSView: NSView {
        var onKeyDown: ((NSEvent) -> Void)?

        override var acceptsFirstResponder: Bool { true }

        override func keyDown(with event: NSEvent) {
            onKeyDown?(event)
        }
    }
}
