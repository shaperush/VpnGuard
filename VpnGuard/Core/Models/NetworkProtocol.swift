//
//  NetworkProtocol.swift
//  VpnGuard
//
//  Created by Maisternya on 02.06.2024.
//

import Foundation

enum NetworkProtocol: String, CaseIterable {
    case TCP
    case UDP
    
    static subscript(_ index: Int) -> NetworkProtocol {
        return self.allCases[index]
    }
}
