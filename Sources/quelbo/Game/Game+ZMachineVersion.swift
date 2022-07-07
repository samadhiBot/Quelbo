//
//  Game+ZMachineVersion.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/7/22.
//

import Foundation

extension Game {
    /// The ZMachine version to emulate during processing.
    ///
    enum ZMachineVersion: String {
        case z3
        case z3Time
        case z4
        case z5
        case z6
        case z7
        case z8

        init(tokens: [Token]) throws {
            guard (1...2).contains(tokens.count) else {
                throw GameError.invalidZMachineVersion(tokens)
            }
            switch tokens[0] {
            case .atom("ZIP"), .decimal(3):
                if case .atom("TIME") = tokens.last {
                    self = .z3Time
                } else {
                    self = .z3
                }
            case .atom("EZIP"), .decimal(4):
                self = .z4
            case .atom("XZIP"), .decimal(5):
                self = .z5
            case .atom("YZIP"), .decimal(6):
                self = .z6
            case .decimal(7):
                self = .z7
            case .decimal(8):
                self = .z8
            default:
                throw GameError.invalidZMachineVersion(tokens)
            }
        }

        /// An integer representation of the ZMachine version.
        private var version: Int {
            switch self {
            case .z3:     return 3
            case .z3Time: return 3
            case .z4:     return 4
            case .z5:     return 5
            case .z6:     return 6
            case .z7:     return 7
            case .z8:     return 8
            }
        }
    }
}

// MARK: - Conformances

extension Game.ZMachineVersion: Comparable {
    static func < (lhs: Game.ZMachineVersion, rhs: Game.ZMachineVersion) -> Bool {
        lhs.version < rhs.version
    }
}
