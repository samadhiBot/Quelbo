//
//  Variable.swift
//  Quelbo
//
//  Created by Chris Sessions on 7/9/22.
//

import CustomDump
import Foundation

final class Variable: SymbolType, Identifiable {
    let id: String
    private(set) var category: Category?
    private(set) var isMutable: Bool?
    private(set) var type: TypeInfo

    init(
        id: String,
        type: TypeInfo,
        category: Category? = nil,
        isMutable: Bool? = nil
    ) {
        self.category = category
        self.id = id
        self.isMutable = isMutable
        self.type = type
    }

    var code: String {
        id
    }
}

// MARK: - Symbol Variable initializer

extension Symbol {
    static func variable(
        id: String,
        type: TypeInfo,
        category: Category? = nil,
        isMutable: Bool? = nil
    ) -> Symbol {
        .variable(Variable(
            id: id,
            type: type,
            category: category,
            isMutable: isMutable
        ))
    }
}

extension Variable {
    private var memAddress: String {
        String(ObjectIdentifier(self)
            .debugDescription
            .dropFirst(31)
            .dropLast(1))
    }
}

// MARK: - Special assertion handlers

extension Variable {
    func assertHasCategory(_ assertionCategory: Category) throws {
        if let category = category, assertionCategory != category {
            throw Symbol.AssertionError.hasCategoryAssertionFailed(
                for: "\(self)",
                asserted: assertionCategory,
                actual: category
            )
        }
        self.category = assertionCategory
    }

    func assertHasType(_ assertedType: TypeInfo) throws {
        guard let reconciled = type.reconcile(with: assertedType) else {
            throw Symbol.AssertionError.hasTypeAssertionVariableFailed(
                for: id,
                asserted: assertedType,
                actual: type
            )
        }

        self.type = reconciled.withOptional(false)

        if let global = Game.globals.find(id) {
            try global.assertHasType(assertedType)
        }

        /*
         guard
             let dataType = dataType,
             let assertionConfidence = assertionConfidence,
             !dataType.isCompatible(with: type),
             !dataType.isZilElementCompatible(with: type)
         else { return }

         if type == .optional(dataType) || type == .property(dataType) { return }

         if confidence == .certain && assertionConfidence == .certain {
             throw Symbol.AssertionError.hasTypeAssertionFailed(
                 for: "Variable: \(id)",
                 asserted: dataType,
                 actual: type
             )
         }
         guard assertionConfidence > confidence ?? .unknown else { return }

         type = dataType
         confidence = assertionConfidence

         if let global = Game.globals.find(id) {
             try global.assertHasType(dataType, confidence: assertionConfidence)
         }

         */
    }

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

//    func assertIsImmutable() throws {
//        guard mutable != true else {
//            throw Symbol.AssertionError.isImmutableAssertionFailed(
//                for: "Variable: \(id)",
//                asserted: false,
//                actual: true
//            )
//        }
//        mutable = false
//    }
//
//    func assertIsMutable() throws {
//        guard mutable != false else {
//            throw Symbol.AssertionError.isMutableAssertionFailed(
//                for: "Variable: \(id)",
//                asserted: true,
//                actual: false
//            )
//        }
//        mutable = true
//    }
}

// MARK: - Conformances

extension Variable: CustomDumpReflectable {
    var customDumpMirror: Mirror {
        .init(
            self,
            children: [
                "id": self.id,
                "type": self.type as Any,
                "category": self.category as Any,
                "isMutable": self.isMutable as Any,
            ],
            displayStyle: .struct
        )
    }
}

extension Variable: Equatable {
    static func == (lhs: Variable, rhs: Variable) -> Bool {
        lhs.category == rhs.category &&
        lhs.code == rhs.code &&
        lhs.id == rhs.id &&
        lhs.type == rhs.type
    }
}

extension Array where Element == Variable {
    mutating func commit(_ variable: Variable) throws {
        guard let existing = first(where: { $0.id == variable.id }) else {
            append(variable)
            return
        }

        let oldVariable: Symbol = .variable(existing)
        let newVariable: Symbol = .variable(variable)

        try oldVariable.assert(
            .hasSameCategory(as: newVariable)
        )

        try oldVariable.assert(
            .hasType(newVariable.type)
        )
    }
}
