//
//  CountryModel.swift
//  VpnGuard
//
//  Created by Maisternya on 02.06.2024.
//

import Foundation

struct CountryModel: Identifiable, Equatable, Codable {
    let id: String
    let name: String
    let image: String
    let config: String
    
    static func getCountries() -> [CountryModel] {
        [CountryModel(id: "de", name: "Germany", image: "flagGermany", config: ""),
         CountryModel(id: "ca", name: "Canada", image: "flagCanada", config: ""),
         CountryModel(id: "fr", name: "France", image: "flagFrance", config: ""),
         CountryModel(id: "pl", name: "Poland", image: "flagPoland", config: ""),
         CountryModel(id: "uk", name: "UK", image: "flagUK", config: ""),
         CountryModel(id: "us", name: "USA", image: "flagUSA", config: "")]
    }
}
