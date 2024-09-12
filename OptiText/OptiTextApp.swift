//
//  OptiTextApp.swift
//  OptiText
//
//  Created by Banghao Chi on 9/11/24.
//

import SwiftUI

@main
struct OptiTextApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide dock icon
        NSApp.setActivationPolicy(.accessory)
    }
}
