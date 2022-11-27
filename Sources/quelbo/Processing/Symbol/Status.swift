//
//  Status.swift
//  Quelbo
//
//  Created by Chris Sessions on 11/23/22.
//

import Foundation

/// <#Description#>
enum Status: Int {
    case undetermined
    case mutable
    case fixed
}

extension Status {
    /// <#Description#>
    var isDetermined: Bool {
        self > .undetermined
    }
}

extension Status: Comparable {
    static func < (lhs: Status, rhs: Status) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

}
