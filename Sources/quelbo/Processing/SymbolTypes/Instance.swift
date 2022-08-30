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

    init(
        _ variable: Variable,
        isOptional: Bool = false,
        isMutable: Bool? = nil
    ) {
////        self.confidence = variable.confidence
        self.isMutable = isMutable // ?? variable.isMutable
        self.isOptional = isOptional
        self.isZilElement = false
//        self.type = variable.type
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
            switch variable.type {
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

    var confidence: DataType.Confidence? {
        variable.confidence
    }

    var type: DataType? {
        isZilElement ? .zilElement : variable.type
    }
}

// MARK: - Symbol Value initializer

extension Symbol {
    static func instance(
        _ variable: Variable,
        isOptional: Bool = false
//        isMutable: Bool = false
    ) -> Symbol {
        .instance(Instance(
            variable,
            isOptional: isOptional
////            isMutable: isMutable
        ))
    }
}

// MARK: - Special assertion handlers

extension Instance {
//    func assertHasCategory(_ assertionCategory: Category) throws {
//        if let category = category, assertionCategory != category {
//            throw Symbol.AssertionError.hasCategoryFailed(
//                asserted: assertionCategory,
//                actual: category
//            )
//        }
//        self.category = assertionCategory
//    }

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

    func assertHasType(
        _ dataType: DataType?,
        confidence assertionConfidence: DataType.Confidence?
    ) throws {
        try variable.assertHasType(dataType, confidence: assertionConfidence)

        if dataType == .zilElement {
            isZilElement = true
//            confidence = .certain
            return
        }

//        if self.ca

//        if confidence == .certain && assertionConfidence == .certain {
//            throw Symbol.AssertionError.typeFailed("Instance: \(code)", asserted: dataType, actual: type!)
//        }
//        guard assertionConfidence > confidence else { return }
//
//        type = dataType
//        confidence = assertionConfidence
    }

//    func assertIsImmutable() throws {
//        try variable.assertIsImmutable()
//    }
//
//    func assertIsMutable() throws {
//        try variable.assertIsMutable()
//    }
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
                "isZilElement": self.isZilElement
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
        lhs.isZilElement == rhs.isZilElement
    }
}
