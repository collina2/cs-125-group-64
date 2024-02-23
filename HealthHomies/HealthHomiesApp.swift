//
//  HealthHomiesApp.swift
//  HealthHomies
//
//  Created by Rithvij Pochampally on 2/19/24.
//

import SwiftUI
import FirebaseCore
import FirebaseAnalytics

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}


@main
struct HealthHomiesApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var manager = HealthManager()
    var body: some Scene {
        WindowGroup {
            HealthHomieTabView()
                .environmentObject(manager)
        }
    }
}
