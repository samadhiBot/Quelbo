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
    private(set) var isReturnStatement: Bool
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
        isReturnStatement: Bool = false,
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
        self.isReturnStatement = isReturnStatement
        self.payload = payload ?? .empty
        self.repeating = isRepeating
        self.returnHandling = returnHandling
        self.type = type
    }

    var code: String {
        do {
            return try codeBlock(self)
                .replacingOccurrences(of: "try try", with: "try")
        } catch {
            return "Statement:code:\(error)"
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

    func assertShouldReturn() {
        switch returnHandling {
        case .force:
            break
        case .implicit:
            returnHandling = .force
        case .suppress:
            payload.symbols.forEach {
                if case .statement(let statement) = $0 {
                    statement.assertShouldReturn()
                }
            }
        }
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
        isRepeating: Bool = false,
        isReturnStatement: Bool = false,
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
            isReturnStatement: isReturnStatement,
            returnHandling: returnHandling
        ))
    }

    static func variable(
        id: String,
        type: TypeInfo,
        category: Category? = nil,
        isCommittable: Bool = true,
        isMutable: Bool? = nil
    ) -> Symbol {
        .statement(Statement(
            id: id,
            code: { _ in id },
            type: type,
            category: category,
            isCommittable: isCommittable,
            isMutable: isMutable
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
        case (.rooms, .globals):
            return
        default:
            throw Symbol.AssertionError.hasCategoryAssertionFailed(
                for: "\(Self.self)",
                asserted: assertionCategory,
                actual: category
            )
        }
    }

    func assertHasMutability(_ mutability: Bool) throws {
        switch isMutable {
        case mutability: return
        case .none: isMutable = mutability
        default:
            throw Symbol.AssertionError.hasMutabilityAssertionFailed(
                for: "\(Self.self)",
                asserted: mutability,
                actual: isMutable
            )
        }
    }

    func assertHasType(_ assertedType: TypeInfo) throws {
        self.type = try type.reconcile(".statement(\(id ?? code))", with: assertedType)

        try payload.symbols.returningExplicitly.assert(
            .haveType(type)
        )
    }
}

// MARK: - Conformances

extension Array where Element == Statement {
    func routineSelfReference(for id: String) -> Statement? {
        first { statement in
            statement.id == id && statement.isFunctionCall
        }
    }
}

extension Statement: CustomDumpReflectable {
    var customDumpMirror: Mirror {
        .init(
            self,
            children: [
                "id": self.id as Any,
                "code": self.code,
                "type": self.type,
//                "payload": self.payload as Any,
                "category": self.category as Any,
                "activation": self.activation as Any,
                "isAgainStatement": self.isAgainStatement,
                "isBindingAndRepeatingStatement": self.isBindingAndRepeatingStatement,
                "isCommittable": self.isCommittable,
                "isMutable": self.isMutable as Any,
                "isRepeating": self.isRepeating,
                "isReturnStatement": self.isReturnStatement,
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
        lhs.category == rhs.category &&
        lhs.activation == rhs.activation &&
        lhs.isAgainStatement == rhs.isAgainStatement &&
        lhs.isBindingAndRepeatingStatement == rhs.isBindingAndRepeatingStatement &&
        lhs.isCommittable == rhs.isCommittable &&
        lhs.isMutable == rhs.isMutable &&
        lhs.isRepeating == rhs.isRepeating &&
        lhs.isReturnStatement == rhs.isReturnStatement &&
        lhs.returnHandling == rhs.returnHandling
    }
}
