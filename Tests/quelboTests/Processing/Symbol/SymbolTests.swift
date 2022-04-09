////
////  SymbolTests.swift
////  Quelbo
////
////  Created by Chris Sessions on 3/27/22.
////
//
//import CustomDump
//import Fizmo
//import XCTest
//@testable import quelbo
//
//final class SymbolTests: QuelboTests {
//    func testSimple() throws {
//        let symbol = try Symbol(zil: "CHEST")
//        XCTAssertNoDifference(
//            symbol,
//            Symbol(code: "chest")
//        )
//    }
//
//    func testProperty() throws {
//        let symbol = try Symbol(zil: ",P?FOO-BAR")
//        XCTAssertNoDifference(
//            symbol,
//            Symbol(code: "fooBar")
//        )
//    }
//
//    func testGlobal() throws {
//        let symbol = try Symbol(zil: ",FOO-BAR")
//        XCTAssertNoDifference(
//            symbol,
//            Symbol(code: "fooBar")
//        )
//    }
//
//    func testLocal() throws {
//        let symbol = try Symbol(zil: ".FOO-BAR")
//        XCTAssertNoDifference(
//            symbol,
//            Symbol(code: "fooBar")
//        )
//    }
//
//    func testKnown() throws {
//        let symbol = try Symbol(zil: "STROPN")
//        XCTAssertNoDifference(
//            symbol,
//            Symbol(code: "openText", type: .string)
//        )
//    }
//}
