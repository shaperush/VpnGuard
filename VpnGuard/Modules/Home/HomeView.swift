//
//  HomeView.swift
//  VpnGuard
//
//  Created by Maisternya on 04.06.2024.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var paywallService: PaywallService
    @State var showPremiumOnDismiss = false
    @State var isShowCountryList: Bool = false
    @State var showPremiumWhenDismiss: Bool = false
    @Binding var showSideMenu: Bool
    @ObservedObject var viewModel: ContentViewModel
    @Binding var showPremiumView: Bool
    var body: some View {
        ZStack {
            VStack {
                HeaderToolbarView(showSideMenu: $showSideMenu, showPremiumView: $showPremiumView)
                    .environmentObject(paywallService)
                ConnectedInfoView(download: $viewModel.downloadSpeed, upload: $viewModel.uploadSpeed)
                
                Spacer()
                
                ConnectionView(showPremiumView: $showPremiumView, viewModel: viewModel)
                    .environmentObject(paywallService)
                Spacer()
                SelectedCountry(isShowCountryList: $isShowCountryList, country: $viewModel.selectedCountry)
            }
        }
        .background(.appBg)
        .sheet(isPresented: $isShowCountryList, onDismiss: {
            if showPremiumOnDismiss {
                showPremiumView.toggle()
                showPremiumWhenDismiss = false
            }
        }) {
            CountryListView(showPremiumOnDismiss: $showPremiumOnDismiss, viewModel: viewModel)
                .environmentObject(paywallService)
        }
        .hiddenTabBar()
    }
}

struct ConnectionView: View {
    @Binding var showPremiumView: Bool
    @EnvironmentObject var paywallService: PaywallService
    @ObservedObject var viewModel: ContentViewModel
    var body: some View {
        ZStack {
            if [.connecting, .connected, .disconnecting].contains(viewModel.connectingStatus) {
                PulseLoading().offset(y: -30)
            }
            VStack {
                Button(action: {
                    if paywallService.isPremium {
                        viewModel.connect()
                    } else {
                        showPremiumView = true
                    }
                }, label: {
                    Image(viewModel.connectingStatus == .connected ? .stopConnectionIco : .startConnectionIco)
                }).buttonStyle(.plain)
                Text(viewModel.connectingStatus.statusName)
                    .font(.system(size: 16, weight: .semibold))
                Text(viewModel.currentTime)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.neutral)
            }
           
            
        }.padding(.bottom, 20)
    }
}

struct PulseLoading: View {
    @State var pulse1 = false
    @State var pulse2 = false
    @State var pulse3 = false
    private let circleDiametr: CGFloat = 50
    private let scaleFactor: CGFloat = 6.0
    var body: some View {
        ZStack {
            Circle().stroke(Color.orange.opacity(0.25)).frame(width: circleDiametr, height: circleDiametr)
                .scaleEffect(pulse1 ? scaleFactor : 1.0)
                .opacity(pulse1 ? 0 : 1)
            Circle().stroke(Color.orange.opacity(0.25)).frame(width: circleDiametr, height: circleDiametr)
                .scaleEffect(pulse2 ? scaleFactor : 0.5)
                .opacity(pulse2 ? 0 : 1)
            Circle().stroke(Color.orange.opacity(0.25)).frame(width: circleDiametr, height: circleDiametr)
                .scaleEffect(pulse3 ? scaleFactor : 0.0)
                .opacity(pulse3 ? 0 : 1)
        }
        .onAppear {
            animateView()
        }
    }
    
    func animateView() {
        withAnimation(Animation.linear(duration: 3.0).delay(-0.1).repeatForever(autoreverses: false)) {
            pulse1.toggle()
        }
        
        withAnimation(Animation.linear(duration: 3.0).delay(-0.6).repeatForever(autoreverses: false)) {
            pulse2.toggle()
        }
        
        withAnimation(Animation.linear(duration: 3.0).delay(-1.1).repeatForever(autoreverses: false)) {
            pulse3.toggle()
        }
    }
}

struct ConnectedInfoView: View {
    @Binding var download: String
    @Binding var upload: String
    var body: some View {
        HStack {
            VStack {
                HStack {
                    Text("Download")
                        .font(.system(size: 14, weight: .semibold))
                    Spacer()
                    Image(.downloadValueIco)
                }
                .padding(.bottom, 10)
                HStack {
                    Text(download)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.neutral)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.leading, 16)
            .padding(.trailing, 10)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            Divider()
            
            VStack {
                HStack {
                    Text("Upload")
                        .font(.system(size: 14, weight: .semibold))
                    Spacer()
                    Image(.uploadValueIco)
                }
                .padding(.bottom, 10)
                HStack {
                    Text(upload)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.neutral)

                    Spacer()
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.leading, 10)
            .padding(.trailing, 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 104)
        .background(.appBlock)
        .cornerRadius(10.0)
        .padding(.leading, 16)
        .padding(.trailing, 16)
        .shadow(color: .barShadow, radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/, x: 0, y: 8)
    }
}

struct SelectedCountry: View {
    @Binding var isShowCountryList: Bool
    @Binding var country: CountryModel
    var body: some View {
        Button {
            isShowCountryList.toggle()
        } label: {
            HStack {
                Image(country.image)
                    .padding()
                Text(country.name)
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
                Image(.chevronUpIco)
                    .padding()
            }
            
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(.appBlock)
            .cornerRadius(10.0)
            .padding(.leading, 16)
            .padding(.trailing, 16)
            .padding(.bottom, 20)
            .shadow(color: .barShadow, radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/, x: 0, y: 8)
        }.buttonStyle(.plain)
    }
}


#Preview {
    HomeView(showSideMenu: .constant(false), viewModel: ContentViewModel(), showPremiumView: .constant(false))
}
