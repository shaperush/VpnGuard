//
//  ContentViewModel.swift
//  VpnGuard
//
//  Created by Maisternya on 02.06.2024.
//

import Foundation
import Combine

class ContentViewModel: ObservableObject {
    let countryList: [CountryModel]
    var cancellable = Set<AnyCancellable>()
    @Published var connectionError: VpnError? = nil
    @Published var isConnected: Bool = false
    @Published var selectedCountry: CountryModel
    @Published var isUDP: Bool
    @Published var connectOnStart: Bool
    
    
    @Published var currentTime: String
    @Published var downloadSpeed: String
    @Published var uploadSpeed: String
    @Published var connectingStatus: ConnectionStatus = .disconnected
    
    
    private let vpnService: VpnService
    
    init() {
        countryList = CountryModel.getCountries()
        selectedCountry = VpnConfig.country
        vpnService = VpnService()
        isUDP = self.vpnService.networkProtocol == .UDP
        connectOnStart = self.vpnService.connectOnStart
        downloadSpeed = "0 MB"
        uploadSpeed = "0 MB"
        currentTime = "00:00"
        
        initBinding()
    }
    
    func connect() {
        isConnected.toggle()
        isConnected ? vpnService.startConnecting(country: selectedCountry) : vpnService.stopConnecting()
    }
    
    func updateCountry(_ country: CountryModel) {
        VpnConfig.country = country
        selectedCountry = country
    }
}

extension ContentViewModel {
    private func initBinding() {
        vpnService.$serviceError.sink { [weak self] error in
            self?.connectionError = error
        }.store(in: &cancellable)
        
        vpnService.$currentTime.sink { [weak self] time in
            self?.currentTime = time
        }.store(in: &cancellable)
        
        vpnService.$networkTraffic.sink { [weak self] traffic in
            self?.downloadSpeed = traffic.download.toFileSize
            self?.uploadSpeed = traffic.upload.toFileSize
        }.store(in: &cancellable)
        
        vpnService.$connectingStatus.sink { [weak self] status in
            self?.connectingStatus = ConnectionStatus(rawValue: status.rawValue) ?? .invalid
        }.store(in: &cancellable)
        
        $isUDP.sink { [weak self] isUDP in
            self?.vpnService.networkProtocol = isUDP ? .UDP : .TCP
            VpnConfig.currentProtocol = isUDP ? .UDP : .TCP
        }.store(in: &cancellable)
        
        $connectOnStart.sink { [weak self] isConnect  in
            self?.vpnService.connectOnStart = isConnect
            VpnConfig.connectOnStart = isConnect
        }.store(in: &cancellable)
    }
}



