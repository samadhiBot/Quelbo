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
    private(set) var type: TypeInfo

    init(
        id: String,
        tokens: [Token]
    ) {
        self.id = id
        self.tokens = tokens
        self.type = .unknown
    }

    var category: Category? { .definitions }

    var code: String {
        id
    }

    var isMutable: Bool? { false }
}

// MARK: - Symbol Definition initializer

extension Symbol {
    static func definition(
        id: String,
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
