//
//  Int+ext.swift
//  Fizmo
//
//  Created by Chris Sessions on 3/23/22.
//

import Foundation

extension Int {
    public mutating func decrement() -> Int {
        self -= 1
        return self
    }
}
