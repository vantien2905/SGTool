//
//  ApiUtils.swift
//  Seed_Game
//
//  Created by Tien Dinh on 13/7/24.
//

import Foundation


class ApiUtils {
    
    static let shared = ApiUtils()

    var headersBuy: [String: String] {
        get {
            [
                "telegram-data": UserDefaultManager.get(forKey: .tokenBuy),
                "user-agent": "AppleWebKit/537.36 (KHTML, like Gecko) C"
            ]
        }
    }
    
    var headersGet: [String: String] {
        get {
            [
                "User-Agent": "Safari/605.1.15",
                "telegram-data": UserDefaultManager.get(forKey: .tokenGetList)
            ]
        }
    }
    
    
}
