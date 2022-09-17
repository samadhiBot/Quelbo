//
//  SegmentTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 8/9/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class SegmentTests: QuelboTests {
    let factory = Factories.Segment.self

    func testSegment() throws {
        localVariables.append(Variable(id: "foo", type: .string))

        let symbol = try factory.init([
            .atom("FOO")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .variable(id: "foo", type: .string))
    }
}
