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

enum Category: Int {
    case egg
    case worm
    
    var type: String {
        switch self {
        case .egg:
            return "egg"
        case .worm:
            return "worm"
        }
    }
}

enum Rarity: Int, Codable {
    case common
    case uncommon
    case rare
    case epic
    case legendary
    
    var type: RarityType {
        switch self {
        case .common:
            return .common
        case .uncommon:
            return .uncommon
        case .rare:
            return .rare
        case .epic:
            return .epic
        case .legendary:
            return .legendary
        }
    }
}

enum RarityType: String {
    case common
    case uncommon
    case rare
    case epic
    case legendary
}

enum MarketType: String {
    case worm
    case egg
}
