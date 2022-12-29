//
//  TestInitializers.swift
//  Quelbo
//
//  Created by Chris Sessions on 7/25/22.
//

@testable import quelbo

// MARK: - Statement

extension Statement {
    convenience init(
        id: String? = nil,
        code: String? = nil,
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
        returnHandling: Symbol.ReturnHandling = .implicit
    ) {
        self.init(
            id: id,
            code: { _ in code ?? id ?? "" },
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
            returnHandling: returnHandling
        )
    }
}

// MARK: - Symbol

extension Symbol {
    static func statement(
        id: String? = nil,
        code: String,
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
            returnHandling: returnHandling
        ))
    }
}
