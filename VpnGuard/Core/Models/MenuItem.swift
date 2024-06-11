//
//  MenuItem.swift
//  VpnGuard
//
//  Created by Maisternya on 04.06.2024.
//

import Foundation

struct MenuItem: Identifiable {
    let id: Int
    let name: String
    let imageName: String
    
    static let menus = [ MenuItem(id: 0, name: "Home", imageName: "network"),
                         MenuItem(id: 1,name: "Rate us", imageName: "star"),
                         MenuItem(id: 2,name: "Speed test", imageName: "gauge.with.needle"),
                         MenuItem(id: 3,name: "Settings", imageName: "gearshape") ]
}
