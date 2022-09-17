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
    private(set) var type: TypeInfo
    private(set) var isMutable: Bool?
//    private(set) var isZilElement: Bool

    init(
        code: String,
        type: TypeInfo
    ) {
        self._code = code
//        self.isZilElement = false
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
        if type.isZilElement {
            switch type.dataType {
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

        switch (_code, type.dataType) {
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
            type: .init(
                dataType: .bool,
                confidence: bool ? .booleanTrue : .booleanFalse
            )
        ))
    }

    static func literal(_ int64: Int) -> Symbol {
        .literal(Literal(
            code: int64.description,
            type: .init(
                dataType: .int,
                confidence: int64 == 0 ? .integerZero : .certain
            )
        ))
    }

    static func literal(_ int32: Int32) -> Symbol {
        .literal(Literal(
            code: int32.description,
            type: .init(
                dataType: .int32,
                confidence: int32 == 0 ? .integerZero : .certain
            )
        ))
    }

    static func literal(_ int16: Int16) -> Symbol {
        .literal(Literal(
            code: int16.description,
            type: .init(
                dataType: .int16,
                confidence: int16 == 0 ? .integerZero : .certain
            )
        ))
    }

    static func literal(_ int8: Int8) -> Symbol {
        .literal(Literal(
            code: int8.description,
            type: .init(
                dataType: .int8,
                confidence: int8 == 0 ? .integerZero : .certain
            )
        ))
    }

    static func literal(_ string: String) -> Symbol {
        .literal(Literal(
            code: string.quoted,
            type: .string
        ))
    }
}

// MARK: - Special assertion handlers

extension Literal {
    func assertHasType(_ assertedType: TypeInfo) throws {
        guard let reconciled = type.reconcile(with: assertedType) else {
            throw Symbol.AssertionError.hasTypeAssertionLiteralFailed(
                for: _code,
                asserted: assertedType,
                actual: type
            )
        }

        self.type = reconciled //.asNonOptional

//        if assertedType.dataType == .zilElement {
//            self.isZilElement = true
//            self.type = .init(
//                dataType: type.dataType,
//                confidence: .certain
//            )
//            return
//        }
//
//        if type.confidence == .certain && assertedType.confidence == .certain {
//            throw Symbol.AssertionError.hasTypeAssertionLiteralFailed(
//                for: _code,
//                asserted: assertedType,
//                actual: type
//            )
//        }
//        guard assertedType.confidence > type.confidence else { return }
//
//        type = assertedType
    }
}

// MARK: - Conformances

extension Literal: CustomDumpReflectable {
    var customDumpMirror: Mirror {
        .init(
            self,
            children: [
                "code": self.code,
//                "isZilElement": self.isZilElement,
                "type": self.type as Any,
            ],
            displayStyle: .struct
        )
    }
}

extension Literal: Equatable {
    static func == (lhs: Literal, rhs: Literal) -> Bool {
        lhs._code == rhs._code &&
        lhs.type == rhs.type
    }
}
