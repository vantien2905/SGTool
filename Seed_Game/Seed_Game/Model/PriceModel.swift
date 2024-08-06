//
//  PriceModel.swift
//  Seed_Game
//
//  Created by An Nguyen on 5/8/24.
//

import Foundation

class PriceModel {
    static let shared = PriceModel()

    private init() {}
    
    var wCmBuy: Double? = 0.1
    var wUcmBuy: Double? = 0.2
    var wRaBuy: Double? = 1.0
    var wEpBuy: Double? = 8.0
    var wLgBuy: Double? = 50.0
    var wCmSell: Double? = 1.5
    var wUcmSell: Double? = 3
    var wRaSell: Double? = 8
    var wEpSell: Double? = 30
    var wLgSell: Double?
    var eCmBuy: Double? = 30
    var eUcmBuy: Double? = 80
    var eRaBuy: Double? = 150
    var eEpBuy: Double? = 1000
    var eLgBuy: Double? = 10000
    var eCmSell: Double?
    var eUcmSell: Double?
    var eRaSell: Double?
    var eEpSell: Double?
    var eLgSell: Double?
}
