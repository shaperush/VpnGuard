//
//  VpnService.swift
//  VpnGuard
//
//  Created by Maisternya on 02.06.2024.
//

import Foundation
import NetworkExtension
import Network
import Combine

enum VpnError {
    case internetConnection
    case tunnelError(String)
}

struct NetworkTraffic {
    let upload: Int64
    let download:  Int64
}

class VpnService {
    @Published var networkProtocol: NetworkProtocol = VpnConfig.currentProtocol
    @Published var connectOnStart: Bool = VpnConfig.connectOnStart
    @Published var networkTraffic = NetworkTraffic(upload: 0, download: 0)
    @Published var serviceError: VpnError?
    @Published var currentTime: String = "00:00"
    @Published var connectingStatus: NEVPNStatus = .disconnected
    
    var selectedCountry: CountryModel?
    private var notificationObserver: NotificationCenter?
    private var timer: Timer?
    var cancellable = Set<AnyCancellable>()

    private var manager: NETunnelProviderManager?
    private let trafficKey = "TRAFFIC_KEY"
    
    init() {
        subscribeStatusChange()
        
        startConnecting(country: VpnConfig.country, checkVPNConnection: !connectOnStart)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func stopConnecting() {
        stopTimer()
        manager?.connection.stopVPNTunnel()
    }
    
    func startConnecting(country: CountryModel, checkVPNConnection: Bool = false) {
        selectedCountry = country
        guard connectingStatus != .connected else {
            manager?.connection.stopVPNTunnel()
            return
        }
        
        checkInternetConnection()
        
        let callback = { [weak self] (error: Error?) -> Void in
            self?.manager?.loadFromPreferences(completionHandler: { error in
                if let error  {
                    self?.serviceError = .tunnelError(error.localizedDescription)
                    return
                }
                let options: [String : NSObject] = [
                    "username": "vpnbook" as NSString,
                    "password": "dnx97sa" as NSString
                ]
                
                if checkVPNConnection {
                    self?.connectingStatus = self?.manager?.connection.status ?? .invalid
                    return
                }
                
                do {
                    try self?.manager?.connection.startVPNTunnel(options: options)
                    self?.startTimer()
                } catch {
                    self?.serviceError = .tunnelError(error.localizedDescription)
                }
           })
        }
        
        configureVPN(callback: callback)
    }
}

extension VpnService {
    private func subscribeStatusChange() {
        NotificationCenter.default.publisher(for: .NEVPNStatusDidChange)
                    .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] notification in
                        let nevpnconn = notification.object as! NEVPNConnection
                        let status = nevpnconn.status
                        self?.checkNEStatus(status: status)
                    }.store(in: &cancellable)
    }
    
    private func getTrafficData() {
        let decoder = JSONDecoder()
        guard let session = manager?.connection as? NETunnelProviderSession else { return }
        do {
            try session.sendProviderMessage(trafficKey.data(using: .utf8)!) { [weak self] data in
                guard let data, let traffic = try? decoder.decode([String: Int64].self, from: data) else { return }
                let upload = traffic["upload"]  ?? 0
                let download = traffic["download"] ?? 0
                self?.networkTraffic = NetworkTraffic(upload: upload, download: download)
            }
        } catch {
            print(error)
        }
    }
    
    private func checkInternetConnection() {
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { [weak self] path in
            if path.status == .unsatisfied {
                DispatchQueue.main.async {
                    self?.serviceError = .internetConnection
                }
            }
        }
        let queue = DispatchQueue(label: "Network")
        monitor.start(queue: queue)
    }
    
    private func checkNEStatus(status: NEVPNStatus) {
        connectingStatus = status
        switch status {
        case .invalid:
            stopTimer()
        case .disconnected:
            stopTimer()
        case .connecting:
            break
        case .connected:
            startTimer()
        case .reasserting:
            break
        case .disconnecting:
            break
        default:
            break
        }
    }
    
    private func configureVPN(callback: @escaping (Error?) -> Void) {
        guard let  selectedCountry, let configurationContent = VpnConfig.getDataFromVPNProfile(country: selectedCountry, networkProtocol: networkProtocol) else { return }
        
        NETunnelProviderManager.loadAllFromPreferences { [weak self] managers, error in
            if let error  {
                self?.serviceError = .tunnelError(error.localizedDescription)
                return
            }
            
            self?.manager = managers?.first ?? NETunnelProviderManager()
            self?.manager?.loadFromPreferences(completionHandler: { error in
                if let error  {
                    callback(error)
                    return
                }
                
                let tunnelProtocol = NETunnelProviderProtocol()
                tunnelProtocol.serverAddress = ""
                tunnelProtocol.providerBundleIdentifier = "net.bestapp.selfvpnguard.NetworkFlowGroup"
                tunnelProtocol.providerConfiguration = ["configuration": configurationContent]
                tunnelProtocol.disconnectOnSleep = false
                
                self?.manager?.protocolConfiguration = tunnelProtocol
                self?.manager?.localizedDescription = "VpnGuard"
                self?.manager?.isEnabled = true
                self?.manager?.saveToPreferences(completionHandler: { error in
                    if let error  {
                        callback(error)
                        return
                    }
                    callback(nil)
                })
            })
        }
    }
}

extension VpnService {
    private func startTimer() {
        stopTimer()
        let timer = Timer(timeInterval: 1.0, target: self, selector: #selector(timerUpdate), userInfo: Date(), repeats: true)
        self.timer = timer
        RunLoop.main.add(timer, forMode: .common)
    }
    
    @objc func timerUpdate() {
        guard let date = timer?.userInfo as? Date else { return }
        let elapsed = -date.timeIntervalSinceNow
        let hours = Int(elapsed / 3600)
        let minutes = Int((elapsed.truncatingRemainder(dividingBy: 3600)) / 60)
        let seconds = Int(elapsed.truncatingRemainder(dividingBy: 60))
        if hours < 1 {
            currentTime = String(format: "%02d:%02d", minutes, seconds)
            getTrafficData()
        } else {
            currentTime = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
            getTrafficData()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
    
