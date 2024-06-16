//
//  HeaderToolbarView.swift
//  VpnGuard
//
//  Created by Maisternya on 14.06.2024.
//

import SwiftUI

struct HeaderToolbarView: View {
    @EnvironmentObject var paywallService: PaywallService

    @Binding var showSideMenu: Bool
    @Binding var showPremiumView: Bool
    var body: some View {
        HStack(alignment: .top) {
            Button(action: {
                showSideMenu.toggle()
            }, label: {
                Image(.menuIco)
            }).buttonStyle(.plain)
            Spacer()
            
            if !paywallService.isPremium {
                Button(action: {
                    showPremiumView.toggle()
                }, label: {
                    HStack {
                        Image(.crownWhiteIco)
                        Text("Go Premium")
                            .foregroundStyle(.white)
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .frame(width: 174, height: 48)
                    .background(.appAction)
                    .cornerRadius(16.0)
                }).buttonStyle(.plain)
                    .padding(.trailing, 16)
                    .padding(.top, 5)
            }
        }
    }
}

#Preview {
    HeaderToolbarView(showSideMenu: .constant(false), showPremiumView: .constant(false))
}
