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
        isBindWithAgainStatement: Bool = false,
        isMutable: Bool? = nil,
        isRepeating: Bool = false,
        isReturnStatement: Bool = false,
        suppressesReturns: Bool = false
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
            isBindWithAgainStatement: isBindWithAgainStatement,
            isMutable: isMutable,
            isRepeating: isRepeating,
            isReturnStatement: isReturnStatement,
            suppressesReturns: suppressesReturns
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
        isBindWithAgainStatement: Bool = false,
        isMutable: Bool? = nil,
        isRepeating: Bool = false,
        isReturnStatement: Bool = false,
        suppressesReturns: Bool = false
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
            isBindWithAgainStatement: isBindWithAgainStatement,
            isMutable: isMutable,
            isRepeating: isRepeating,
            isReturnStatement: isReturnStatement,
            suppressesReturns: suppressesReturns
        ))
    }
}
