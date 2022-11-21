//
//  Game+ReservedGlobals.swift
//  Quelbo
//
//  Created by Chris Sessions on 11/19/22.
//

import Foundation

extension Game {
    static var reservedGlobals: [Symbol] {
        [
            .statement(
                id: "actions",
                code: { _ in "actions" },
                type: .table,
                category: .globals,
                isMutable: true
            ),
            .statement(
                id: "here",
                code: { _ in "here" },
                type: .object.optional,
                category: .rooms,
                isMutable: true
            ),
            .statement(
                id: "nullFunc",
                code: { _ in
                    """
                    @discardableResult
                    /// The `nullFunc` (NULL-F) routine.
                    func nullFunc(a1: Any? = nil, a2: Any? = nil) -> Bool {
                        return false
                    }
                    """
                },
                type: .bool,
                category: .routines
            ),
            .statement(
                id: "preactions",
                code: { _ in "preactions" },
                type: .table,
                category: .globals,
                isMutable: true
            ),
            .statement(
                id: "prsa",
                code: { _ in "prsa" },
                type: .int.optional,
                category: .globals,
                isMutable: true
            ),
            .statement(
                id: "prsi",
                code: { _ in "prsi" },
                type: .object,
                category: .globals,
                isMutable: true
            ),
            .statement(
                id: "prso",
                code: { _ in "prso" },
                type: .object,
                category: .globals,
                isMutable: true
            ),
            .statement(
                id: "verbs",
                code: { _ in "verbs" },
                type: .table,
                category: .globals,
                isMutable: true
            ),
        ]
    }
}
