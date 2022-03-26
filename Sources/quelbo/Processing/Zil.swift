//
//  Zil.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/12/22.
//

import Foundation

enum Zil: String {
    case `repeat` =               "REPEAT"
    case add =                    "+"
    case and =                    "AND"
    case clearFlag =              "FCLEAR"
    case condition =              "COND"
    case crlf =                   "CRLF"
    case decrementLessThan =      "DLESS?"
    case divide =                 "/"
    case get =                    "GET"
    case getProperty =            "GETP"
    case isEqualTo =              "=?"
    case isGreaterThan =          "G?"
    case isGreaterThanOrEqualTo = "G=?"
    case isLessThan =             "L?"
    case isLessThanOrEqualTo =    "L=?"
    case isNotEqualTo =           "N=?"
    case isOne =                  "isOne"
    case isZero =                 "isZero"
    case move =                   "MOVE"
    case multiply =               "*"
    case or =                     "OR"
    case print =                  "PRINT"
    case printCharacter =         "PRINTC"
    case printDescription =       "PRINTD"
    case printStringCR =          "PRINTR"
    case printTable =             "PRINTF"
    case programBlock =           "PROG"
    case putProperty =            "PUTP"
    case returnFalse =            "RFALSE"
    case returnTrue =             "RTRUE"
    case set =                    "SET"
    case setFlag =                "FSET"
    case setGlobal =              "SETG"
    case subtract =               "-"
    case tell =                   "TELL"
}

extension Zil {
    init?(_ keyword: String) {
        if let zil = Zil(rawValue: keyword) ?? Zil.altName(rawValue: keyword) {
            self = zil
        } else {
            return nil
        }
    }

    var process: ([Token]) throws -> String {
        switch self {
        case .add:                    return add
        case .and:                    return and
        case .clearFlag:              return clearFlag
        case .condition:              return condition
        case .crlf:                   return crlf
        case .decrementLessThan:      return decrementLessThan
        case .divide:                 return divide
        case .get:                    return `get`
        case .getProperty:            return getProperty
        case .isEqualTo:              return isEqualTo
        case .isGreaterThan:          return isGreaterThan
        case .isGreaterThanOrEqualTo: return isGreaterThanOrEqualTo
        case .isLessThan:             return isLessThan
        case .isLessThanOrEqualTo:    return isLessThanOrEqualTo
        case .isNotEqualTo:           return isNotEqualTo
        case .isOne:                  return isOne
        case .isZero:                 return isZero
        case .move:                   return move
        case .multiply:               return multiply
        case .or:                     return or
        case .print:                  return print
        case .printCharacter:         return printCharacter
        case .printDescription:       return printDescription
        case .printStringCR:          return printStringCR
        case .printTable:             return printTable
        case .programBlock:           return programBlock
        case .putProperty:            return putProperty
        case .repeat:                 return `repeat`
        case .returnFalse:            return returnFalse
        case .returnTrue:             return returnTrue
        case .set:                    return `set`
        case .setFlag:                return setFlag
        case .setGlobal:              return setGlobal
        case .subtract:               return subtract
        case .tell:                   return tell
        }
    }
}

extension Zil {
    enum Err: Error {
        case invalidValue(String)
        case missingName(String)
        case missingObject(String)
        case missingParams(String)
        case missingProperty(String)
        case missingTable(String)
        case missingValue(String)
        case unconsumedTokens(String)
        case unimplemented(String)
    }

    static func altName(rawValue: String) -> Zil? {
        switch rawValue {
        case "==?":    return .isEqualTo
        case "BACK":   return .subtract
        case "EQUAL?": return .isEqualTo
        case "GRTR?":  return .isGreaterThan
        case "LESS?":  return .isLessThan
        case "N==?":   return .isNotEqualTo
        case "PRINTB": return .print
        case "PRINTI": return .print
        case "PRINTN": return .print
        case "PRINTT": return .printTable
        case "PRINTU": return .printCharacter
        case "SUB":    return .subtract
        default:       return nil
        }
    }
}
