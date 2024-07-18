//
//  Constants.swift
//  Seed_Game
//
//  Created by Tien Dinh on 14/7/24.
//

import Foundation

let coefficient: Double = 1000000000

enum PriceSuggest: Int {
    case egg
    case worm
    
    func price(rarity: Int) -> Double {
        switch self {
        case .worm:
            switch Rarity(rawValue: rarity)?.type {
            case .common: return 0.01
            case .uncommon: return 0.04
            case .rare: return 1.1
            case .epic: return 11
            case .legendary: return 60
            case nil: return 0
            }
        case .egg:
            switch Rarity(rawValue: rarity)?.type {
            case .common: return 29
            case .uncommon: return 60
            case .rare: return 200
            case .epic: return 300
            case .legendary: return 300
            case nil: return 0
            }
        }
    }
}
