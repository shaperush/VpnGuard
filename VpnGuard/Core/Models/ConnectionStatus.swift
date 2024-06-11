//
//  ConnectionStatus.swift
//  VpnGuard
//
//  Created by Maisternya on 04.06.2024.
//

import Foundation
import NetworkExtension

enum ConnectionStatus: Int {
    case invalid
    case disconnected
    case connecting
    case connected
    case reasserting
    case disconnecting
    
    static func fromNEVPNStatus(_ status: NEVPNStatus) -> Self {
        return ConnectionStatus(rawValue: status.rawValue) ?? .invalid
    }
    
    var statusName: String {
        switch self {

        case .invalid:
            "Invalid"
        case .disconnected:
            "Disconnected"
        case .connecting:
            "Connecting"
        case .connected:
            "Connected"
        case .reasserting:
            "Reasserting"
        case .disconnecting:
            "Disconnecting"
        }
    }
}


