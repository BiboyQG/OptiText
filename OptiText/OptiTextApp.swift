//
//  OptiTextApp.swift
//  OptiText
//
//  Created by Banghao Chi on 9/11/24.
//

import SwiftUI
import KeyboardShortcuts
import Quartz
import AppKit

// Add this extension at the top of the file, outside of any struct or class
extension KeyboardShortcuts.Name {
    static let captureScreenshot = Self("captureScreenshot")
}

@main
struct OptiTextApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State var screenshotURL: URL?
    @State private var isPreviewPresented = false
    @State var isFloatingWindowPresented = false
    
    var body: some Scene {
        MenuBarExtra("OptiText", systemImage: "text.viewfinder") {
            ContentView(screenshotURL: $screenshotURL, isPreviewPresented: $isPreviewPresented, isFloatingWindowPresented: $isFloatingWindowPresented)
        }
        .menuBarExtraStyle(.window)
        .windowResizability(.contentSize)
        
        WindowGroup(id: "floatingWindow") {
            FloatingWindowView()
                .frame(width: 300, height: 200)
                .background(Color(NSColor.windowBackgroundColor))
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultPosition(.center)
        .defaultSize(CGSize(width: 300, height: 200))
    }
}

class AutoClosingWindow: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
    
    override func resignMain() {
        super.resignMain()
        close()
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, QLPreviewPanelDataSource, QLPreviewPanelDelegate {
    var screenshotURL: URL?
    var floatingWindow: AutoClosingWindow?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        KeyboardShortcuts.onKeyDown(for: .captureScreenshot) { [self] in
            self.captureScreenshot()
        }
        
        // Create the floating window
        createFloatingWindow()
    }
    
    func createFloatingWindow() {
        let window = AutoClosingWindow(
            contentRect: NSRect(x: 100, y: 100, width: 300, height: 200),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        window.title = "Floating Window"
        window.center()
        window.setFrameAutosaveName("FloatingWindow")
        window.contentView = NSHostingView(rootView: FloatingWindowView())
        window.isReleasedWhenClosed = false
        window.level = .floating
        window.backgroundColor = NSColor.windowBackgroundColor.withAlphaComponent(0.9)
        window.isMovableByWindowBackground = true
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        
        self.floatingWindow = window
    }
    
    func openInQuickLook(url: URL) {
        self.screenshotURL = url
        if let panel = QLPreviewPanel.shared() {
            panel.dataSource = self
            panel.makeKeyAndOrderFront(nil)
            
            // Present the floating window after Quick Look is shown
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.floatingWindow?.makeKeyAndOrderFront(nil)
                self.floatingWindow?.orderFrontRegardless()
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

// Add this new view for the floating window
struct FloatingWindowView: View {
    @State private var input1 = ""
    @State private var input2 = ""
    
    var body: some View {
        VStack {
            TextField("Input 1", text: $input1)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            TextField("Input 2", text: $input2)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
        }
        .frame(width: 300, height: 200)
        .background(Color(NSColor.windowBackgroundColor.withAlphaComponent(0.9)))
        .cornerRadius(10)
    }
}
