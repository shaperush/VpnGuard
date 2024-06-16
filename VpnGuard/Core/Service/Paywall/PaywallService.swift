import Adapty
import Foundation
import SwiftUI

final class PaywallService: ObservableObject {
    @Published var paywall: AdaptyPaywall?
    @Published var paywallProducts: [ProductItemModel] = []
    @Published var adaptyProducts: [AdaptyPaywallProduct] = []
    @Published var isPremium: Bool = false
    @Published var isLoadingStatus = false
    @Published var isLoadingProducts = false
    
    init() {
        getPaywalls()
        getPurchaserInfo()
    }
    
    // MARK: - Paywalls
    func getPurchaserInfo(completion: ((Bool, Error?) -> Void)? = nil) {
        Adapty.getProfile { [weak self] result in
            switch result {
            case let .success(profile):
                self?.updatePremiumStatus(with: profile, error: nil, completion: completion)
            case let .failure(error):
                completion?(false, error)
            }
            self?.isLoadingStatus = true
        }
    }
    
    func getPaywalls(completion: ((Error?) -> Void)? = nil) {
        reset()
        Adapty.getPaywall(placementId: AppConstants.PLACEMENT_ID) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(paywall):
                self.paywall = paywall
                self.getPaywallProducts(for: paywall, completion: completion)
            case let .failure(error):
                completion?(error)
            }
        }
    }
    
    // MARK: - Make Purchase
    func makePurchase(for product: AdaptyPaywallProduct, completion: @escaping ((Bool, Error?) -> Void)) {
        Adapty.makePurchase(product: product) { [weak self] result in
            switch result {
            case let .success(purchasedInfo):
                self?.updatePremiumStatus(with: purchasedInfo.profile, error: nil, completion: completion)
            case let .failure(error):
                completion(false, error)
            }
        }
    }
    
    // MARK: - Restore Purchases
    func restorePurchases(completion: @escaping ((Bool, Error?) -> Void)) {
        Adapty.restorePurchases { [weak self] result in
            switch result {
            case let .success(profile):
                self?.updatePremiumStatus(with: profile, completion: completion)
            case let .failure(error):
                completion(self?.isPremium ?? false, error)
            }
        }
    }
}

// MARK: - Utils
private extension PaywallService {
    private func reset() {
        paywall = nil
        paywallProducts = []
    }
    
    private func createPaywallModels(for products: [AdaptyPaywallProduct],
                                     eligibilities: [String: AdaptyEligibility]?) -> [ProductItemModel] {
        products.compactMap { product in
            guard let priceString = product.localizedPrice, let periodString = product.localizedSubscriptionPeriod else { return nil }
            return .init(
                id: product.vendorProductId,
                priceString: priceString,
                period: periodString,
                introductoryDiscount: getIntroductoryDiscount(for: product,
                                                              introductoryOfferEligibility: eligibilities?[product.vendorProductId])
            )
        }
    }
    
    func getIntroductoryDiscount(for product: AdaptyPaywallProduct,
                                 introductoryOfferEligibility: AdaptyEligibility?) -> IntroductoryDiscountModel? {
        guard
            case .eligible = introductoryOfferEligibility,
            let discount = product.introductoryDiscount,
            let localizedPeriod = discount.localizedSubscriptionPeriod,
            let localizedPrice = discount.localizedPrice
        else {
            return nil
        }
        let paymentMode: String
        switch discount.paymentMode {
        case .freeTrial: paymentMode = "Free trial"
        case .payAsYouGo: paymentMode = "Pay as you go"
        case .payUpFront: paymentMode = "Pay upfront"
        case .unknown: paymentMode = ""
        }
        return .init(
            localizedPeriod: localizedPeriod,
            localizedPrice: localizedPrice,
            paymentMode: paymentMode
        )
    }
    
    private func updateProducts(_ products: [AdaptyPaywallProduct], remoteConfig: [String: Any]?, eligibilities: [String: AdaptyEligibility]?) {
        adaptyProducts = products
        paywallProducts = createPaywallModels(for: products, eligibilities: eligibilities)
        isLoadingProducts = true
    }
    
    private func getPaywallProducts(for currentPaywall: AdaptyPaywall,completion: ((Error?) -> Void)? = nil) {
        let remoteConfig = currentPaywall.remoteConfig

        Adapty.getPaywallProducts(paywall: currentPaywall) { [weak self] result in
            switch result {
            case let .success(products):
                self?.updateProducts(products, remoteConfig: remoteConfig, eligibilities: nil)

                Adapty.getProductsIntroductoryOfferEligibility(products: products) { result in
                    switch result {
                    case let .success(eligibilities):
                        self?.updateProducts(products, remoteConfig: remoteConfig, eligibilities: eligibilities)
                        completion?(nil)
                    case let .failure(error):
                        completion?(error)
                    }
                }
            case let .failure(error):
                completion?(error)
            }
        }
    }
    
    private func updatePremiumStatus(with profile: AdaptyProfile, error: Error? = nil, completion: ((Bool, Error?) -> Void)? = nil) {
        let isPremium = profile.accessLevels["premium"]?.isActive ?? false
        self.isPremium = isPremium
        completion?(isPremium, error)
    }
}

extension PaywallService: AdaptyDelegate {
    func didLoadLatestProfile(_ profile: AdaptyProfile) {
        updatePremiumStatus(with: profile)
    }
}
