//
//  Collection.swift
//  Stopwatches
//
//  Created by Matsulenko on 03.03.2024.
//

import Foundation

extension Collection {
    func allEqual<T: Equatable>(by key: KeyPath<Element, T>) -> Bool {
        return allSatisfy { first?[keyPath:key] == $0[keyPath:key] }
    }
}
