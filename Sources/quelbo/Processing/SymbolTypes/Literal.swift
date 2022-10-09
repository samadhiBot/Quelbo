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
    private(set) var returnHandling: Symbol.ReturnHandling

    init(
        code: String,
        type: TypeInfo
    ) {
        self._code = code
        self.returnHandling = .implicit
        self.type = type
    }

    var category: Category? {
        nil
    }

    var code: String {
        if type.isZilElement {
            switch type.dataType {
            case .bool: return ".bool(\(_code))"
            case .int16: return ".int16(\(_code))"
            case .int32: return ".int32(\(_code))"
            case .int8: return ".int8(\(_code))"
            case .int: return ".int(\(_code))"
            case .object: return ".object(\(_code))"
            case .string: return ".string(\(_code))"
            case .table: return ".table(\(_code))"
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

    static func verb(_ verb: String) -> Symbol {
        .literal(Literal(
            code: verb,
            type: .verb
        ))
    }

    static func zilAtom(_ zil: String) -> Symbol {
        .literal(Literal(
            code: zil,
            type: .zilAtom
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

        self.type = reconciled
    }
}

// MARK: - Conformances

extension Literal: CustomDumpReflectable {
    var customDumpMirror: Mirror {
        .init(
            self,
            children: [
                "code": self.code,
                "type": self.type as Any,
                "returnHandling": self.returnHandling,
            ],
            displayStyle: .struct
        )
    }
}

extension Literal: Equatable {
    static func == (lhs: Literal, rhs: Literal) -> Bool {
        lhs._code == rhs._code &&
        lhs.returnHandling == rhs.returnHandling &&
        lhs.type == rhs.type
    }
}
