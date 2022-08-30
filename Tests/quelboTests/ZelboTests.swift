//
//  QuelboTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/6/22.
//

import XCTest
@testable import quelbo

class QuelboTests: XCTestCase {
    var localVariables: [Variable]!

    override func setUp() {
        super.setUp()

        Game.shared.symbols = []
        Game.shared.globalVariables = []
        Game.shared.zMachineVersion = .z3
        self.localVariables = []
    }

    func findLocalVariable(_ id: String) -> Variable? {
        localVariables.first { $0.id == id }
    }

    func AssertSameFactory(
        _ factory1: FactoryType.Type?,
        _ factory2: FactoryType.Type?,
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

class TestFactory: Factory {
    override func process() throws -> Symbol {
        let symbols = try symbolize(tokens)
        return symbols[0]
    }
}

//extension QuelboTests {
//    var fooTable: Symbol {
//        Symbol(
//            id: "foo",
//            code: """
//                let foo: Table = Table(
//                    .room(forest1),
//                    .room(forest2),
//                    .room(forest3)
//                )
//                """,
//            type: .table,
//            category: .globals,
//            children: [
//                .variable(id: "forest1", code: ".room(forest1)", type: .zilElement, category: .rooms),
//                .variable(id: "forest2", code: ".room(forest2)", type: .zilElement, category: .rooms),
//                .variable(id: "forest3", code: ".room(forest3)", type: .zilElement, category: .rooms),
//            ]
//        )
//    }
//}
