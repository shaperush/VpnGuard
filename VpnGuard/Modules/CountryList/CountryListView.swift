//
//  CountryListView.swift
//  VpnGuard
//
//  Created by Maisternya on 02.06.2024.
//

import SwiftUI

struct CountryListView: View {
    @Binding var showPremiumOnDismiss: Bool
    @EnvironmentObject var paywallService: PaywallService
    @ObservedObject var viewModel: ContentViewModel
    @Environment(\.dismiss) var dismiss
    var body: some View {
        VStack(spacing: 0) {
            ForEach(viewModel.countryList, id: \.id) { item in
                Button {
                    if paywallService.isPremium {
                        viewModel.updateCountry(item)
                        dismiss()
                    } else {
                        dismiss()
                        showPremiumOnDismiss = true
                    }
                    
                } label: {
                    CountryItem(country: item, isSelected: item == viewModel.selectedCountry)
                }.buttonStyle(.plain)
            }
            Spacer()
        }.padding(.top, 20)
        .background(.appBg)
    }
}

struct CountryItem: View {
    var country: CountryModel
    var isSelected: Bool
    var body: some View {
        HStack {
            Image(country.image)
                .padding()
            Text(country.name)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(isSelected ? .white  : .black)
            Spacer()
            Image(isSelected ? .fullSignalWhiteIco : .mediumSignalIco)
            Image(isSelected ? .chevronRightWhiteIco : .chevronRightIco)
                .padding()
        }
        
        .frame(maxWidth: .infinity)
        .frame(height: 48)
        .background(isSelected ? .appAction : .appBlock)
        .cornerRadius(16.0)
        .padding(.leading, 16)
        .padding(.trailing, 16)
        .padding(.bottom, 20)
        .shadow(color: isSelected ? .shadowButton : .barShadow, radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/, x: 0, y: 8)
    }
}

#Preview {
    CountryListView(showPremiumOnDismiss: .constant(false), viewModel: ContentViewModel())
}
