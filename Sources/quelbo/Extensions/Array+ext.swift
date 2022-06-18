//
//  Array+ext.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/8/22.
//

import Foundation

extension Array {
    /// Safely shifts an `Element` from the front of an `Array`.
    ///
    /// - Returns: The first `Element` of the `Array`. Returns `nil` if the array is empty.
    public mutating func shift() -> Element? {
        guard !isEmpty else { return nil }
        return removeFirst()
    }
}

extension Sequence where Iterator.Element: Hashable {
    var unique: [Iterator.Element] {
        var seen: Set<Iterator.Element> = []
        return filter { seen.insert($0).inserted }
    }
}
