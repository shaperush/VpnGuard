//
//  SideMenuView.swift
//  VpnGuard
//
//  Created by Maisternya on 03.06.2024.
//

import SwiftUI
import StoreKit

struct SideMenuView: View {
    @State var startAnimation = false
    @Binding var showSideMenu: Bool
    @Binding  var selectedSideMenuTab: Int
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.black.opacity(0.1))
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        startAnimation.toggle()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            self.showSideMenu = false
                        }
                    }
                }
            
            
            RoundedRectangle(cornerRadius: 40)
                .fill(Color.appAction)
                .rotationEffect(startAnimation ? .degrees(0) : .zero, anchor: .bottomTrailing)
                .offset(x: startAnimation ? -40 : -UIScreen.screenWidth, y: 0)
                .scaleEffect(0.95)
                .shadow(color: .secondary, radius: 40)
                .opacity(0.95)
            
            VStack(alignment: .center) {
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation {
                            startAnimation.toggle()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                self.showSideMenu = false
                            }
                        }
                    }, label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.white)
                            .padding()
                    })
                    .padding(.top, 30)
                    .padding(.trailing, 30)
                }
                
                HStack {
                    Spacer()
                    Image(.menuGroupIco)
                    Spacer()
                }
                
                HStack {
                    MenuListView(startAnimation: $startAnimation,
                                 selectedSideMenuTab: $selectedSideMenuTab,
                                 showSideMenu: $showSideMenu)
                    .padding(.leading, 60)
                    .foregroundStyle(.white)
                    Spacer()
                }
                
                Spacer()
                
                
            }
            .offset(x: startAnimation ? -30 : -UIScreen.screenWidth, y: 0)
            .animation(.easeIn(duration: 0.3), value: 0)
        }
        .onAppear {
            withAnimation { startAnimation.toggle() }
        }
    }
}

struct MenuListView: View {
    @Binding var startAnimation: Bool
    @Binding var selectedSideMenuTab: Int
    @Binding var showSideMenu: Bool
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(MenuItem.menus) { menu in
                Button {
                    if menu.id == 1 {
                        SKStoreReviewController.requestReviewInCurrentScene()                    } else {
                            selectedSideMenuTab = menu.id
                        }
                    withAnimation {
                        startAnimation.toggle()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            self.showSideMenu = false
                        }
                    }
                } label: {
                    MenuItemView(menu: menu, selectedSideMenuTab: $selectedSideMenuTab)
                        .padding(.vertical, 15)
                }
            }
        }
    }
}

struct MenuItemView: View {
    let menu: MenuItem
    @Binding var selectedSideMenuTab: Int
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 14) {
                Image(systemName: menu.imageName)
                    .fixedSize(horizontal: true, vertical: true)
                    .frame(width: 20)
                Text(menu.name)
                    .font(.system(size:  16, weight: .bold))
            }
        }
    }
}

#Preview {
    SideMenuView(showSideMenu: .constant(true), selectedSideMenuTab: .constant(0))
}
