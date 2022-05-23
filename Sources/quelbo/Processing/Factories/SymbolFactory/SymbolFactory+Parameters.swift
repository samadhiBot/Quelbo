//
//  SymbolFactory+Parameters.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/16/22.
//

import Foundation

extension SymbolFactory {
    /// <#Description#>
    enum Parameters: Equatable {
        case zero
        case zeroOrOne(Symbol.DataType)
        case zeroOrMore(Symbol.DataType)
        case one(Symbol.DataType)
        case oneOrMore(Symbol.DataType)
        case two(Symbol.DataType, Symbol.DataType)
        case twoOrMore(Symbol.DataType)
        case three(Symbol.DataType, Symbol.DataType, Symbol.DataType)
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

        func type(at index: Int) throws -> Symbol.DataType {
            switch self {
            case .zero:
                throw FactoryError.invalidTypeLookup(at: index)
            case let .zeroOrOne(type):
                return type
            case let .zeroOrMore(type):
                return type
            case let .one(type):
                switch index {
                case 0:  return type
                default: throw FactoryError.invalidTypeLookup(at: index)
                }
            case let .oneOrMore(type):
                return type
            case let .two(firstType, secondType):
                switch index {
                case 0:  return firstType
                case 1:  return secondType
                default: throw FactoryError.invalidTypeLookup(at: index)
                }
            case let .twoOrMore(type):
                return type
            case let .three(firstType, secondType, thirdType):
                switch index {
                case 0:  return firstType
                case 1:  return secondType
                case 2:  return thirdType
                default: throw FactoryError.invalidTypeLookup(at: index)
                }
            case .any:
                return .unknown
            }
        }
    }
}
