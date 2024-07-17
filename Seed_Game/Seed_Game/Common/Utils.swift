//
//  Utils.swift
//  Seed_Game
//
//  Created by Tien Dinh on 13/7/24.
//

import Foundation

postfix operator &

postfix func & <T>(element: T?) -> String {
    return (element == nil) ? "" : "\(element!)"
}

postfix func & <T>(element: T) -> String {
    return "\(element)"
}

public typealias VoidClosure = (() -> Void)


func decode<T: Decodable>(_ data: Data, completion: @escaping ((T) -> Void)) {
    do {
        let model = try JSONDecoder().decode(T.self, from: data)
        completion(model)
    } catch DecodingError.dataCorrupted(let context) {
        print(context)
    } catch DecodingError.keyNotFound(let key, let context) {
        print("Key '\(key)' not found:", context.debugDescription)
        print("codingPath:", context.codingPath)
    } catch DecodingError.valueNotFound(let value, let context) {
        print("Value '\(value)' not found:", context.debugDescription)
        print("codingPath:", context.codingPath)
    } catch DecodingError.typeMismatch(let type, let context) {
        print("Type '\(type)' mismatch:", context.debugDescription)
        print("codingPath:", context.codingPath)
    } catch {
        print("error: ", error)
    }
}

extension LosslessStringConvertible {
    var string: String { .init(self) }
}
