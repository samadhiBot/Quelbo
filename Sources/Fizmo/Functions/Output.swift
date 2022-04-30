//
//  Output.swift
//  Fizmo
//
//  Created by Chris Sessions on 3/24/22.
//

import Foundation

private var outputBuffer = "" {
    didSet {
        #if DEBUG
        print("➡️ \(outputBuffer)")
        #endif
    }
}

/// Output a single character.
///
/// - Parameter character: The character to output.
public func output(_ character: Character) {
    outputBuffer.append(character)
}

/// Output a number.
///
/// - Parameter number: The number to output.
public func output(_ number: Int) {
    outputBuffer.append("\(number)")
}

/// Output a string.
///
/// - Parameter string: The string to output.
public func output(_ string: String) {
    outputBuffer.append(string)
}

/// Output a character represented by the specified unicode scaler.
///
/// - Parameter utf8: The unicode scaler to output.
public func output(utf8: UInt8) {
    let scaler = UnicodeScalar(utf8)
    let character = Character(scaler)
    output(character)
}

/// Return the output buffer and then empty the buffer.
///
/// - Returns: A string containing the output buffer contents since the last flush.
public func outputFlush() -> String {
    defer {
        outputBuffer = ""
    }
    return outputBuffer
}
