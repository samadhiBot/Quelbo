//
//  ConditionMDLTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 1/13/23.
//

import CustomDump
import XCTest
@testable import quelbo

final class ConditionMDLTests: QuelboTests {
    let factory = Factories.ConditionMDL.self

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("COND", type: .mdl))
    }

    func testConditionMDL() throws {
        process("""
            <SETG ZORK-NUMBER 1>

            <COND (<N==? ,ZORK-NUMBER 3>
                   <GLOBAL SWIMYUKS
                       <LTABLE 0 "You can't swim in the dungeon.">>)>
        """)

        XCTAssertNoDifference(
            Game.globals.find("swimyuks"),
            Statement(
                id: "swimyuks",
                code: """
                var swimyuks = Table(
                    "You can't swim in the dungeon.",
                    flags: .length
                )
                """,
                type: .table.root,
                category: .globals,
                isCommittable: true
            )
        )
    }

    func testConditionMDLWhenFalse() throws {
        process("""
            <SETG ZORK-NUMBER 3>

            <COND (<N==? ,ZORK-NUMBER 3>
                   <GLOBAL SWIMYUKS
                       <LTABLE 0 "You can't swim in the dungeon.">>)>
        """)

        XCTAssertNil(Game.globals.find("swimyuks"))
    }
}
