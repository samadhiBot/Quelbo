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
    let boardedWindow = Variable(
        id: "boardedWindow",
        type: .object,
        confidence: .certain,
        category: .globals
    )

    override func setUp() {
        super.setUp()

        try! Game.commit([
            .variable(boardedWindow)
        ])
    }

    func testSymbolizeAtomReferringToGlobal() throws {
        let symbol = try testFactory.init([
            .atom("BOARDED-WINDOW")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .instance(boardedWindow))
    }

    func testSymbolizeAtomTForBooleanTrue() throws {
        let symbol = try testFactory.init([
            .atom("T")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .literal(true))
    }

    func testSymbolizeAtomTForVariableT() throws {
        localVariables.append(Variable(id: "t"))

        let symbol = try testFactory.init([
            .atom("T")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .variable(id: "t"))
    }

    func testSymbolizeBoolTrue() throws {
        let symbol = try testFactory.init([
            .bool(true)
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .literal(true))
    }

    func testSymbolizeBoolFalse() throws {
        let symbol = try testFactory.init([
            .bool(false)
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .literal(false))
    }

    func testSymbolizeCharacter() throws {
        let symbol = try testFactory.init([
            .character("Z")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .literal("Z"))
    }

    func testSymbolizeCommented() throws {
        let symbol = try testFactory.init([
            .commented(.bool(true))
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "// true",
            type: .comment,
            confidence: .certain,
            returnable: .void
        ))
    }

    func testSymbolizeDecimal() throws {
        let symbol = try testFactory.init([
            .decimal(42)
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .literal(42))
    }

//    func testSymbolizeEval() throws {
//        let symbol = try testFactory.init([
//            .eval(
//                .form([
//                    .atom("+"),
//                    .decimal(2),
//                    .decimal(3),
//                ])
//            )
//        ], with: &localVariables).process()
//
//        XCTAssertNoDifference(symbol, Symbol(
//            code: ".add(2, 3)",
//            type: .int
//        ))
//    }

    func testSymbolizeGlobal() throws {
        let symbol = try testFactory.init([
            .global("BOARDED-WINDOW")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .variable(boardedWindow))
    }

    func testSymbolizeList() throws {
        let symbol = try testFactory.init([
            .list([
                .atom("FLOATING?"),
                .bool(false),
            ])
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "[isFloating, false]",
            type: .array(.zilElement),
            confidence: .booleanFalse
        ))
    }

    func testSymbolizeLocal() throws {
        localVariables.append(
            .init(id: "fooBar", type: .object)
        )

        let symbol = try testFactory.init([
            .local("FOO-BAR")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .variable(id: "fooBar", type: .object))
    }

    func testSymbolizeUnknownLocalThrows() throws {
        XCTAssertThrowsError(
            _ = try testFactory.init([
                .local("FOO-BAR")
            ], with: &localVariables).process()
        )
    }

    func testSymbolizeProperty() throws {
        let symbol = try testFactory.init([
            .property("STRENGTH"),
            .decimal(10),
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            id: "strength",
            code: "strength: 10",
            type: .int,
            confidence: .certain
        ))
    }

    func testSymbolizePropertyDirection() throws {
        try Game.commit(.statement(
            id: "north",
            code: "",
            type: .direction,
            confidence: .certain,
            category: .properties
        ))

        let symbol = try testFactory.init([
            .property("NORTH")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "north",
            type: .direction,
            confidence: .certain,
            category: .properties
        ))
    }

    func testSymbolizeQuote() throws {
        let symbol = try testFactory.init([
            .quote(.form([
                .atom("RANDOM"),
                .decimal(100)
            ]))
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: ".random(100)",
            type: .int,
            confidence: .certain
        ))
    }

//    func testSymbolizeSegment() throws {
//        let symbol = try testFactory.init([
//            .segment(
//                .form([
//                    .atom("+"),
//                    .decimal(2),
//                    .decimal(3),
//                ])
//            )
//        ], with: &localVariables).process()
//
//        XCTAssertNoDifference(symbol, Symbol(
//            code: ".add(2, 3)",
//            type: .int
//        ))
//    }

    func testSymbolizeString() throws {
        let symbol = try testFactory.init([
            .string("Plants can talk")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .literal("Plants can talk"))
    }

    func testSymbolizeTypeByte() throws {
        let symbol = try testFactory.init([
            .type("BYTE"),
            .decimal(42),
        ], with: &localVariables).process()

        let int8Literal = Int8(42)

        XCTAssertNoDifference(symbol, .literal(int8Literal))
    }
}
