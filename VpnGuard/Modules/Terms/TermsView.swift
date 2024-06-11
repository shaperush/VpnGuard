//
//  TermsView.swift
//  VpnGuard
//
//  Created by Maisternya on 06.06.2024.
//

import SwiftUI

struct TermsView: View {
    @Environment(\.dismiss) var dissmiss
    @State var aboutInfo: AboutInfo
    var body: some View {
        ZStack {
            Color.appBg.ignoresSafeArea()
            VStack {
                HStack(alignment: .top) {
                    Button(action: {
                        dissmiss()
                    }, label: {
                        Image(.backMenuIco)
                    }).buttonStyle(.plain)
                    Spacer()
                }
                ScrollView {
                    Text(aboutInfo.rawValue)
                        .padding()
                }
            }
        }
        .hiddenTabBar()
    }
}

#Preview {
    TermsView(aboutInfo: .about)
}
