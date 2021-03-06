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
            Symbol(id: "color", type: .bool, category: .routines),
            Symbol(id: "readbuf", type: .table),
            Symbol(id: "undo", type: .bool, category: .routines),
            Symbol(id: "zipOptions", type: .bool, category: .routines),
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

        XCTAssertNoDifference(symbol, Symbol(
            """
               if zMachineVersion == zip {
                   resp.set(to: try readbuf.get(at: 1))
               } else if zMachineVersion == ezip {
                   resp.set(to: try readbuf.get(at: 1))
               } else {
                   if try readbuf.get(at: 1) {
                       resp.set(to: try readbuf.get(at: 2))
                   } else {
                       resp.set(to: 0)
                   }
               }
               """,
            type: .void
        ))
    }
}
