//
//  Factory+symbolizeTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/31/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class FactorySymbolizeTests: QuelboTests {
    let testFactory = TestFactory.self

    let boardedWindow = Instance(.init(
        id: "boardedWindow",
        code: """
            /// The `boardedWindow` (BOARDED-WINDOW) object.
            var boardedWindow = Object(
                action: boardedWindowFunc,
                adjectives: ["boarded"],
                description: "boarded window",
                flags: [omitDescription],
                location: localGlobals,
                synonyms: ["window"]
            )
            """,
        type: .object,
        category: .objects,
        isCommittable: true
    ))

    override func setUp() {
        super.setUp()

        process("""
            <OBJECT BOARDED-WINDOW
                (IN LOCAL-GLOBALS)
                    (SYNONYM WINDOW)
                (ADJECTIVE BOARDED)
                (DESC "boarded window")
                (FLAGS NDESCBIT)
                (ACTION BOARDED-WINDOW-FCN)>
        """)
    }

    func testSymbolizeAtomReferringToGlobal() throws {
        let symbol = try TestFactory([
            .atom("BOARDED-WINDOW")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .instance(boardedWindow))
    }

    func testSymbolizeAtomTForBooleanTrue() throws {
        let symbol = try TestFactory([
            .atom("T")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .true)
    }

    func testSymbolizeAtomTForVariableT() throws {
        let tStatement = Statement(id: "t", type: .string)
        localVariables.append(tStatement)

        let symbol = try TestFactory([
            .atom("T")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .instance(tStatement))
    }

    func testSymbolizeBoolTrue() throws {
        let symbol = try TestFactory([
            .bool(true)
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .literal(true))
    }

    func testSymbolizeBoolFalse() throws {
        let symbol = try TestFactory([
            .bool(false)
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .literal(false))
    }

    func testSymbolizeCharacter() throws {
        let symbol = try TestFactory([
            .character("Z")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .literal("Z"))
    }

    func testSymbolizeCommented() throws {
        let symbol = try TestFactory([
            .commented(.bool(true))
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "// true",
            type: .comment
        ))
    }

    func testSymbolizeDecimal() throws {
        let symbol = try TestFactory([
            .decimal(42)
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .literal(42))
    }

    func testSymbolizeEval() throws {
        let symbol = try TestFactory([
            .eval(
                .form([
                    .atom("+"),
                    .decimal(2),
                    .decimal(3),
                ])
            )
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .literal(5))
    }

    func testSymbolizeGlobal() throws {
        let symbol = try TestFactory([
            .global(.atom("BOARDED-WINDOW"))
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .instance(boardedWindow))
    }

    func testSymbolizeList() throws {
        let symbol = try TestFactory([
            .list([
                .atom("FLOATING?"),
                .bool(false),
            ])
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "[isFloating, false]",
            type: .booleanFalse.array
        ))
    }

    func testSymbolizeLocal() throws {
        localVariables.append(
            .init(
                id: "fooBar",
                type: .object,
                isCommittable: true
            )
        )

        let symbol = try TestFactory([
            .local("FOO-BAR")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .variable(id: "fooBar", type: .object))
    }

    func testSymbolizeUnknownLocalThrows() throws {
        XCTAssertThrowsError(
            _ = try TestFactory([
                .local("FOO-BAR")
            ], with: &localVariables).process()
        )
    }

    func testSymbolizeProperty() throws {
        let symbol = try TestFactory([
            .property("STRENGTH"),
            .decimal(10),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            id: "strength",
            code: "strength: 10",
            type: .int
        ))
    }

    func testSymbolizePropertyDirection() throws {
        try Game.commit(.statement(
            id: "north",
            code: "",
            type: .direction,
            category: .properties,
            isCommittable: true
        ))

        let symbol = try TestFactory([
            .property("NORTH")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "north",
            type: .direction,
            category: .properties
        ))
    }

    func testSymbolizeQuote() throws {
        let symbol = try TestFactory([
            .quote(.form([
                .atom("RANDOM"),
                .decimal(100)
            ]))
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .definition(
            id: "%quote",
            tokens: [
                .form([
                    .atom("RANDOM"),
                    .decimal(100),
                ])
            ]
        ))
    }

    func testSymbolizeSegment() throws {
        let symbol = try TestFactory([
            .segment(
                .form([
                    .atom("+"),
                    .decimal(2),
                    .decimal(3),
                ])
            )
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: ".add(2, 3)",
            type: .int
        ))
    }

    func testSymbolizeString() throws {
        let symbol = try TestFactory([
            .string("Plants can talk")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .literal("Plants can talk"))
    }

    func testSymbolizeTypeByte() throws {
        let symbol = try TestFactory([
            .type("BYTE"),
            .decimal(42),
        ], with: &localVariables).process()

        let int8Literal = Int8(42)

        XCTAssertNoDifference(symbol, .literal(int8Literal))
    }
}
