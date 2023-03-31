//
//  Statement.swift
//  Quelbo
//
//  Created by Chris Sessions on 7/9/22.
//

import CustomDump
import Foundation

final class Statement: SymbolType {
    private(set) var activation: String?
    private(set) var category: Category?
    private(set) var codeBlock: (Statement) throws -> String
    private(set) var id: String?
    private(set) var isAgainStatement: Bool
    private(set) var isBindingAndRepeatingStatement: Bool
    private(set) var isCommittable: Bool
    private(set) var isFunctionCall: Bool
    private(set) var isMutable: Bool?
    private(set) var isThrowing: Bool
    private(set) var payload: Payload
    private(set) var repeating: Bool
    private(set) var returnHandling: Symbol.ReturnHandling
    private(set) var type: TypeInfo

    init(
        id: String? = nil,
        code: @escaping (Statement) throws -> String,
        type: TypeInfo,
        payload: Payload? = nil,
        category: Category? = nil,
        activation: String? = nil,
        isAgainStatement: Bool = false,
        isBindingAndRepeatingStatement: Bool = false,
        isCommittable: Bool = false,
        isFunctionCall: Bool = false,
        isMutable: Bool? = nil,
        isRepeating: Bool = false,
        isThrowing: Bool = false,
        returnHandling: Symbol.ReturnHandling = .implicit
    ) {
        self.activation = activation
        self.category = category
        self.codeBlock = code
        self.id = id
        self.isAgainStatement = isAgainStatement
        self.isBindingAndRepeatingStatement = isBindingAndRepeatingStatement
        self.isCommittable = isCommittable
        self.isFunctionCall = isFunctionCall
        self.isMutable = isMutable
        self.isThrowing = isThrowing
        self.payload = payload ?? .empty
        self.repeating = isRepeating
        self.returnHandling = returnHandling
        self.type = type
    }
}

// MARK: - Computed properties

extension Statement {
    var code: String {
        do {
            return try codeBlock(self)
        } catch {
            return """
                #error("Statement:code:\(error)")
                """
        }
    }

    var isRepeating: Bool {
        guard !isCommittable else {
            return false
        }
        return repeating || payload.symbols.contains {
            guard case .statement(let statement) = $0 else { return false }
            return statement.isAgainStatement
        }
    }

    var signature: String {
        guard let id else { return code }
        return ".\(payload.signatureType)(\(id.quoted))"
    }
}

// MARK: - Symbol Statement initializers

extension Symbol {
    static var emptyStatement: Symbol {
        .statement(
            code: { _ in "" },
            type: .unknown
        )
    }

    static func statement(
        id: String? = nil,
        code: @escaping (Statement) throws -> String,
        type: TypeInfo,
        payload: Statement.Payload? = nil,
        category: Category? = nil,
        activation: String? = nil,
        isAgainStatement: Bool = false,
        isBindingAndRepeatingStatement: Bool = false,
        isCommittable: Bool = false,
        isFunctionCall: Bool = false,
        isMutable: Bool? = nil,
        isThrowing: Bool = false,
        isRepeating: Bool = false,
        returnHandling: Symbol.ReturnHandling = .implicit
    ) -> Symbol {
        .statement(Statement(
            id: id,
            code: code,
            type: type,
            payload: payload,
            category: category,
            activation: activation,
            isAgainStatement: isAgainStatement,
            isBindingAndRepeatingStatement: isBindingAndRepeatingStatement,
            isCommittable: isCommittable,
            isFunctionCall: isFunctionCall,
            isMutable: isMutable,
            isRepeating: isRepeating,
            isThrowing: isThrowing,
            returnHandling: returnHandling
        ))
    }

    static func variable(
        id: String,
        type: TypeInfo,
        category: Category? = nil,
        isCommittable: Bool = true,
        isMutable: Bool? = nil,
        returnHandling: Symbol.ReturnHandling = .implicit
    ) -> Symbol {
        .statement(Statement(
            id: id,
            code: { _ in id },
            type: type,
            category: category,
            isCommittable: isCommittable,
            isMutable: isMutable,
            returnHandling: returnHandling
        ))
    }
}

// MARK: - Special assertion handlers

extension Statement {
    func assertHasCategory(_ assertionCategory: Category) throws {
        guard let category else {
            self.category = assertionCategory
            return
        }
        guard assertionCategory != category else {
            return
        }
        switch (category, assertionCategory) {
        case (.constants, .globals):
            self.category = .globals
            return
        case (.rooms, .globals):
            return
        default:
            throw Symbol.AssertionError.hasCategoryAssertionFailed(
                for: "\(id ?? code)",
                asserted: assertionCategory,
                actual: category
            )
        }
    }

    func assertHasMutability(_ assertedMutability: Bool) throws {
        if assertedMutability == isMutable { return }
        guard isMutable == nil || assertedMutability == true else {
            throw Symbol.AssertionError.hasMutabilityAssertionFailed(
                for: id ?? code,
                asserted: assertedMutability,
                actual: isMutable
            )
        }
        self.isMutable = assertedMutability
        if !assertedMutability {
            self.type.assertIsCertain()
        }
    }

    func assertHasReturnHandling(_ assertedHandling: Symbol.ReturnHandling) throws {
        switch (assertedHandling, returnHandling) {
        case (.forced, .implicit):
            self.returnHandling = .forced
        case (.forced, .passthrough):
            self.returnHandling = .forcedPassthrough
            try payload.assertHasReturnHandling(.forced, from: returnHandling)
        case (.forced, .forcedPassthrough):
            try payload.assertHasReturnHandling(.forced, from: returnHandling)
        case (.forced, .suppressedPassthrough):
            try payload.assertHasReturnHandling(.forced, from: returnHandling)
        case (.forced, .forced),
             (.forced, .suppressed),
             (.implicit, .implicit),
             (.suppressed, .suppressedPassthrough):
            break
        default:
            throw Symbol.AssertionError.hasReturnHandlingAssertionFailed(
                for: "Statement: \(id ?? code)",
                asserted: assertedHandling,
                actual: returnHandling
            )
        }
    }

    func assertHasType(_ assertedType: TypeInfo) throws {
        if isMutable == false && type != .unknown {
            _ = try type.clone().reconcile(".statement(\(id ?? code))", with: assertedType)
        } else {
            self.type = try type.reconcile(".statement(\(id ?? code))", with: assertedType)
        }

        if returnHandling.isPassthrough {
            try payload.symbols.returningSymbols.assert(
                .haveType(type)
            )
        }
    }
}

// MARK: - Conformances

extension Statement: CustomDumpReflectable {
    var customDumpMirror: Mirror {
        .init(
            self,
            children: [
                "id": self.id as Any,
                "code": self.code,
                "type": self.type,
                // "payload": self.payload,
                "category": self.category as Any,
                "activation": self.activation as Any,
                "isAgainStatement": self.isAgainStatement,
                "isBindingAndRepeatingStatement": self.isBindingAndRepeatingStatement,
                "isCommittable": self.isCommittable,
                "isMutable": self.isMutable as Any,
                "isRepeating": self.isRepeating,
                "isThrowing": self.isThrowing,
                "returnHandling": self.returnHandling,
            ],
            displayStyle: .struct
        )
    }
}

extension Statement: Equatable {
    static func == (lhs: Statement, rhs: Statement) -> Bool {
        lhs.id == rhs.id &&
        lhs.code == rhs.code &&
        lhs.type == rhs.type &&
        (rhs.payload == .empty ? true : (lhs.payload == rhs.payload)) &&
        lhs.category == rhs.category &&
        lhs.activation == rhs.activation &&
        lhs.isAgainStatement == rhs.isAgainStatement &&
        lhs.isBindingAndRepeatingStatement == rhs.isBindingAndRepeatingStatement &&
        lhs.isCommittable == rhs.isCommittable &&
        lhs.isMutable == rhs.isMutable &&
        lhs.isRepeating == rhs.isRepeating &&
        lhs.isThrowing == rhs.isThrowing &&
        lhs.returnHandling == rhs.returnHandling
    }
}
