//
//  Output.swift
//  Fizmo
//
//  Created by Chris Sessions on 3/24/22.
//

import Foundation

private var outputBuffer = ""

public func output(_ character: Character) {
    outputBuffer.append(character)
}

public func output(_ number: Int) {
    outputBuffer.append("\(number)")
}

public func output(_ string: String, withCarriageReturn: Bool = false) {
    outputBuffer.append("\(string)")
    if withCarriageReturn {
        outputBuffer.append("\n")
    }
}

public func outputFlush() -> String {
    defer {
        outputBuffer = ""
    }
    return outputBuffer
}
