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
    private(set) var localVariables: [Statement]
    private(set) var type: TypeInfo

    init(
        id: String,
        tokens: [Token],
        localVariables: [Statement] = []
    ) {
        self.id = id
        self.localVariables = localVariables
        self.tokens = tokens
        self.type = .unknown
    }

    var category: Category? { .definitions }

    var code: String {
        if let evaluatedCode { return evaluatedCode }

        do {
            let routineCall = try Factories.RoutineCall(
                tokens,
                with: &localVariables,
                mode: .evaluate
            ).processOrEvaluate()

            let code = routineCall.code

            self.evaluatedCode = code
            self.evaluationError = nil
            self.type = routineCall.type

            return code

        } catch {
            self.evaluationError = error
            return "/* \(id) evaluation error: \(error) */"
        }
    }

    var isMutable: Bool? { false }

    var status: Status {
        if evaluatedCode == nil { return .undetermined }
        return type.status
    }
}

// MARK: - Symbol Definition initializer

extension Symbol {
    static func definition(
        id: String,
        tokens: [Token],
        localVariables: [Statement] = []
    ) -> Symbol {
        .definition(Definition(
            id: id,
            tokens: tokens,
            localVariables: localVariables
        ))
    }
}

// MARK: - Special assertion handlers

extension Definition {
    func assertHasType(_ assertedType: TypeInfo) throws {
        self.type = assertedType
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
        case useFactoriesDefinitionEval(Definition)
    }
}
