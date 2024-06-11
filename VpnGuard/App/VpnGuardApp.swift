//
//  VpnGuardApp.swift
//  VpnGuard
//
//  Created by Maisternya on 01.06.2024.
//

import SwiftUI
import Adapty

@main
struct VpnGuardApp: App {
    @Environment(\.scenePhase) var scenePhase
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var paywallService = PaywallService()
    @StateObject var userService = UserService()
    @State private var showingPaywall = false
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(paywallService)
                .environmentObject(userService)
                .onAppear {
                    if Adapty.delegate == nil {
                        Adapty.delegate = userService
                    }
                }
        }
    }
    
    private func processScenePhaseChange(to phase: ScenePhase) {
        switch phase {
        case .active, .background:
            break
        case .inactive:
            showingPaywall = false
        @unknown default:
            break
        }
    }
}
