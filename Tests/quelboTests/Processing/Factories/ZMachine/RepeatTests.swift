//
//  RepeatTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/9/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class RepeatTests: QuelboTests {
    let factory = Factories.Repeat.self

    override func setUp() {
        super.setUp()

        try! Game.commit([

        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("REPEAT"))
    }

//    func testRepeat() throws {
//        let symbol = try factory.init([
//
//        ]).process()
//
//        XCTAssertNoDifference(symbol, Symbol(
//            "",
//            type: .unknown,
//            children: [
//            ]
//        ))
//    }
//
//    func testThrows() throws {
//        XCTAssertThrowsError(
//            try factory.init([
//            ]).process()
//        )
//    }
}
