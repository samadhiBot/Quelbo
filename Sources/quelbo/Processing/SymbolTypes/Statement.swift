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
    private(set) var children: [Symbol]
    private(set) var codeBlock: (Statement) throws -> String
    private(set) var confidence: DataType.Confidence?
    private(set) var id: String?
    private(set) var isMutable: Bool?
    private(set) var returnable: Symbol.Returnable
    private(set) var parameters: [Instance]
    private(set) var repeating: Bool
    private(set) var type: DataType?
    private(set) var quirk: Quirk?

    init(
        id: String? = nil,
        code: @escaping (Statement) throws -> String,
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
        self.activation = activation
        self.category = category
        self.children = children
        self.codeBlock = code
        self.confidence = confidence
        self.id = id
        self.isMutable = isMutable
        self.parameters = parameters
        self.repeating = isRepeating
        self.returnable = returnable
        self.type = type
        self.quirk = quirk
    }

    var code: String {
        do {
            return try codeBlock(self)
        } catch {
            return "Statement:code:\(error)"
        }
    }

    var isRepeating: Bool {
        repeating || children.contains {
            guard case .statement(let statement) = $0 else { return false }

            return statement.quirk == .againStatement
        }
    }
}

// MARK: - Symbol Statement initializer

extension Statement {
    enum Quirk: Equatable {
        case againStatement
        case bindWithAgain
        case returnStatement
        case zilElement
    }
}

// MARK: - Symbol Statement initializer

extension Symbol {
    static func statement(
        id: String? = nil,
        code: @escaping (Statement) throws -> String,
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
            code: code,
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

// MARK: - Special assertion handlers

extension Statement {
    func assertHasType(
        _ dataType: DataType?,
        confidence assertionConfidence: DataType.Confidence?
    ) throws {
        guard
            let dataType = dataType,
            let assertionConfidence = assertionConfidence,
            type != dataType
        else { return }

        for symbol in children {
            guard
                case .statement(let statement) = symbol,
                statement.quirk == .returnStatement
            else { continue}

            try statement.assertHasType(dataType, confidence: assertionConfidence)
        }

        if dataType == .zilElement, quirk == nil {
            quirk = .zilElement
            return
        }

        if type == .zilElement || type == .optional(dataType) { return }

        if let type = type,
           confidence == .certain &&
           assertionConfidence == .certain &&
           ![.void, .zilElement].contains(dataType) &&
           dataType != .optional(type)
        {
            throw Symbol.AssertionError.hasTypeAssertionFailed(
                for: "Statement: \(code)",
                asserted: dataType,
                actual: type
            )
        }

        guard assertionConfidence > confidence ?? .unknown else { return }

        type = confidence == .booleanFalse ? dataType.asOptional : dataType
        confidence = assertionConfidence
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
                "type": self.type as Any,
                "confidence": self.confidence as Any,
                "parameters": self.parameters,
                "category": self.category as Any,
                "activation": self.activation as Any,
                "isMutable": self.isMutable as Any,
                "isRepeating": self.isRepeating,
                "quirk": self.quirk as Any,
                "returnable": self.returnable
            ],
            displayStyle: .struct
        )
    }
}

extension Statement: Equatable {
    static func == (lhs: Statement, rhs: Statement) -> Bool {
        lhs.id == rhs.id
        && lhs.code == rhs.code
        && lhs.type == rhs.type
        && lhs.confidence == rhs.confidence
        && lhs.parameters == rhs.parameters
        && lhs.category == rhs.category
        && lhs.activation == rhs.activation
        && lhs.isMutable == rhs.isMutable
        && lhs.isRepeating == rhs.isRepeating
        && lhs.quirk == rhs.quirk
        && lhs.returnable == rhs.returnable
    }
}
