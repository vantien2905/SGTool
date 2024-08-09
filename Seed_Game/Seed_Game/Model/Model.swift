//
//  Model.swift
//  Seed_Game
//
//  Created by Tien Dinh on 13/7/24.
//

import Foundation

// MARK: - Welcome
struct ItemResponse: Codable {
    let data: ItemData?
}

struct BuyResponse: Codable {
    let data: Item
}

// MARK: - Welcome
struct ERROR: Codable {
    let code, message: String?
}

// MARK: - DataClass
struct ItemData: Codable {
    let total, page, pageSize: Int?
    let items: [Item]?

    enum CodingKeys: String, CodingKey {
        case total, page
        case pageSize = "page_size"
        case items
    }
}

// MARK: - Item
struct Item: Codable {
    let id: String
    let eggID: String?
    let eggType: String?
    let wormType: String?
    let wormID: String?
    let priceGross: Double?
    let priceNet, fee: Double?
    let status: String?
    let createdBy: String?
    let boughtBy: JSONNull?
    let createdAt, updatedAt: String?
    var marketID: String?
    var type: String?

    enum CodingKeys: String, CodingKey {
        case id
        case eggID = "egg_id"
        case eggType = "egg_type"
        case wormID = "worm_id"
        case wormType = "worm_type"
        case priceGross = "price_gross"
        case priceNet = "price_net"
        case fee, status
        case createdBy = "created_by"
        case boughtBy = "bought_by"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case marketID = "market_id"
        case type
    }
    
    var price: Double {
        get {
            return (priceGross ?? 0) / coefficient
        }
    }
    
    func getType() -> RarityType? {
        if let wormType = wormType, !wormType.isEmpty {
            return RarityType(rawValue: wormType)
        }
        if let eggType, !eggType.isEmpty {
            return RarityType(rawValue: eggType)
        }
        return nil
    }
    func getCategory() -> Category {
        if eggID&.isEmpty {
            return .worm
        }
        return .egg
    }
}

enum Status: String, Codable {
    case onSale = "on-sale"
}

// MARK: - Encode/decode helpers

class JSONNull: Codable, Hashable {

    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
            return true
    }

    public var hashValue: Int {
            return 0
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if !container.decodeNil() {
                    throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
            }
    }

    public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encodeNil()
    }
}

public extension URLRequest {
    
    func cURL() -> String {
        let cURL = "curl -f"
        let method = "-X \(self.httpMethod ?? "GET")"
        let url = url.flatMap { "--url '\($0.absoluteString)'" }
        
        let header = self.allHTTPHeaderFields?
            .map { "-H '\($0): \($1)'" }
            .joined(separator: " ")
        
        let data: String?
        if let httpBody, !httpBody.isEmpty {
            if let bodyString = String(data: httpBody, encoding: .utf8) { // json and plain text
                let escaped = bodyString
                    .replacingOccurrences(of: "'", with: "'\\''")
                data = "--data '\(escaped)'"
            } else { // Binary data
                let hexString = httpBody
                    .map { String(format: "%02X", $0) }
                    .joined()
                data = #"--data "$(echo '\#(hexString)' | xxd -p -r)""#
            }
        } else {
            data = nil
        }
        
        return [cURL, method, url, header, data]
            .compactMap { $0 }
            .joined(separator: " ")
    }
    
}

//Delay task in main
func delay(_ time: Double, execute: @escaping () -> Void) {
    if time > 0 {
        DispatchQueue.main.asyncAfter(deadline: .now() + time, execute: execute)
    } else {
        DispatchQueue.main.async(execute: execute)
    }
}
