import Adapty
import Foundation
import SwiftUI

struct ProductsModel: Identifiable {
    var id: Int
    var price: String
    var name: String
}

struct PaywallView: View {
    @Environment(\.openURL) var openURL
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var paywallService: PaywallService
    @State var isLoading: Bool = false
    @State var errorAlertMessage: String?
    @State var shouldShowErrorAlert: Bool = false
    @State var alertMessage: String?
    @State var shouldShowAlert: Bool = false
    @State var selectedProduct: Int = 0
    
    var items: [GridItem] {
        Array(repeating: .init(.adaptive(minimum: 160)), count: 2)
    }

    // MARK: - body
    var body: some View {
        ZStack {
            Color.appBg.ignoresSafeArea()
            VStack {
                topCloseButton
                Spacer()
                titleGroup
                Spacer()
                productGroup
                buttonGroup
            }
            .disabled(isLoading)
            progressView
                .isHidden(!isLoading)
        }
    }
    
    // MARK: - top close button
    var topCloseButton: some View {
        HStack {
            Button( role: .destructive, action: {
                presentationMode.wrappedValue.dismiss()
            }, label: {
                Image.System.close
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.secondary)
            }
            ).padding()
            Spacer()
        }
        .padding()
    }
    
    // MARK: - description
    var titleGroup: some View {
        VStack(alignment: .center) {
            Text(AppStrings.paywallTitle)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.appTitle)
                .padding()
            Text(AppStrings.paywallSubtitle)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.secondary)
                .padding(.horizontal, 50)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    // MARK: - productGroup
    var productGroup: some View {
        VStack {
            Text(AppStrings.choosePlan)
                .textCase(.uppercase)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)
                .padding()
            LazyVGrid(columns: items, spacing: 20) {
                ForEach(Array(paywallService.paywallProducts.enumerated()), id: \.offset) { index, item in
                    ProductItemView(selectedIndex: $selectedProduct, product: item, index: index)
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 40)
    }
    
    // MARK: - buttonGroup
    var buttonGroup: some View {
        VStack {
            Button {
                purchaseAction(product: paywallService.paywallProducts[selectedProduct])
            } label: {
                Text(AppStrings.continueButton)
                    .textCase(.uppercase)
                    .frame(height: 48)
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                    .foregroundStyle(.white)
                    .background(.appAction)
                    .font(.system(size: 16, weight: .semibold))
                    .cornerRadius(10.0)
            }.buttonStyle(.plain)
            
            HStack(spacing: 0) {
                Button {
                    openURL(URL(string: AppConstants.TERMS_URL)!)
                } label: {
                    Text(AppStrings.terms)
                        .frame(height: 48)
                        .frame( alignment: .leading)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                }.buttonStyle(.plain)
                
                Button {
                    restorePurchaseAction()
                } label: {
                    Text(AppStrings.restorePurchase)
                        .frame(height: 48)
                        .frame( alignment: .center )
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                }.buttonStyle(.plain)
                
                Button {
                    openURL(URL(string: AppConstants.POLICY_URL)!)
                    restorePurchaseAction()
                } label: {
                    Text(AppStrings.policy)
                        .frame(height: 48)
                        .frame(alignment: .trailing)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                }.buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Progress view
    var progressView: some View {
        ZStack {
            Color.Palette.background.ignoresSafeArea().opacity(0.3)
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color.Palette.accentContent))
                .scaleEffect(1.5, anchor: .center)
                .animation(.easeOut, value: isLoading)
        }
        .alert(errorAlertMessage ?? "Error occurred", isPresented: $shouldShowErrorAlert) {
            Button("OK", role: .cancel) {
                errorAlertMessage = nil
                shouldShowErrorAlert = false
            }
        }
        .alert(alertMessage ?? "Success!", isPresented: $shouldShowAlert) {
            Button("OK", role: .cancel) {
                alertMessage = nil
                shouldShowAlert = false
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    private func updateErrorAlert(isShown: Bool, title: String) {
        errorAlertMessage = title
        shouldShowErrorAlert = isShown
    }
    
    private func restorePurchaseAction() {
        isLoading = true
        paywallService.restorePurchases { isPremium, error in
            isLoading = false
            guard error == nil else {
                errorAlertMessage = "Could not restore purchases."
                shouldShowErrorAlert = true
                return
            }
            alertMessage = "Successfully restored purchases!"
            shouldShowAlert = true
        }
    }
    
    private func purchaseAction(product: ProductItemModel) {
        guard let product = paywallService.adaptyProducts.first(where: { $0.vendorProductId == product.id })  else {
            updateErrorAlert(isShown: true, title: "No product found")
            return
        }
        isLoading = true
        paywallService.makePurchase(for: product) { succeeded, error in
            isLoading = false
            guard succeeded else {
                error.map { print($0) }
                return
            }
            alertMessage = "Success!"
            shouldShowAlert = true
        }
    }
}


struct ProductItemView: View {
    @Binding var selectedIndex: Int
    var product: ProductItemModel
    var index: Int
    var body: some View {
        Button {
            selectedIndex = index
        } label: {
            VStack(spacing: 2) {
                Text(product.priceString)
                    .font(.system(size: 16, weight: .semibold))
                Text("per \(product.period)")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(.secondary)
            }
            .frame(height: 88)
            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
            .background(.appBlock)
            .cornerRadius(16)
            .shadow(color: .barShadow, radius: 16, y: 8)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(selectedIndex == index ? .appAction : .clear, lineWidth: 1)
            )
        }.buttonStyle(.plain)
    }
}


// MARK: - preview

struct PaywallView_Previews: PreviewProvider {
    static var previews: some View {
        PaywallView()
            .environmentObject(PaywallService())
    }
}
