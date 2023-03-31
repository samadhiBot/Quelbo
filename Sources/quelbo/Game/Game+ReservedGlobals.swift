//
//  Game+ReservedGlobals.swift
//  Quelbo
//
//  Created by Chris Sessions on 11/19/22.
//

import Foundation

extension Game {
    /// An array of reserved globals that are implicitly present in ZIL.
    static var reservedGlobals: [Symbol] {
        [
            .statement(
                id: "actions",
                code: { _ in
                    """
                    /// The `actions` (ACTIONS) 􀎠􀁮Table global.
                    var actions = Table()
                    """
                },
                type: .table,
                category: .globals,
                isMutable: true
            ),

            .statement(
                id: "lowDirection",
                code: { _ in
                    """
                    /// The `lowDirection` (LOW-DIRECTION) 􀎠Int global.
                    let lowDirection = 0
                    """
                },
                type: .int,
                category: .constants,
                isMutable: false
            ),

            .statement(
                id: "nullFunc",
                code: { _ in
                    """
                    @discardableResult
                    /// The `nullFunc` (NULL-F) routine.
                    func nullFunc(a1: Any? = nil, a2: Any? = nil) -> Bool {
                        false
                    }
                    """
                },
                type: .bool,
                category: .routines
            ),

            .statement(
                id: "parsedVerb",
                code: { _ in
                    """
                    /// The `parsedVerb` (PARSED-VERB) 􀎠Verb? global.
                    var parsedVerb: Verb?
                    """
                },
                type: .verb.optional,
                category: .globals,
                isMutable: true
            ),

            .statement(
                id: "parsedIndirectObject",
                code: { _ in
                    """
                    /// The `parsedIndirectObject` (PARSED-INDIRECT-OBJECT) 􀎠Object? global.
                    var parsedIndirectObject: Object?
                    """
                },
                type: .object.optional,
                category: .globals,
                isMutable: true
            ),

            .statement(
                id: "parsedDirectObject",
                code: { _ in
                    """
                    /// The `parsedDirectObject` (PARSED-DIRECT-OBJECT) 􀎠Object? global.
                    var parsedDirectObject: Object?
                    """
                },
                type: .object.optional,
                category: .globals,
                isMutable: true
            ),

            .statement(
                id: "preactions",
                code: { _ in
                    """
                    /// The `preactions` (PREACTIONS) 􀎠􀁮Table global.
                    var preactions = Table()
                    """
                },
                type: .table,
                category: .globals,
                isMutable: true
            ),

            .statement(
                id: "prepositions",
                code: { _ in
                    """
                    /// The `prepositions` (PREPOSITIONS) 􀎠􀁮Table global.
                    var prepositions = Table()
                    """
                },
                type: .table,
                category: .globals,
                isMutable: true
            ),

            .statement(
                id: "verbs",
                code: { _ in
                    """
                    /// The `verbs` (VERBS) 􀎠􀁮Table global.
                    var verbs = Table()
                    """
                },
                type: .table,
                category: .globals,
                isMutable: true
            ),

            .statement(
                id: "zilch",
                code: { _ in
                    """
                    /// The `zilch` (ZILCH) 􀎠Bool global.
                    let zilch = true
                    """
                },
                type: .bool,
                category: .constants,
                isMutable: false
            ),
        ]
    }
}
