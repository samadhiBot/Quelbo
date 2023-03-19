//
//  IsYesTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 1/6/23.
//

import CustomDump
import XCTest
@testable import quelbo

final class IsYesTests: QuelboTests {
    override func setUp() {
        super.setUp()
        sharedSetup()
    }

    func sharedSetup() {
        process("""
            <GLOBAL P-INBUF <ITABLE 120 (BYTE LENGTH) 0> ;<ITABLE BYTE 60>>
            <GLOBAL P-LEXV
                <ITABLE 59 (LEXV) 0 #BYTE 0 #BYTE 0> ;<ITABLE BYTE 120>>

            <ROUTINE YES? ()
                 <PRINTI ">">
                 <READ ,P-INBUF ,P-LEXV>
                 <COND (<EQUAL? <GET ,P-LEXV 1> ,W?YES ,W?Y>
                    <RTRUE>)
                       (T
                    <RFALSE>)>>
        """)
    }

    func testIsYes() throws {
        XCTAssertNoDifference(
            Game.routines.find("isYes"),
            Statement(
                id: "isYes",
                code: """
                    @discardableResult
                    /// The `isYes` (YES?) routine.
                    func isYes() -> Bool {
                        output(">")
                        read(&pInbuf, &pLexv)
                        if try Globals.pLexv.get(at: 1).equals(Word.yes, Word.y) {
                            return true
                        } else {
                            return false
                        }
                    }
                    """,
                type: .booleanTrue,
                category: .routines,
                isCommittable: true,
                returnHandling: .passthrough
            )
        )
    }
}
