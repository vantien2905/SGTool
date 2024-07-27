//
//  LimitedQueue.swift
//  UserApp
//
//  Created by An Nguyen on 8/6/24.
//

import Foundation

class LimitedQueue<T: Codable> {
    var items: [T] = []
    private let maxSize: Int

    init(maxSize: Int) {
        self.maxSize = maxSize
    }

    func enqueue(_ item: T) {
        if items.count >= maxSize {
            items.removeLast() // Remove the oldest item
        }
        items.insert(item, at: 0)
    }

    func dequeue() -> T? {
        guard !items.isEmpty else {
            return nil
        }
        let item = items.removeLast()
        return item
    }

    func allItems() -> [T] {
        return items
    }
    
    func dequeueAll() {
        items.removeAll()
    }
    

    
    func isEmpty() -> Bool {
        return items.isEmpty
    }
}
