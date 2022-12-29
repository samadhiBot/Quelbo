//
//  Symbol+ReturnHandling.swift
//  Quelbo
//
//  Created by Chris Sessions on 9/20/22.
//

import Foundation

extension Symbol {
    /// Signifies how a symbol should behave when it comes to returning a value.
    enum ReturnHandling: Int {
        /// The symbol never returns a value.
        case suppressed

        /// The symbol never returns a value, but one or more of its children might.
        case suppressedPassthrough

        /// The symbol is a block or conditional that normally does not return a value, but one or
        /// more of its children might.
        case passthrough

        /// The symbol returns a value under the right context.
        case implicit

        /// The symbol is a block or conditional that returns a value, as returned by one or more
        /// of its children might.
        case forcedPassthrough

        /// The symbol always returns a value.
        case forced
    }
}

extension Symbol.ReturnHandling {
    var isPassthrough: Bool {
        self == .passthrough || self == .forcedPassthrough || self == .suppressedPassthrough
    }
}

// MARK: - Conformances

extension Symbol.ReturnHandling: Comparable {
    static func < (lhs: Symbol.ReturnHandling, rhs: Symbol.ReturnHandling) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
