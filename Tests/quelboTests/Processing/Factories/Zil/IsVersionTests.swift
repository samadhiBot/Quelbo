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
            Symbol("color", type: .bool, category: .routines),
            Symbol("readbuf", type: .array(.zilElement)),
            Symbol("undo", type: .bool, category: .routines),
            Symbol("zipOptions", type: .bool, category: .routines),
        ])
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zilSymbolFactories.find("VERSION?"))
    }

    func testConditions() throws {
        let symbol = try factory.init([
            .list([
                .atom("ZIP"),
                .form([
                    .atom("SET"),
                    .atom("RESP"),
                    .form([
                        .atom("GETB"),
                        .global("READBUF"),
                        .decimal(1)
                    ])
                ])
            ]),
            .list([
                .atom("EZIP"),
                .form([
                    .atom("SET"),
                    .atom("RESP"),
                    .form([
                        .atom("GETB"),
                        .global("READBUF"),
                        .decimal(1)
                    ])
                ])
            ]),
            .list([
                .atom("ELSE"),
                .form([
                    .atom("COND"),
                    .list([
                        .form([
                            .atom("GETB"),
                            .global("READBUF"),
                            .decimal(1)
                        ]),
                        .form([
                            .atom("SET"),
                            .atom("RESP"),
                            .form([
                                .atom("GETB"),
                                .global("READBUF"),
                                .decimal(2)
                            ])
                        ])
                    ]),
                    .list([
                        .atom("ELSE"),
                        .form([
                            .atom("SET"),
                            .atom("RESP"),
                            .decimal(0)
                        ])
                    ])
                ])
            ])
        ]).process()

        XCTAssertNoDifference(symbol.ignoringChildren, Symbol(
            """
               if zMachineVersion == zip {
                   resp.set(to: readbuf[1])
               } else if zMachineVersion == ezip {
                   resp.set(to: readbuf[1])
               } else {
                   if readbuf[1] {
                       resp.set(to: readbuf[2])
                   } else {
                       resp.set(to: 0)
                   }
               }
               """,
            type: .void
        ))
    }
}
