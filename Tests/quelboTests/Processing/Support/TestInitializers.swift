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
        code: String,
        type: TypeInfo,
        parameters: [Instance] = [],
        children: [Symbol] = [],
        category: Category? = nil,
        activation: String? = nil,
        isAgainStatement: Bool = false,
        isAnonymousFunction: Bool = false,
        isBindWithAgainStatement: Bool = false,
        isCommittable: Bool = false,
        isMutable: Bool? = nil,
        isRepeating: Bool = false,
        isReturnStatement: Bool = false,
        returnHandling: Symbol.ReturnHandling = .implicit
    ) {
        self.init(
            id: id,
            code: { _ in code },
            type: type,
            parameters: parameters,
            children: children,
            category: category,
            activation: activation,
            isAgainStatement: isAgainStatement,
            isAnonymousFunction: isAnonymousFunction,
            isBindWithAgainStatement: isBindWithAgainStatement,
            isCommittable: isCommittable,
            isMutable: isMutable,
            isRepeating: isRepeating,
            isReturnStatement: isReturnStatement,
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
        parameters: [Instance] = [],
        children: [Symbol] = [],
        category: Category? = nil,
        activation: String? = nil,
        isAgainStatement: Bool = false,
        isAnonymousFunction: Bool = false,
        isBindWithAgainStatement: Bool = false,
        isCommittable: Bool = false,
        isMutable: Bool? = nil,
        isRepeating: Bool = false,
        isReturnStatement: Bool = false,
        returnHandling: Symbol.ReturnHandling = .implicit
    ) -> Symbol {
        .statement(Statement(
            id: id,
            code: { _ in code },
            type: type,
            parameters: parameters,
            children: children,
            category: category,
            activation: activation,
            isAgainStatement: isAgainStatement,
            isAnonymousFunction: isAnonymousFunction,
            isBindWithAgainStatement: isBindWithAgainStatement,
            isCommittable: isCommittable,
            isMutable: isMutable,
            isRepeating: isRepeating,
            isReturnStatement: isReturnStatement,
            returnHandling: returnHandling
        ))
    }
}
