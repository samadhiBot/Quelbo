////
////  Symbol+ParameterTests.swift
////  Quelbo
////
////  Created by Chris Sessions on 3/10/22.
////
//
//import CustomDump
//import Fizmo
//import XCTest
//@testable import quelbo
//
//final class SymbolParameterTests: QuelboTests {
//    func testAtomSTRCLS() throws {
//        let param = Symbol.Parameter(
//            token: .atom("STRCLS"),
//            context: .normal,
//            codeSymbols: []
//        )
//
//        XCTAssertNoDifference(
//            try param.process(),
//            Symbol(
//                code: "closeText: String",
//                name: "closeText",
//                type: .string
//            )
//        )
//    }
//
//    func testAtomOBJ() throws {
//        let param = Symbol.Parameter(
//            token: .atom("OBJ"),
//            context: .normal,
//            codeSymbols: []
//        )
//
//        XCTAssertNoDifference(
//            try param.process(),
//            Symbol(
//                code: "object: Object",
//                name: "object",
//                type: .object
//            )
//        )
//    }
//
//    func testAtomSTROPN() throws {
//        let param = Symbol.Parameter(
//            token: .atom("STROPN"),
//            context: .normal,
//            codeSymbols: []
//        )
//
//        XCTAssertNoDifference(
//            try param.process(),
//            Symbol(
//                code: "openText: String",
//                name: "openText",
//                type: .string
//            )
//        )
//    }
//
//    func testAtomRARG() throws {
//        let param = Symbol.Parameter(
//            token: .atom("RARG"),
//            context: .normal,
//            codeSymbols: []
//        )
//
//        XCTAssertNoDifference(
//            try param.process(),
//            Symbol(
//                code: "rarg: Int",
//                name: "rarg",
//                type: .int
//            )
//        )
//    }
//
//    func testAtomTBL() throws {
//        let param = Symbol.Parameter(
//            token: .atom("TBL"),
//            context: .normal,
//            codeSymbols: []
//        )
//
//        XCTAssertNoDifference(
//            try param.process(),
//            Symbol(
//                code: "table: [TableElement]",
//                name: "table",
//                type: .array(.tableElement)
//            )
//        )
//    }
//
//    func testAtomUnknown() throws {
//        let param = Symbol.Parameter(
//            token: .atom("CHERRY-PIE"),
//            context: .normal,
//            codeSymbols: []
//        )
//
//        XCTAssertNil(try param.process())
//    }
//
//    func testAtomUsedInCodeBlock() throws {
//        let param = Symbol.Parameter(
//            token: .atom("ONE-MILLION"),
//            context: .normal,
//            codeSymbols: [
//                Symbol(
//                    code: "oneMillion - 1",
//                    name: "oneMillion",
//                    type: .int
//                )
//            ]
//        )
//
//        XCTAssertNoDifference(
//            try param.process(),
//            Symbol(
//                code: "oneMillion: Int",
//                name: "oneMillion",
//                type: .int
//            )
//        )
//    }
//
//    func testAtomUnknownWithQuestionMark() throws {
//        let param = Symbol.Parameter(
//            token: .atom("HERE?"),
//            context: .normal,
//            codeSymbols: []
//        )
//
//        XCTAssertNoDifference(
//            try param.process(),
//            Symbol(
//                code: "isHere: Bool",
//                name: "isHere",
//                type: .bool
//            )
//        )
//    }
//
//    func testListWithBoolDefault() throws {
//        let param = Symbol.Parameter(
//            token: .list([
//                .atom("E?"),
//                .bool(false)
//            ]),
//            context: .normal,
//            codeSymbols: []
//        )
//
//        XCTAssertNoDifference(
//            try param.process(),
//            Symbol(
//                code: "isE: Bool = false",
//                name: "isE",
//                type: .bool
//            )
//        )
//    }
//}
