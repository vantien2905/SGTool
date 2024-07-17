//
//  UserDefault+.swift
//  Seed_Game
//
//  Created by Tien Dinh on 14/7/24.
//

import Foundation

class UserDefaultManager {

    // Store data in UserDefaults
    class func save(_ value: Any, forKey key: ConfigKey) {
        UserDefaults.standard.set(value, forKey: key.rawValue)
        UserDefaults.standard.synchronize()
    }

    // Retrieve data from UserDefaults
    class func get(forKey key: ConfigKey) -> String {
        return UserDefaults.standard.string(forKey: key.rawValue)&
    }

    // Delete data from UserDefaults
    class func delete(forKey key: String) {
        UserDefaults.standard.removeObject(forKey: key)
        UserDefaults.standard.synchronize()
    }
}

enum ConfigKey: String {
    case tokenGetList
    case tokenBuy
}
