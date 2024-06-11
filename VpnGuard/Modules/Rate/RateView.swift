//
//  RateView.swift
//  VpnGuard
//
//  Created by Maisternya on 04.06.2024.
//

import SwiftUI

struct RateView: View {
    @Binding var showSideMenu: Bool
    var body: some View {
        VStack {
            HeaderToolbar(showSideMenu: $showSideMenu)
            Spacer()
        }.background(.appBg)
        .hiddenTabBar()
    }
}

#Preview {
    RateView(showSideMenu: .constant(false))
}
