//
//  SymbolFactory+Parameters.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/16/22.
//

import Foundation

extension SymbolFactory {
    /// The set of parameter possibilities for a symbol factory.
    enum Parameters: Equatable {
        /// The factory expects zero token parameters.
        case zero

        /// The factory expects zero or one token parameters with the specified type.
        case zeroOrOne(Symbol.DataType)

        /// The factory expects zero or more token parameters with the specified type.
        case zeroOrMore(Symbol.DataType)

        /// The factory expects one token parameters with the specified type.
        case one(Symbol.DataType)

        /// The factory expects one or more token parameters with the specified type.
        case oneOrMore(Symbol.DataType)

        /// The factory expects two token parameters with the specified types.
        case two(Symbol.DataType, Symbol.DataType)

        /// The factory expects two or more token parameters with the specified type.
        case twoOrMore(Symbol.DataType)

        /// The factory expects three token parameters with the specified types.
        case three(Symbol.DataType, Symbol.DataType, Symbol.DataType)

        /// The factory expects any number of token parameters with any type.
        case any

        var range: ClosedRange<Int> {
            switch self {
            case .zero:       return 0...0
            case .zeroOrOne:  return 0...1
            case .zeroOrMore: return 0...Int.max
            case .one:        return 1...1
            case .oneOrMore:  return 1...Int.max
            case .two:        return 2...2
            case .twoOrMore:  return 2...Int.max
            case .three:      return 3...3
            case .any:        return 0...Int.max
            }
        }

        /// The data type at the specified `index` in a ``SymbolFactory/Parameters-swift.enum``
        /// case.
        ///
        /// - Parameter index: The index to fetch the expected data type.
        ///
        /// - Returns: The data type at the specified `index`.
        ///
        /// - Throws: When called with an `index` that is not valid for a given `Parameters` case.
        func expectedType(at index: Int) throws -> Symbol.DataType {
            switch self {
            case .zero:
                throw Error.invalidTypeLookup(at: index)
            case let .zeroOrOne(type):
                return type
            case let .zeroOrMore(type):
                return type
            case let .one(type):
                switch index {
                case 0:  return type
                default: throw Error.invalidTypeLookup(at: index)
                }
            case let .oneOrMore(type):
                return type
            case let .two(firstType, secondType):
                switch index {
                case 0:  return firstType
                case 1:  return secondType
                default: throw Error.invalidTypeLookup(at: index)
                }
            case let .twoOrMore(type):
                return type
            case let .three(firstType, secondType, thirdType):
                switch index {
                case 0:  return firstType
                case 1:  return secondType
                case 2:  return thirdType
                default: throw Error.invalidTypeLookup(at: index)
                }
            case .any:
                return .unknown
            }
        }
    }
}

// MARK: - Errors

extension SymbolFactory.Parameters {
    enum Error: Swift.Error {
        case invalidTypeLookup(at: Int)
    }
}
