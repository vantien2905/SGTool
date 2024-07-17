//
//  String+.swift
//  Seed_Game
//
//  Created by Tien Dinh on 17/7/24.
//

import Foundation


extension String {
    var toDouble: Double {
        return Double(self) ?? 0
    }
    
    var toInt: Int {
        return Int(self) ?? 0
    }
}
