//
//  GlobalTypeTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/19/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class GlobalTypeTests: QuelboTests {
    let factory = Factories.GlobalType.self

    override func setUp() {
        super.setUp()

        try! Game.commit(
        )
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("GDECL"))
    }

    func testGlobalType() throws {
        let symbol = try factory.init([
            .list([
                .atom("BEACH-DIG")
            ]),
            .atom("FIX")
        ]).process()

        let expected = Symbol(
            id: "<GlobalType>",
            children: [
                Symbol(
                    id: "beachDig",
                    code: "var beachDig: Int = 0",
                    type: .int,
                    category: .globals
                )
            ]
        )

        XCTAssertNoDifference(symbol, expected)
        XCTAssertNoDifference(try Game.find("beachDig"), expected.children[0])
    }

    func testMultiGlobalType() throws {
        let symbol = try factory.init([
            .list([
                .atom("MS"),
                .atom("WD"),
                .atom("RS")
            ]),
            .atom("FIX")
        ]).process()

        let expected = Symbol(
            id: "<GlobalType>",
            children: [
                Symbol(
                    id: "ms",
                    code: "var ms: Int = 0",
                    type: .int,
                    category: .globals
                ),
                Symbol(
                    id: "wd",
                    code: "var wd: Int = 0",
                    type: .int,
                    category: .globals
                ),
                Symbol(
                    id: "rs",
                    code: "var rs: Int = 0",
                    type: .int,
                    category: .globals
                ),
            ]
        )

        XCTAssertNoDifference(symbol, expected)
        XCTAssertNoDifference(try Game.find("ms"), expected.children[0])
        XCTAssertNoDifference(try Game.find("wd"), expected.children[1])
        XCTAssertNoDifference(try Game.find("rs"), expected.children[2])
    }

    func testMultiGlobalTypeFormValue() throws {
        let symbol = try factory.init([
            .list([
                .atom("VERBOSE"),
                .atom("SUPER-BRIEF")
            ]),
            .form([
                .atom("OR"),
                .atom("ATOM"),
                .atom("FALSE")
            ])
        ]).process()

        let expected = Symbol(
            id: "<GlobalType>",
            children: [
                Symbol(
                    id: "verbose",
                    code: "var verbose: Bool = false",
                    type: .bool,
                    category: .globals
                ),
                Symbol(
                    id: "superBrief",
                    code: "var superBrief: Bool = false",
                    type: .bool,
                    category: .globals
                ),
            ]
        )

        XCTAssertNoDifference(symbol, expected)
        XCTAssertNoDifference(try Game.find("verbose"), expected.children[0])
        XCTAssertNoDifference(try Game.find("superBrief"), expected.children[1])
    }
}
