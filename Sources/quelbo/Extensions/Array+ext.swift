//
//  Array+ext.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/8/22.
//

import Foundation
import Fizmo

extension Array {
    enum Error: Swift.Error {
        case foundMultipleFactories([SymbolFactory.Type])
        case noMatchingFactory(for: String)
        case symbolsTypeMismatch([Symbol])
        case tokensTypeMismatch([Token])
    }
}

extension Sequence where Iterator.Element: Hashable {
    var unique: [Iterator.Element] {
        var seen: Set<Iterator.Element> = []
        return filter { seen.insert($0).inserted }
    }
}
