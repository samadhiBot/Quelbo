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

        /// A program block without a default activation.
        case blockWithoutActivation

        /// A repeating program block with the specified activation.
        case repeatingWithActivation(String)

        /// A repeating program block without a default activation.
        case repeatingWithoutActivation


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
            case .blockWithActivation, .repeatingWithActivation:
                return true
            default:
                return false
            }
        }

        var isRepeating: Bool {
            switch self {
            case .repeatingWithActivation, .repeatingWithoutActivation:
                return true
            default:
                return false
            }
        }

        mutating func makeRepeating() {
            switch self {
            case .blockWithActivation(let string):
                self = .repeatingWithActivation(string)
            case .blockWithoutActivation:
                self = .repeatingWithoutActivation
            default:
                break
            }
        }

        mutating func setActivation(_ string: String) {
            switch self {
            case .blockWithActivation, .blockWithoutActivation:
                self = .blockWithActivation(string)
            case .repeatingWithActivation, .repeatingWithoutActivation:
                self = .repeatingWithActivation(string)
            }
        }
    }
}
