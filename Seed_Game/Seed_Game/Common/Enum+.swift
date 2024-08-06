//
//  Enum+.swift
//  Seed_Game
//
//  Created by Tien Dinh on 13/7/24.
//

import Foundation


enum EggStatus: String, Codable {
    case inInventory = "in-inventory"
    case onMarket = "on-market"
}

enum Category: String {
    case egg
    case worm
    
    func getName() -> String {
        switch self {
        case .egg:
            return "TRỨNG"
        case .worm:
            return "SÂU"
        }
    }
    
    func getTypeParam() -> String {
        switch self {
        case .egg:
            return  "egg"
        case .worm:
            return "worms"
        }
    }
    func getMarketType() -> String {
        switch self {
        case .egg:
            return  "egg"
        case .worm:
            return "worm"
        }
    }
    
    func getKeyID() -> String {
        return self == .worm ? "worm_id" : "egg_id"
    }
}


enum RarityType: String {
    case common
    case uncommon
    case rare
    case epic
    case legendary
    
    func getDisplayString() -> String {
        switch self {
        case .common:
            return "CO"
        case .uncommon:
            return "UN"
        case .rare:
            return "RA"
        case .epic:
            return "EP"
        case .legendary:
            return "LG"
        }
    }
}

enum MarketType: String {
    case worm
    case egg
}
