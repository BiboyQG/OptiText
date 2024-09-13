//
//  ContentView.swift
//  OptiText
//
//  Created by Banghao Chi on 9/11/24.
//

import SwiftUI
import KeyboardShortcuts

struct ContentView: View {
    @Binding var screenshotURL: URL?
    @Binding var isPreviewPresented: Bool
    @Binding var isFloatingWindowPresented: Bool
    
    var body: some View {
        VStack {
            Text("Press shortcut to capture a screenshot")
                .padding()
            KeyboardShortcuts.Recorder(for: .captureScreenshot)
            if let url = screenshotURL {
                Button("View Screenshot") {
                    isPreviewPresented = true
                    if let appDelegate = NSApp.delegate as? AppDelegate {
                        appDelegate.openInQuickLook(url: url)
                    }
                }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView(screenshotURL: .constant(nil), isPreviewPresented: .constant(false), isFloatingWindowPresented: .constant(false))
}
