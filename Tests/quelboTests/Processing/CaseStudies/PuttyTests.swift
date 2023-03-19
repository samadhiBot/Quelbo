//
//  PuttyTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 11/21/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class PuttyTests: QuelboTests {
    override func setUp() {
        super.setUp()

        process("""
            <OBJECT PUTTY
                (IN TUBE)
                (SYNONYM MATERIAL GUNK)
                (ADJECTIVE VISCOUS)
                (DESC "viscous material")
                (FLAGS TAKEBIT TOOLBIT)
                (SIZE 6)
                (ACTION PUTTY-FCN)>

            <ROUTINE PUTTY-FCN ()
                 <COND (<OR <AND <VERB? OIL>
                         <EQUAL? ,PRSI ,PUTTY>>
                        <AND <VERB? PUT>
                         <EQUAL? ,PRSO ,PUTTY>>>
                    <TELL "The all-purpose gunk isn't a lubricant." CR>)>>
        """)
    }

    func testPutty() throws {
        XCTAssertNoDifference(
            Game.objects.find("putty"),
            Statement(
                id: "putty",
                code: """
                    /// The `putty` (PUTTY) object.
                    var putty = Object(
                        id: "putty",
                        action: puttyFunc,
                        adjectives: ["viscous"],
                        description: "viscous material",
                        flags: [.isTakable, .isTool],
                        location: tube,
                        size: 6,
                        synonyms: ["material", "gunk"]
                    )
                    """,
                type: .object.optional,
                category: .objects,
                isCommittable: true
            )
        )
    }

    func testPuttyFunc() throws {
        XCTAssertNoDifference(
            Game.routines.find("puttyFunc"),
            Statement(
                id: "puttyFunc",
                code: """
                    /// The `puttyFunc` (PUTTY-FCN) routine.
                    func puttyFunc() {
                        if .or(
                            .and(
                                isParsedVerb(.oil),
                                Globals.parsedIndirectObjects.equals(putty)
                            ),
                            .and(
                                isParsedVerb(.put),
                                Globals.parsedDirectObjects.equals(putty)
                            )
                        ) {
                            output("The all-purpose gunk isn't a lubricant.")
                        }
                    }
                    """,
                type: .void,
                category: .routines,
                isCommittable: true,
                returnHandling: .passthrough
            )
        )
    }
}
