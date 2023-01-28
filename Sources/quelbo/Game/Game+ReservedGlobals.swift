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
                code: { _ in "var actions: Table = Table()" },
                type: .table,
                category: .globals,
                isMutable: true
            ),
            .statement(
                id: "lowDirection",
                code: { _ in "let lowDirection: Int = 0" },
                type: .int
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
                id: "parsedVerb",
                code: { _ in "var parsedVerb: Verb?" },
                type: .verb.optional,
                category: .globals,
                isMutable: true
            ),
            .statement(
                id: "parsedIndirectObject",
                code: { _ in "var parsedIndirectObject: Object?" },
                type: .object.optional,
                category: .globals,
                isMutable: true
            ),
            .statement(
                id: "parsedDirectObject",
                code: { _ in "var parsedDirectObject: Object?" },
                type: .object.optional,
                category: .globals,
                isMutable: true
            ),
            .statement(
                id: "partsOfSpeech",
                code: { _ in
                    """
                    enum PartsOfSpeech: Int {
                        case objectFirst = 0
                        case verbFirst = 1
                        case adjectiveFirst = 2
                        case directionFirst = 3
                        case buzzWord = 4
                        case preposition = 8
                        case direction = 16
                        case adjective = 32
                        case verb = 64
                        case object = 128
                    }
                    """
                },
                type: .void,
                category: .globals,
                isMutable: true
            ),
            .statement(
                id: "preactions",
                code: { _ in "var preactions: Table = Table()" },
                type: .table,
                category: .globals,
                isMutable: true
            ),
            .statement(
                id: "prepositions",
                code: { _ in "var prepositions: Table = Table()" },
                type: .table,
                category: .globals,
                isMutable: true
            ),
            .statement(
                id: "verbs",
                code: { _ in "var verbs: Table = Table()" },
                type: .table,
                category: .globals,
                isMutable: true
            ),
        ]
    }
}
