//
//  OptiTextApp.swift
//  OptiText
//
//  Created by Banghao Chi on 9/11/24.
//

import SwiftUI
import KeyboardShortcuts
import Quartz

@main
struct OptiTextApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State var screenshotURL: URL?
    @State private var isPreviewPresented = false
    
    var body: some Scene {
        MenuBarExtra("OptiText", systemImage: "text.viewfinder") {
            ContentView(screenshotURL: $screenshotURL, isPreviewPresented: $isPreviewPresented)
        }
        .menuBarExtraStyle(.window)
        .windowResizability(.contentSize)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, QLPreviewPanelDataSource, QLPreviewPanelDelegate {
    var screenshotURL: URL?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        KeyboardShortcuts.onKeyDown(for: .captureScreenshot) { [self] in
            self.captureScreenshot()
        }
    }
    
    func openInQuickLook(url: URL) {
        self.screenshotURL = url
        if let panel = QLPreviewPanel.shared() {
            panel.dataSource = self
            panel.makeKeyAndOrderFront(nil)
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
            DispatchQueue.main.async {
                self.openInQuickLook(url: fileURL)
            }
        } catch {
            print("Error saving screenshot: \(error)")
        }
    }
    
    // MARK: - QLPreviewPanelDataSource
    
    func numberOfPreviewItems(in panel: QLPreviewPanel!) -> Int {
        return screenshotURL != nil ? 1 : 0
    }
    
    func previewPanel(_ panel: QLPreviewPanel!, previewItemAt index: Int) -> QLPreviewItem! {
        return screenshotURL as QLPreviewItem?
    }
}
