//
//  VpnConfig.swift
//  VpnGuard
//
//  Created by Maisternya on 02.06.2024.
//

import Foundation

final class VpnConfig {
    static private let vpnProfileNames = ["pl": ["pl134-tcp80",
                                                 "pl134-tcp443",
                                                 "pl134-udp53",
                                                 "pl134-udp25000",
                                                 "pl140-tcp80",
                                                 "pl140-tcp443",
                                                 "pl140-udp53",
                                                 "pl140-udp25000"],
                                          "de": ["de20-tcp443",
                                                 "de20-tcp80",
                                                 "de20-udp53",
                                                 "de20-udp25000",
                                                 "de220-tcp443",
                                                 "de220-tcp80",
                                                 "de220-udp53",
                                                 "de220-udp25000"],
                                          "uk": ["uk1-tcp80",
                                                 "uk1-tcp443",
                                                 "uk1-udp53",
                                                 "uk1-udp25000",
                                                 "uk2-tcp80",
                                                 "uk2-tcp443",
                                                 "uk2-udp53",
                                                 "uk2-udp25000"],
                                          "us": ["us1-tcp80",
                                                 "us1-tcp443",
                                                 "us1-udp53",
                                                 "us1-udp25000",
                                                 "us2-tcp80",
                                                 "us2-tcp443",
                                                 "us2-udp53",
                                                 "us2-udp25000"],
                                          "ca": ["ca149-udp25000",
                                                 "ca149-udp53",
                                                 "ca149-tcp443",
                                                 "ca149-tcp80",
                                                 "ca196-tcp80",
                                                 "ca196-tcp443",
                                                 "ca196-udp53",
                                                 "ca196-udp25000"],
                                          "fr": ["fr200-udp25000",
                                                 "fr200-tcp80",
                                                 "fr200-udp53",
                                                 "fr200-tcp443",
                                                 "fr231-tcp80",
                                                 "fr231-tcp443",
                                                 "fr231-udp53",
                                                 "fr231-udp25000"]]
    
    private init() {}
    
    static func getDataFromVPNProfile(country: CountryModel, networkProtocol: NetworkProtocol) -> Data? {
        if let countryProfiles = vpnProfileNames[country.id] {
            let suffix = networkProtocol.rawValue.lowercased()            
            if let filename = countryProfiles.filter({ $0.contains(suffix)}).randomElement(),
               let configurationFile = Bundle.main.url(forResource: filename, withExtension: "ovpn") {
                do {
                    let data = try Data(contentsOf: configurationFile)
                    return data
                } catch {
                    return nil
                }
            }
        }
        return nil
    }
    
    static let selectedCountryKey = "SelectedCountryKey"
    static var country: CountryModel {
        get {
            let userDefault = UserDefaults.standard
            let decoder = JSONDecoder()
            if let data = userDefault.value(forKey: VpnConfig.selectedCountryKey) as? Data,
               let country = try? decoder.decode(CountryModel.self, from: data) {
                return country
            }
            return CountryModel.getCountries()[0]
        }
        
        set {
            let userDefault = UserDefaults.standard
            let encoder = JSONEncoder()
            
            if let data = try? encoder.encode(newValue) {
                userDefault.setValue(data, forKey: VpnConfig.selectedCountryKey)
            }
        }
    }
    
    static let selectedProtocolKey = "SelectedProtocolKey"
    static var currentProtocol: NetworkProtocol {
        get {
            let userDefault = UserDefaults.standard
            if let data = userDefault.value(forKey: VpnConfig.selectedProtocolKey) as? String {
                return NetworkProtocol(rawValue: data) ?? .TCP
            }
            return .TCP
        }
        
        set {
            let userDefault = UserDefaults.standard
            userDefault.setValue(newValue.rawValue, forKey: VpnConfig.selectedProtocolKey)
        }
    }
    
    
    static let connectOnStartKey = "ConnectOnStartKey"
    static var connectOnStart: Bool {
        get {
            let userDefault = UserDefaults.standard
            if let data = userDefault.value(forKey: VpnConfig.connectOnStartKey) as? Bool {
                return data
            }
            return false
        }
        
        set {
            let userDefault = UserDefaults.standard
            userDefault.setValue(newValue, forKey: VpnConfig.connectOnStartKey)
        }
    }
}
