//
//  ContentView.swift
//  VpnGuard
//
//  Created by Maisternya on 01.06.2024.
//

import SwiftUI

struct ContentView: View {
    @State var showSideMenu: Bool = false
    @State var selectedSideMenuTab = 0
    @StateObject var viewModel = ContentViewModel()
    
    var body: some View {
        ZStack{
            TabView(selection: $selectedSideMenuTab) {
                HomeView(showSideMenu: $showSideMenu, viewModel: viewModel)
                    .tag(0)
                RateView(showSideMenu: $showSideMenu)
                    .tag(1)
                SpeedTestView(showSideMenu: $showSideMenu)
                    .tag(2)
                SettingsView(viewModel: viewModel, showSideMenu: $showSideMenu)
                    .tag(3)
            }
            
            if showSideMenu {
                SideMenuView(showSideMenu: $showSideMenu,
                             selectedSideMenuTab: $selectedSideMenuTab)
            }
        }
    }
}

#Preview {
    ContentView()
}
