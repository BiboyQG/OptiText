//
//  ContentView.swift
//  OptiText
//
//  Created by Banghao Chi on 9/11/24.
//

import SwiftUI
import AppKit
import QuickLook

struct ContentView: View {
    @State private var screenshotURL: URL?
    
    var body: some View {
        VStack {
            Text("Press Shift+Option+C to capture a screenshot")
                .padding()
        }
        .padding()
        .quickLookPreview($screenshotURL)
        .onAppear {
            NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                if event.modifierFlags.contains([.shift, .option]) && event.keyCode == 8 { // 8 is the key code for 'C'
                    captureScreenshot()
                    return nil
                }
                return event
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
