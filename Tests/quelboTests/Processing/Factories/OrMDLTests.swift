//
//  OrMDLTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 1/7/23.
//

import CustomDump
import XCTest
@testable import quelbo

final class OrMDLTests: QuelboTests {
    let factory = Factories.OrMDL.self

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("OR", type: .mdl))
    }

    func testOrTrue() throws {
        let symbol = process("""
            <OR T <GLOBAL SHOULD-NOT-SEE 42>>
        """, type: .mdl)

        XCTAssertNoDifference(symbol, .emptyStatement)
    }

    func testOrFalse() throws {
        let symbol = process("""
            <OR <> <GLOBAL SHOULD-SEE 42>>
        """, type: .mdl)

        XCTAssertNoDifference(symbol, .statement(
            id: "shouldSee",
            code: """
                /// The `shouldSee` (SHOULD-SEE) 􀎠Int global.
                var shouldSee = 42
                """,
            type: .int,
            category: .globals,
            isCommittable: true,
            isMutable: true
        ))
    }

    func testSecondElementAfterFalseFirstElement() throws {
        process(
            """
            <OR <GASSIGNED? ZELDA>
                <SETG WBREAKS <STRING !\" !,WBREAKS>>>
            """,
            mode: .evaluate
        )

        XCTAssertNoDifference(
            Game.globals.find("wbreaks"),
            Statement(
                id: "wbreaks",
                code: """
                    /// The `wbreaks` (WBREAKS) 􀎠String global.
                    var wbreaks = [", wbreaks].joined()
                    """,
                type: .string,
                category: .globals,
                isCommittable: true,
                isMutable: true
            )
        )
    }

    func testSecondElementAfterTrueFirstElement() throws {
        evaluate("""
            <OR <GASSIGNED? ZILCH>
                <SETG WBREAKS <STRING !\" !,WBREAKS>>>
        """)

        XCTAssertNil(Game.globals.find("wbreaks"))
    }
}
