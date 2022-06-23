//
//  SymbolFactory+ProgramBlockType.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/16/22.
//

import Foundation

extension SymbolFactory {
    /// The set of possible program block types.
    enum ProgramBlockType: Hashable {
        /// A program block with the specified activation.
        case blockWithActivation(String)

        /// A program block with a default activation.
        case blockWithDefaultActivation

        /// A program block without a default activation.
        case blockWithoutDefaultActivation

        /// A repeating program block with the specified activation.
        case repeatingWithActivation(String)

        /// A repeating program block with a default activation.
        case repeatingWithDefaultActivation

        /// A repeating program block without a default activation.
        case repeatingWithoutDefaultActivation


        var activation: String? {
            switch self {
            case .blockWithActivation(let string):
                return string
            case .repeatingWithActivation(let string):
                return string
            default:
                return nil
            }
        }

        var hasActivation: Bool {
            switch self {
            case .blockWithoutDefaultActivation, .repeatingWithoutDefaultActivation:
                return false
            default:
                return true
            }
        }

        var isRepeating: Bool {
            switch self {
            case .repeatingWithActivation, .repeatingWithDefaultActivation:
                return true
            default:
                return false
            }
        }

        mutating func makeRepeating() {
            switch self {
            case .blockWithActivation(let string):
                self = .repeatingWithActivation(string)
            case .blockWithDefaultActivation:
                self = .repeatingWithDefaultActivation
            case .blockWithoutDefaultActivation:
                self = .repeatingWithoutDefaultActivation
            default:
                break
            }
        }

        mutating func setActivation(_ string: String) {
            switch self {
            case .blockWithActivation,
                 .blockWithDefaultActivation,
                 .blockWithoutDefaultActivation:
                self = .blockWithActivation(string)
            case .repeatingWithActivation,
                 .repeatingWithDefaultActivation,
                 .repeatingWithoutDefaultActivation:
                self = .repeatingWithActivation(string)
            }
        }
    }
}
