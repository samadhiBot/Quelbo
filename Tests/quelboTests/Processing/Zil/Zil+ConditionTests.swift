//
//  Zil+ConditionTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/12/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class ZilConditionTests: XCTestCase {
    func testProcessCondition() throws {
        let zil = try Zil("COND")?.process([
            .list([
                .form([
                    .atom("INFESTED?"),
                    .form([
                        .atom("GETB"),
                        .atom(".T"),
                        .decimal(0)
                    ])
                ]),
                .form([
                    .atom("SET"),
                    .atom("NG"),
                    .decimal(1)
                ]),
                .form([
                    .atom("RETURN")
                ])
            ])
        ])

        XCTAssertNoDifference(zil, """
            if isInfested(getb(t, 0)) {
                set(&ng, to: 1)
                break
            }
            """
        )
    }
}
