//
//  NextSiblingTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 6/7/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class NextSiblingTests: QuelboTests {
    let factory = Factories.NextSibling.self

    override func setUp() {
        super.setUp()

        try! Game.commit([
            Symbol(id: "egg", type: .object, category: .objects),
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zMachineSymbolFactories.find("NEXT?"))
    }

    func testFirstItemInClearing() throws {
        let symbol = try factory.init([
            .global("EGG")
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            "egg.nextSibling",
            type: .object
        ))
    }

    func testNonObjectThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .string("egg")
            ])
        )
    }
}
