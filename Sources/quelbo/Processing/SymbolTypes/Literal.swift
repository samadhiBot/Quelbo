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
    private(set) var isMutable: Bool?
    private(set) var returnHandling: Symbol.ReturnHandling
    private(set) var type: TypeInfo

    init(
        code: String,
        type: TypeInfo,
        returnHandling: Symbol.ReturnHandling = .forced
    ) {
        self._code = code
        self.returnHandling = returnHandling
        self.type = type
    }

    var category: Category? {
        nil
    }

    var code: String {
        switch (_code, type.dataType) {
        case ("false", .bool): return "false"
        case ("false", .int), ("false", .int32), ("false", .int16), ("false", .int8): return "0"
        case ("false", _): return "nil"

        case ("true", .bool): return "true"
        case ("true", .int), ("true", .int32), ("true", .int16), ("true", .int8): return "1"

        case ("0", .bool): return "false"
        case ("0", .int), ("0", .int32), ("0", .int16), ("0", .int8): return "0"
        case ("0", _): return "nil"

        case (_, .verb): return "Verb.\(_code)"
        case (_, .word): return "Word.\(_code)"

        default: return _code
        }
    }

    var codeMultiType: String {
        guard type.isTableElement == true else { return code }

        switch type.dataType {
        case .bool: return ".bool(\(_code))"
        case .int16: return ".int16(\(_code))"
        case .int32: return ".int32(\(_code))"
        case .int8: return ".int8(\(_code))"
        case .int: return ".int(\(_code))"
        case .object: return ".object(\(_code))"
        case .string: return ".string(\(_code))"
        case .table: return ".table(\(_code))"
        default: return code
        }
    }
}

// MARK: - Literal true/false initializers

extension Literal {
    /// <#Description#>
    static var `false`: Literal {
        .init(
            code: "false",
            type: .booleanFalse
        )
    }

    /// <#Description#>
    static var `true`: Literal {
        .init(
            code: "true",
            type: .booleanTrue
        )
    }
}

extension Symbol {
    /// <#Description#>
    static var `false`: Symbol {
        .literal(.false)
    }

    /// <#Description#>
    static var `true`: Symbol {
        .literal(.true)
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
        let confidence: TypeInfo.Confidence = {
            switch int64 {
            case 0: return .integerZero
            case 1: return .integerOne
            default: return .certain
            }
        }()

        return .literal(Literal(
            code: int64.description,
            type: .init(
                dataType: .int,
                confidence: confidence
            )
        ))
    }

    static func literal(_ int32: Int32) -> Symbol {
        let confidence: TypeInfo.Confidence = {
            switch int32 {
            case 0: return .integerZero
            case 1: return .integerOne
            default: return .certain
            }
        }()

        return .literal(Literal(
            code: int32.description,
            type: .init(
                dataType: .int32,
                confidence: confidence
            )
        ))
    }

    static func literal(_ int16: Int16) -> Symbol {
        let confidence: TypeInfo.Confidence = {
            switch int16 {
            case 0: return .integerZero
            case 1: return .integerOne
            default: return .certain
            }
        }()

        return .literal(Literal(
            code: int16.description,
            type: .init(
                dataType: .int16,
                confidence: confidence
            )
        ))
    }

    static func literal(_ int8: Int8) -> Symbol {
        let confidence: TypeInfo.Confidence = {
            switch int8 {
            case 0: return .integerZero
            case 1: return .integerOne
            default: return .certain
            }
        }()

        return .literal(Literal(
            code: int8.description,
            type: .init(
                dataType: .int8,
                confidence: confidence
            )
        ))
    }

    static func literal(_ string: String) -> Symbol {
        .literal(Literal(
            code: string.quoted,
            type: .string
        ))
    }

    static func partsOfSpeech(_ partsOfSpeech: String) -> Symbol {
        .literal(Literal(
            code: "PartsOfSpeech.\(partsOfSpeech)",
            type: .partsOfSpeech
        ))
    }

    static func verb(_ verb: String) -> Symbol {
        .literal(Literal(
            code: verb,
            type: .verb
        ))
    }

    static func word(_ word: String) -> Symbol {
        .literal(Literal(
            code: word,
            type: .word
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
    func assertHasReturnHandling(_ assertedHandling: Symbol.ReturnHandling) throws {
        switch (assertedHandling, returnHandling) {
        case (.forced, .suppressed), (.suppressed, .forced):
            throw Symbol.AssertionError.hasReturnHandlingAssertionFailed(
                for: code,
                asserted: assertedHandling,
                actual: returnHandling
            )
        default:
            self.returnHandling = assertedHandling
        }
    }

    func assertHasType(_ assertedType: TypeInfo) throws {
        self.type = try type.reconcile(".literal(\(_code))", with: assertedType)
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
            ],
            displayStyle: .struct
        )
    }
}

extension Literal: Equatable {
    static func == (lhs: Literal, rhs: Literal) -> Bool {
        lhs._code == rhs._code &&
        lhs.type.dataType == rhs.type.dataType
    }
}
