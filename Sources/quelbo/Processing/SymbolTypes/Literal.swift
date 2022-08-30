//
//  Literal.swift
//  Quelbo
//
//  Created by Chris Sessions on 7/9/22.
//

import CustomDump
import Foundation

final class Literal: SymbolType {
    let _code: String
    private(set) var type: DataType?
    private(set) var confidence: DataType.Confidence?
    private(set) var isMutable: Bool?
    private(set) var isZilElement: Bool

    init(
        code: String,
        type: DataType,
        confidence: DataType.Confidence
    ) {
        self._code = code
        self.confidence = confidence
        self.isZilElement = false
        self.type = type
    }

    var category: Category? {
        nil
    }

    /*
     ZilElements:

     case bool(Bool)
     case int(Int)
     case int8(Int8)
     case int16(Int16)
     case int32(Int32)
     case lexv(Int16, Int8, Int8)
     case none
     case object(Object)
     case room(Room)
     case string(String)
     case table(Table)
     */

    var code: String {
        if isZilElement {
            switch type {
//            case .array(_): return ".array(_)(\(_code))"
            case .bool: return ".bool(\(_code))"
//            case .comment: return ".comment(\(_code))"
//            case .direction: return ".direction(\(_code))"
            case .int16: return ".int16(\(_code))"
            case .int32: return ".int32(\(_code))"
            case .int8: return ".int8(\(_code))"
            case .int: return ".int(\(_code))"
            case .object: return ".object(\(_code))"
//            case .optional(_): return ".optional(_)(\(_code))"
//            case .property(_): return ".property(_)(\(_code))"
//            case .routine: return ".routine(\(_code))"
            case .string: return ".string(\(_code))"
            case .table: return ".table(\(_code))"
//            case .thing: return ".thing(\(_code))"
//            case .unknown, .none: return ".unknown(\(_code))"
//            case .variable(_): return ".variable(_)(\(_code))"
//            case .void: return ".void(\(_code))"
//            case .zilElement: return ".zilElement(\(_code))"
            default: break
            }
        }

        switch (_code, type) {
        case ("false", .bool): return "false"
        case ("false", .int): return "0"
        case ("false", .int32): return "0"
        case ("false", .int16): return "0"
        case ("false", .int8): return "0"
        case ("false", _): return "nil"

        case ("true", .bool): return "true"
        case ("true", .int): return "1"
        case ("true", .int32): return "1"
        case ("true", .int16): return "1"
        case ("true", .int8): return "1"

        case ("0", .bool): return "false"
        case ("0", .int): return "0"
        case ("0", .int32): return "0"
        case ("0", .int16): return "0"
        case ("0", .int8): return "0"
        case ("0", _): return "nil"

        default: return _code
        }
    }
}

// MARK: - Symbol Literal initializers

extension Symbol {
    static func literal(_ bool: Bool) -> Symbol {
        .literal(Literal(
            code: bool.description,
            type: .bool,
            confidence: bool ? .booleanTrue : .booleanFalse
        ))
    }

    static func literal(_ int64: Int) -> Symbol {
        .literal(Literal(
            code: int64.description,
            type: .int,
            confidence: int64 == 0 ? .integerZero : .certain
        ))
    }

    static func literal(_ int32: Int32) -> Symbol {
        .literal(Literal(
            code: int32.description,
            type: .int32,
            confidence: int32 == 0 ? .integerZero : .certain
        ))
    }

    static func literal(_ int16: Int16) -> Symbol {
        .literal(Literal(
            code: int16.description,
            type: .int16,
            confidence: int16 == 0 ? .integerZero : .certain
        ))
    }

    static func literal(_ int8: Int8) -> Symbol {
        .literal(Literal(
            code: int8.description,
            type: .int8,
            confidence: int8 == 0 ? .integerZero : .certain
        ))
    }

    static func literal(_ string: String) -> Symbol {
        .literal(Literal(
            code: string.quoted,
            type: .string,
            confidence: .certain
        ))
    }
}

// MARK: - Special assertion handlers

extension Literal {
    func assertHasType(
        _ dataType: DataType?,
        confidence assertionConfidence: DataType.Confidence?
    ) throws {
        guard
            let dataType = dataType,
            let assertionConfidence = assertionConfidence,
            type != dataType
        else { return }

        if dataType == .zilElement {
            isZilElement = true
            confidence = .certain
            return
        }

        if confidence == .certain && assertionConfidence == .certain {
            throw Symbol.AssertionError.hasTypeAssertionFailed(
                for: "Literal: \(_code)",
                asserted: dataType,
                actual: type
            )
        }
        guard assertionConfidence > confidence ?? .unknown else { return }

        type = dataType
        confidence = assertionConfidence
    }
}

// MARK: - Conformances

extension Literal: CustomDumpReflectable {
    var customDumpMirror: Mirror {
        .init(
            self,
            children: [
                "code": self.code,
                "confidence": self.confidence as Any,
                "isZilElement": self.isZilElement,
                "type": self.type as Any,
            ],
            displayStyle: .struct
        )
    }
}

extension Literal: Equatable {
    static func == (lhs: Literal, rhs: Literal) -> Bool {
        lhs._code == rhs._code &&
        lhs.confidence == rhs.confidence &&
        lhs.type == rhs.type
    }
}
