//
//  QuelboTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/6/22.
//

import XCTest
@testable import quelbo

class QuelboTests: XCTestCase {
    override func setUp() {
        Game.shared.gameSymbols = []
    }

    func AssertSameFactory(
        _ factory1: SymbolFactory.Type?,
        _ factory2: SymbolFactory.Type?,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard let factory1 = factory1 else {
            return XCTFail("The first factory was not found.", file: file, line: line)
        }
        guard let factory2 = factory2 else {
            return XCTFail("The second factory was not found.", file: file, line: line)
        }
        XCTAssertEqual(
            String(describing: factory1.self),
            String(describing: factory2.self),
            file: file,
            line: line
        )
    }
}

// MARK: - Test helpers

extension QuelboTests {
    var fooTable: Symbol {
        Symbol(
            id: "foo",
            code: """
                    let foo: [TableElement] = [
                        .room(forest1),
                        .room(forest2),
                        .room(forest3),
                    ]
                    """,
            type: .array(.tableElement),
            category: .globals,
            children: [
                Symbol(id: "forest1", code: ".room(forest1)", type: .tableElement, category: .rooms),
                Symbol(id: "forest2", code: ".room(forest2)", type: .tableElement, category: .rooms),
                Symbol(id: "forest3", code: ".room(forest3)", type: .tableElement, category: .rooms),
            ]
        )
    }
}
