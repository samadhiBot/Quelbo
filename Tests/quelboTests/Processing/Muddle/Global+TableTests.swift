//
//  Global+Table.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/8/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class GlobalTable: XCTestCase {
    func testFormPureLTable() throws {
        var global = Global([
            .atom("FOO"),
            .form([
                .atom("LTABLE"),
                .list([
                    .atom("PURE")
                ]),
                .atom("FOREST-1"),
                .atom("FOREST-2"),
                .atom("FOREST-3"),
                .atom("PATH"),
                .atom("CLEARING"),
                .atom("FOREST-1"),
            ])
        ], isMutable: true)
        XCTAssertNoDifference(
            try global.process().code,
            """
            let foo = ZIL.Table(
                .atom("FOREST-1"),
                .atom("FOREST-2"),
                .atom("FOREST-3"),
                .atom("PATH"),
                .atom("CLEARING"),
                .atom("FOREST-1"),
            )
            """
        )
    }

    func testNestedLTables() throws {
        var global = Global([
            .atom("VILLAINS"),
            .form([
                .atom("LTABLE"),
                .form([
                    .atom("TABLE"),
                    .atom("TROLL"),
                    .atom("SWORD"),
                    .decimal(1),
                    .decimal(0),
                    .atom("TROLL-MELEE")
                ]),
                .form([
                    .atom("TABLE"),
                    .atom("THIEF"),
                    .atom("KNIFE"),
                    .decimal(1),
                    .decimal(0),
                    .atom("THIEF-MELEE")
                ]),
                .form([
                    .atom("TABLE"),
                    .atom("CYCLOPS"),
                    .bool(false),
                    .decimal(0),
                    .decimal(0),
                    .atom("CYCLOPS-MELEE")
                ])
            ])
        ], isMutable: true)
        XCTAssertNoDifference(
            try global.process().code,
            """
            var villains = ZIL.Table(
                .table(
                    .atom("TROLL"),
                    .atom("SWORD"),
                    .decimal(1),
                    .decimal(0),
                    .atom("TROLL-MELEE"),
                ),
                .table(
                    .atom("THIEF"),
                    .atom("KNIFE"),
                    .decimal(1),
                    .decimal(0),
                    .atom("THIEF-MELEE"),
                ),
                .table(
                    .atom("CYCLOPS"),
                    .bool(false),
                    .decimal(0),
                    .decimal(0),
                    .atom("CYCLOPS-MELEE"),
                ),
            )
            """
        )
    }

    func testFormTableWithCommented() throws {
        var global = Global([
            .atom("DEF1-RES"),
            .form([
                .atom("TABLE"),
                .atom("DEF1"),
                .decimal(0),
                .commented(
                    .form([
                        .atom("REST"),
                        .atom(",DEF1"),
                        .decimal(2)
                    ])
                ),
                .decimal(0),
                .commented(
                    .form([
                        .atom("REST"),
                        .atom(",DEF1"),
                        .decimal(4)
                    ])
                )
            ])
        ], isMutable: true)
        XCTAssertNoDifference(
            try global.process().code,
            """
            var def1Res = ZIL.Table(
                .atom("DEF1"),
                .decimal(0),
                .decimal(0),
            )
            """
        )
    }
}
