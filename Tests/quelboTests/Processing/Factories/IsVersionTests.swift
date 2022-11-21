//
//  IsVersionTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/30/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class IsVersionTests: QuelboTests {
    let factory = Factories.IsVersion.self

    override func setUp() {
        super.setUp()

        try! Game.commit([
            .variable(id: "color", type: .bool, category: .routines),
            .variable(id: "readbuf", type: .table),
            .variable(id: "undo", type: .bool, category: .routines),
            .variable(id: "zipOptions", type: .bool, category: .routines),
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("VERSION?"))
    }

    func testConditions() throws {
        let symbol = process("""
            <VERSION?
                (ZIP <SET RESP <GETB ,READBUF 1>>)
                (EZIP <SET RESP <GETB ,READBUF 1>>)
                (ELSE
                 <COND (<GETB ,READBUF 1>
                        <SET RESP <GETB ,READBUF 2>>)
                       (ELSE
                        <SET RESP 0>)>)>
        """)

        XCTAssertNoDifference(symbol, .statement(
            code: """
               if zMachineVersion == .zip {
                   resp.set(to: try readbuf.get(at: 1))
               } else if zMachineVersion == .ezip {
                   resp.set(to: try readbuf.get(at: 1))
               } else {
                   if _ = try readbuf.get(at: 1) {
                       resp.set(to: try readbuf.get(at: 2))
                   } else {
                       resp.set(to: 0)
                   }
               }
               """,
            type: .void,
            returnHandling: .suppress
        ))
    }
}
