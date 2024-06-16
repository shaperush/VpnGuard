//
//  ContentView.swift
//  VpnGuard
//
//  Created by Maisternya on 01.06.2024.
//

import SwiftUI

struct ContentView: View {
    @State var showSideMenu: Bool = false
    @State var showPremiumView: Bool = false
    @State var selectedSideMenuTab = 0
    @StateObject var viewModel = ContentViewModel()
    @EnvironmentObject var paywallService: PaywallService
    
    @AppStorage("isShowTutorial") var isShowTutorial = true
    var body: some View {
        ZStack {
            
            TabView(selection: $selectedSideMenuTab) {
                HomeView(showSideMenu: $showSideMenu, viewModel: viewModel, showPremiumView: $showPremiumView)
                    .tag(0)
                    .environmentObject(paywallService)
                SpeedTestView(showSideMenu: $showSideMenu, showPremiumView: $showPremiumView)
                    .tag(1)
                    .environmentObject(paywallService)
                SettingsView(viewModel: viewModel, showSideMenu: $showSideMenu, showPremiumView: $showPremiumView)
                    .tag(2)
                    .environmentObject(paywallService)
            }
            
            
            if showSideMenu {
                SideMenuView(showSideMenu: $showSideMenu,
                             selectedSideMenuTab: $selectedSideMenuTab)
            }
            
            if isShowTutorial {
                StartTutorialView(showPremiumView: $showPremiumView)
                    .transition(.move(edge: .leading))
                    .animation(.easeInOut, value: isShowTutorial)
            }
            
        }.fullScreenCover(isPresented: $showPremiumView, content: {
            PaywallView()
                .environmentObject(paywallService)
        })
    }
}

#Preview {
    ContentView()
}
