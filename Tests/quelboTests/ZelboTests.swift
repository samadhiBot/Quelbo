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

    func findLocalVariable(_ id: String) -> Variable? {
        localVariables.first { $0.id == id }
    }

    func parse(_ source: String) throws -> [Token] {
        let parsed = try Game.shared.parser.parse(source)
        if parsed.count == 1, case .form(let tokens) = parsed[0] {
            return tokens
        }

        return parsed
    }
}
