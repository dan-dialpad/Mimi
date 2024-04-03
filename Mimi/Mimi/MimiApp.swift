//
//  MimiApp.swift
//  Mimi
//
//  Created by Dan Carlson on 2024-03-25.
//

import SwiftUI

@main
struct MimiApp: App {
    @UIApplicationDelegateAdaptor(MimiAppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
