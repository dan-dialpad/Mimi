//
//  AppDelegate.swift
//  Mimi
//
//  Created by Dan Carlson on 2024-04-01.
//

import Foundation
import UIKit

class MimiAppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        ContactsRegistrar.registarContacts()
        return true
    }
}
