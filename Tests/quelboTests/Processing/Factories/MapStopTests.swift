////
////  MapStopTests.swift
////  Quelbo
////
////  Created by Chris Sessions on 5/7/22.
////
//
//import CustomDump
//import XCTest
//@testable import quelbo
//
//final class MapStopTests: QuelboTests {
//    let factory = Factories.MapStop.self
//
//    func testFindFactory() throws {
//        AssertSameFactory(factory, Game.findFactory("MAPSTOP"))
//    }
//
//    func testMapStop() throws {
//        localVariables.append(
//            Statement(id: "atms", type: .string.array)
//        )
//
//        let symbol = try factory.init([
//            .local("ATMS")
//        ], with: &localVariables).process()
//
//        XCTAssertNoDifference(symbol, .statement(
//            code: "mapStop(atms)",
//            type: .string.array,
//            returnHandling: .forced
//        ))
//    }
//}
