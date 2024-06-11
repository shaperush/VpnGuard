//
//  Int64Extention.swift
//  VpnGuard
//
//  Created by Maisternya on 03.06.2024.
//

import Foundation

extension Int64 {
    var toFileSize: String {
        self == 0 ? "0 KB" : ByteCountFormatter.string(fromByteCount: self, countStyle: .file)
    }
}
