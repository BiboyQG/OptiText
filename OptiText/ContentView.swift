//
//  ContentView.swift
//  OptiText
//
//  Created by Banghao Chi on 9/11/24.
//

import SwiftUI
import AppKit
import QuickLook
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let captureScreenshot = Self("captureScreenshot")
}

struct ContentView: View {
    @State private var screenshotURL: URL?
    
    var body: some View {
        VStack {
            Text("Press Shift+Option+C to capture a screenshot")
                .padding()
            KeyboardShortcuts.Recorder(for: .captureScreenshot)
        }
        .padding()
        .quickLookPreview($screenshotURL)
        .onAppear {
            KeyboardShortcuts.onKeyDown(for: .captureScreenshot) {
                captureScreenshot()
            }
        }
    }
    
    func captureScreenshot() {
        guard let screen = NSScreen.main else { return }
        let rect = screen.frame
        let cgImage = CGWindowListCreateImage(rect, .optionOnScreenOnly, kCGNullWindowID, .bestResolution)
        
        guard let cgImage = cgImage else { return }
        let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
        guard let pngData = bitmapRep.representation(using: .png, properties: [:]) else { return }
        
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("screenshot.png")
        
        do {
            try pngData.write(to: fileURL)
            screenshotURL = fileURL
        } catch {
            print("Error saving screenshot: \(error)")
        }
    }
}

#Preview {
    ContentView()
}
