//
//  Definition.swift
//  Quelbo
//
//  Created by Chris Sessions on 8/2/22.
//

import CustomDump
import Foundation

final class Definition: SymbolType, Identifiable {
    let id: String?
    let tokens: [Token]
    private(set) var confidence: DataType.Confidence?
    private(set) var type: DataType?

    init(
        id: String? = nil,
        tokens: [Token]
    ) {
        self.id = id
        self.tokens = tokens
    }

    var category: Category? { .definitions }

    var code: String {
        id ?? "// Definition:\(tokens.map(\.value))"
    }

    var isMutable: Bool? { false }
}

// MARK: - Symbol Definition initializer

extension Symbol {
    static func definition(
        id: String? = nil,
        tokens: [Token]
    ) -> Symbol {
        .definition(Definition(
            id: id,
            tokens: tokens
        ))
    }
}

// MARK: - Special assertion handlers

extension Definition {
    func assertHasType(
        _ dataType: DataType?,
        confidence assertionConfidence: DataType.Confidence?
    ) throws {
        self.type = dataType
        self.confidence = assertionConfidence
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
            ],
            displayStyle: .struct
        )
    }
}

extension Definition: Equatable {
    static func == (lhs: Definition, rhs: Definition) -> Bool {
        lhs.id == rhs.id &&
        lhs.tokens == rhs.tokens
    }
}

// MARK: - Errors

extension Definition {
    enum Error: Swift.Error {
        case useFactoriesDefinitionEval(Definition)
    }
}
