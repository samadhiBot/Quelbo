//
//  Definition.swift
//  Quelbo
//
//  Created by Chris Sessions on 8/2/22.
//

import CustomDump
import Foundation

final class Definition: SymbolType, Identifiable {
    let id: String
    let tokens: [Token]
    private(set) var evaluatedCode: String?
    private(set) var evaluationError: Swift.Error?
    private(set) var isCommittable: Bool
    private(set) var localVariables: [Statement]
    private(set) var returnHandling: Symbol.ReturnHandling
    private(set) var type: TypeInfo

    init(
        id: String,
        tokens: [Token],
        localVariables: [Statement] = [],
        isCommittable: Bool = false
    ) {
        self.id = id
        self.isCommittable = isCommittable
        self.localVariables = localVariables
        self.returnHandling = .implicit
        self.tokens = tokens
        self.type = .unknown
    }

    var category: Category? { .definitions }

    var code: String {
        if let evaluatedCode { return evaluatedCode }

        do {
            let processed = try {
                if let factorySymbol = try factoryCall() {
                    return factorySymbol
                }
                return try Factories.RoutineCall(
                    tokens,
                    with: &localVariables,
                    mode: .process
                ).processOrEvaluate()
            }()

            try processed.payload?.symbols.assert(
                .haveReturnHandling(returnHandling)
            )

            let code = processed.code

            self.evaluatedCode = code
            self.evaluationError = nil
            self.type = try type.reconcile(id, with: processed.type)

            return code

        } catch {
            self.evaluationError = error
            return "/* _evaluationError_ \(id): \(error) */"
        }
    }

    var isMutable: Bool? { false }

    func factoryCall() throws -> Symbol? {
        guard
            case .form(var formTokens) = tokens.first,
            case .atom(let zil) = formTokens.shift(),
            let factory = Game.findFactory(zil)
        else { return nil }

        return try? factory.init(
            formTokens,
            with: &localVariables,
            mode: .process
        ).processOrEvaluate()
    }
}

// MARK: - Symbol Definition initializer

extension Symbol {
    static func definition(
        id: String,
        tokens: [Token],
        localVariables: [Statement] = [],
        isCommittable: Bool = false
    ) -> Symbol {
        .definition(Definition(
            id: id,
            tokens: tokens,
            localVariables: localVariables,
            isCommittable: isCommittable
        ))
    }
}

// MARK: - Special assertion handlers

extension Definition {
    func assertHasType(_ assertedType: TypeInfo) throws {
        self.type = assertedType
    }

    func assertHasReturnHandling(_ assertedHandling: Symbol.ReturnHandling) throws {
        switch (assertedHandling, returnHandling) {
        case (.forced, .suppressed), (.suppressed, .forced):
            throw Symbol.AssertionError.hasReturnHandlingAssertionFailed(
                for: "Definition: \(id)",
                asserted: assertedHandling,
                actual: returnHandling
            )
        default:
            self.returnHandling = assertedHandling
        }
    }
}

// MARK: - Conformances

extension Definition: CustomDumpReflectable {
    var customDumpMirror: Mirror {
        .init(
            self,
            children: [
                "id": self.id as Any,
                "tokens": self.tokens,
                "type": self.type
            ],
            displayStyle: .struct
        )
    }
}

extension Definition: Equatable {
    static func == (lhs: Definition, rhs: Definition) -> Bool {
        lhs.id == rhs.id &&
        lhs.tokens == rhs.tokens &&
        lhs.type == rhs.type
    }
}

// MARK: - Errors

extension Definition {
    enum Error: Swift.Error {
        case failedToFindNameToken([Token])
    }
}
