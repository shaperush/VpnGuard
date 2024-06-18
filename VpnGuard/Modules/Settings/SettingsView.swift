//
//  SettingsView.swift
//  VpnGuard
//
//  Created by Maisternya on 04.06.2024.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var paywallService: PaywallService
    @ObservedObject var viewModel: ContentViewModel
    @Binding var showSideMenu: Bool
    @State var connectWhenStart: Bool = false
    @State var useUDP: Bool = false
    @State var showTerms: Bool = false
    @State var showAbout: Bool = false
    @Binding var showPremiumView: Bool
    
    var body: some View {
        VStack {
            HeaderToolbarView(showSideMenu: $showSideMenu, showPremiumView: $showPremiumView)
                .environmentObject(paywallService)
            VStack {
                SettingItemView(showPremiumView: $showPremiumView, toggle: $viewModel.connectOnStart, title: "Connect when start", subtitle: "Connect to VPN when app starts")
                
                SettingItemView(showPremiumView: $showPremiumView, toggle: $viewModel.isUDP, title: "Use UDP protocol", subtitle: "By default - TCP protocol")
              
                Button {
                    showTerms.toggle()
                } label: {
                    HStack {
                        Text("Privacy policy")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.appTitle)
                        Spacer()
                        Image(.chevronRightIco)
                    }.frame(height: 50)
                }
              
                Button {
                    showAbout.toggle()
                } label: {
                    HStack {
                        Text("About")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.appTitle)
                        Spacer()
                        Image(.chevronRightIco)
                    }.frame(height: 50)
                }

               
            }.padding()
            Spacer()
        }
        .background(.appBg)
        .hiddenTabBar()
        .fullScreenCover(isPresented: $showAbout, content: {
            TermsView(aboutInfo: .about)
        })
        .fullScreenCover(isPresented: $showTerms, content: {
            TermsView(aboutInfo: .terms)
        })
    }
}

struct SettingItemView: View {
    @EnvironmentObject var paywallService: PaywallService
    @Binding var showPremiumView: Bool
    @Binding var toggle: Bool
    let title: String
    let subtitle: String
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.appTitle)
                Text(subtitle)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            HStack {
                if !paywallService.isPremium {
                    Image(.crownPrimaryIco)
                }
                Toggle("", isOn: $toggle)
                    .toggleStyle(SwitchToggleStyle(tint: .appAction))
                    .scaleEffect(0.9)
                    .padding(.trailing, -5)
                    .onChange(of: toggle) { value in
                        if !paywallService.isPremium {
                            self.toggle = false
                            showPremiumView = true
                        }
                    }
            }.frame(width: 80)
        }.frame(height: 60)
    }
}

#Preview {
    SettingsView(viewModel: ContentViewModel(), showSideMenu: .constant(false), showPremiumView: .constant(false))
}
