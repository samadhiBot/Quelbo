////
////  SymbolFactory+evaluateTests.swift
////  Quelbo
////
////  Created by Chris Sessions on 5/22/22.
////
//
//import CustomDump
//import XCTest
//@testable import quelbo
//
//final class SymbolFactoryEvaluateTests: QuelboTests {
//    let testFactory = try! TestFactory.init([])
//
//    override func setUp() {
//        super.setUp()
//
//        try! Game.commit(
//            Symbol("boardedWindow", type: .object, category: .globals)
//        )
//    }
//
//    func testEvaluateAtom() throws {
////        let symbol = try testFactory.init([
////            .atom("BOARDED-WINDOW")
////        ], with: types).process()
////
////        XCTAssertNoDifference(symbol, Symbol("boardedWindow", type: .object, category: .globals))
//    }
//
//    func testEvaluateBoolTrue() throws {
//        let token = try testFactory.evaluate(
//            .bool(true)
//        )
//
//        XCTAssertNoDifference(token, .bool(true))
//    }
//
//    func testEvaluateBoolFalse() throws {
//        let token = try testFactory.evaluate(
//            .bool(false)
//        )
//
//        XCTAssertNoDifference(token, .bool(false))
//    }
//
//    func testEvaluateCharacter() throws {
//        let token = try testFactory.evaluate(
//            .character("Z")
//        )
//
//        XCTAssertNoDifference(token, .character("Z"))
//    }
//
//    func testEvaluateCommented() throws {
////        let symbol = try testFactory.init([
////            .commented(.bool(true))
////        ], with: types).process()
////
////        XCTAssertNoDifference(symbol, Symbol("/* true */", type: .comment))
//    }
//
//    func testEvaluateDecimal() throws {
//        let token = try testFactory.evaluate(
//            .decimal(42)
//        )
//
//        XCTAssertNoDifference(token, .decimal(42))
//    }
//
//    func testEvaluateEval() throws {
////        let symbol = try testFactory.init([
////            .eval(
////                .form([
////                    .atom("+"),
////                    .decimal(2),
////                    .decimal(3),
////                ])
////            )
////        ], with: types).process()
////
////        XCTAssertNoDifference(symbol, Symbol(
////            ".add(2, 3)",
////            type: .int,
////            children: [
////                Symbol("2", type: .int, meta: [.isLiteral]),
////                Symbol("3", type: .int, meta: [.isLiteral]),
////            ]
////        ))
//    }
//
//    func testEvaluateForm() throws {
//
//    }
//
//    func testEvaluateGlobal() throws {
////        let symbol = try testFactory.init([
////            .global("BOARDED-WINDOW")
////        ], with: types).process()
////
////        XCTAssertNoDifference(symbol, Symbol(
////            "boardedWindow",
////            type: .object,
////            category: .globals
////        ))
//    }
//
//    func testEvaluateList() throws {
////        let symbol = try testFactory.init([
////            .list([
////                .atom("FLOATING?"),
////                .bool(false),
////            ])
////        ], with: types).process()
////
////        XCTAssertNoDifference(symbol, Symbol(
////            id: "<List>",
////            type: .list,
////            children: [
////                Symbol("isFloating", type: .bool),
////                .falseSymbol
////            ]
////        ))
//    }
//
//    func testEvaluateLocal() throws {
////        let symbol = try testFactory.init([
////            .local("FOO-BAR")
////        ], with: types).process()
////
////        XCTAssertNoDifference(symbol, Symbol("fooBar"))
//    }
//
//    func testEvaluateProperty() throws {
////        let symbol = try testFactory.init([
////            .property("STRENGTH")
////        ], with: types).process()
////
////        XCTAssertNoDifference(symbol, Symbol(
////            "strength",
////            type: .int,
////            category: .properties
////        ))
//    }
//
//    func testEvaluateQuote() throws {
////        let symbol = try testFactory.init([
////            .quote(
////                .form(
////                    [
////                        .atom("INC"),
////                        .atom("X"),
////                        .decimal(2)
////                    ]
////                )
////            )
////        ], with: types).process()
////
////        XCTAssertNoDifference(symbol, Symbol(
////            id: "<Quote>",
////            meta: [
////                .eval(
////                    .form(
////                        [
////                            .atom("INC"),
////                            .atom("X"),
////                            .decimal(2)
////                        ]
////                    )
////                )
////            ]
////        ))
//    }
//
//    func testEvaluateSegment() throws {
////        let symbol = try testFactory.init([
////            .segment(
////                .form([
////                    .atom("+"),
////                    .decimal(2),
////                    .decimal(3),
////                ])
////            )
////        ], with: types).process()
////
////        XCTAssertNoDifference(symbol, Symbol("5", type: .int, meta: [.isLiteral]))
////    }
////
////
////    func testEvaluateString() throws {
////        let symbol = try testFactory.init([
////            .string("Plants can talk")
////        ], with: types).process()
////
////        XCTAssertNoDifference(symbol, Symbol(
////            #""Plants can talk""#,
////            type: .string,
////            meta: [.isLiteral]
////        ))
//    }
//}
