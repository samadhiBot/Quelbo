//
//  Instance.swift
//  Quelbo
//
//  Created by Chris Sessions on 7/9/22.
//

import CustomDump
import Foundation

final class Instance: SymbolType {
    let variable: Variable
    private(set) var isMutable: Bool?
    private(set) var isOptional: Bool
    private(set) var isZilElement: Bool
    private(set) var returnHandling: Symbol.ReturnHandling

    init(
        _ variable: Variable,
        isOptional: Bool = false,
        isMutable: Bool? = nil
    ) {
        self.isMutable = isMutable // ?? variable.isMutable
        self.isOptional = isOptional
        self.isZilElement = false
        self.returnHandling = .implicit
        self.variable = variable
    }

    var category: Category? {
        nil
    }

    var code: String {
        if isZilElement {
            switch variable.category {
            case .objects: return ".object(\(variable.id))"
            case .rooms: return ".room(\(variable.id))"
            default: break
            }
            switch variable.type.dataType {
            case .bool: return ".bool(\(variable.id))"
            case .int16: return ".int16(\(variable.id))"
            case .int32: return ".int32(\(variable.id))"
            case .int8: return ".int8(\(variable.id))"
            case .int: return ".int(\(variable.id))"
            case .object: return ".object(\(variable.id))"
            case .string: return ".string(\(variable.id))"
            case .table: return ".table(\(variable.id))"
            default: break
            }
        }
        return variable.code
    }

    var type: TypeInfo {
        isZilElement ? .zilElement : variable.type
    }
}

// MARK: - Symbol Value initializer

extension Symbol {
    static func instance(
        _ variable: Variable,
        isOptional: Bool = false
    ) -> Symbol {
        .instance(Instance(
            variable,
            isOptional: isOptional
        ))
    }
}

// MARK: - Special assertion handlers

extension Instance {
    func assertHasMutability(_ mutability: Bool) throws {
        switch isMutable {
        case mutability:
            return
        case .none:
            isMutable = mutability
        default:
            throw Symbol.AssertionError.hasMutabilityAssertionFailed(
                for: "\(Self.self)",
                asserted: mutability,
                actual: isMutable
            )
        }
    }

    func assertHasType(_ assertedType: TypeInfo) throws {
        try variable.assertHasType(assertedType)

        if assertedType.dataType == .zilElement {
            isZilElement = true
        }
    }
}


// MARK: - Conformances

extension Instance: CustomDumpReflectable {
    var customDumpMirror: Mirror {
        .init(
            self,
            children: [
                "variable": self.variable,
                "isMutable": self.isMutable as Any,
                "isOptional": self.isOptional,
                "isZilElement": self.isZilElement,
                "returnHandling": self.returnHandling,
            ],
            displayStyle: .struct
        )
    }
}

extension Instance: Equatable {
    static func == (lhs: Instance, rhs: Instance) -> Bool {
        lhs.variable == rhs.variable &&
        lhs.isMutable == rhs.isMutable &&
        lhs.isOptional == rhs.isOptional &&
        lhs.isZilElement == rhs.isZilElement &&
        lhs.returnHandling == rhs.returnHandling
    }
}
