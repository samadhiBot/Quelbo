//
//  TestInitializers.swift
//  Quelbo
//
//  Created by Chris Sessions on 7/25/22.
//

//import Foundation
@testable import quelbo

// MARK: - Statement

extension Statement {
    convenience init(
        id: String? = nil,
        code: String,
        type: DataType?,
        confidence: DataType.Confidence?,
        parameters: [Instance] = [],
        children: [Symbol] = [],
        category: Category? = nil,
        activation: String? = nil,
        isMutable: Bool? = nil,
        isRepeating: Bool = false,
        quirk: Quirk? = nil,
        returnable: Symbol.Returnable = .implicit
    ) {
        self.init(
            id: id,
            code: { _ in code },
            type: type,
            confidence: confidence,
            parameters: parameters,
            children: children,
            category: category,
            activation: activation,
            isMutable: isMutable,
            isRepeating: isRepeating,
            quirk: quirk,
            returnable: returnable
        )
    }
}

// MARK: - Symbol

extension Symbol {
    static func statement(
        id: String? = nil,
        code: String,
        type: DataType?,
        confidence: DataType.Confidence?,
        parameters: [Instance] = [],
        children: [Symbol] = [],
        category: Category? = nil,
        activation: String? = nil,
        isMutable: Bool? = nil,
        isRepeating: Bool = false,
        quirk: Statement.Quirk? = nil,
        returnable: Symbol.Returnable = .implicit
    ) -> Symbol {
        .statement(Statement(
            id: id,
            code: { _ in code },
            type: type,
            confidence: confidence,
            parameters: parameters,
            children: children,
            category: category,
            activation: activation,
            isMutable: isMutable,
            isRepeating: isRepeating,
            quirk: quirk,
            returnable: returnable
        ))
    }
}
