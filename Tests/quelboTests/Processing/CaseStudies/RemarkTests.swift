//
//  RemarkTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/22/23.
//

import CustomDump
import XCTest
@testable import quelbo

final class RemarkTests: QuelboTests {
    override func setUp() {
        process("""
            <CONSTANT F-WEP 0>    ;"means print weapon name"
            <CONSTANT F-DEF 1>    ;"means print defender name (villain, e.g.)"

            <ROUTINE REMARK (REMARK D W "AUX" (LEN <GET .REMARK 0>) (CNT 0) STR)
                 <REPEAT ()
                         <COND (<G? <SET CNT <+ .CNT 1>> .LEN> <RETURN>)>
                     <SET STR <GET .REMARK .CNT>>
                     <COND (<EQUAL? .STR ,F-WEP> <PRINTD .W>)
                           (<EQUAL? .STR ,F-DEF> <PRINTD .D>)
                           (T <PRINT .STR>)>>
                 <CRLF>>
        """)
    }

    func testDecimalZero() throws {
        let fWep = Statement(
            id: "fWep",
            code: "let fWep = 0",
            type: .integerZero,
            category: .constants,
            isCommittable: true,
            isMutable: false
        )

        XCTAssertNoDifference(Game.constants.find("fWep"), fWep)
        XCTAssertNoDifference(Game.findInstance("fWep"), Instance(fWep))
    }

    func testRemark() throws {
        XCTAssertNoDifference(
            Game.routines.find("remark"),
            Statement(
                id: "remark",
                code: #"""
                    /// The `remark` (REMARK) routine.
                    func remark(remark: Table, d: Object, w: Object) {
                        var len = try remark.get(at: 0)
                        var cnt = 0
                        var str = ""
                        while true {
                            if cnt.set(to: .add(cnt, 1)).isGreaterThan(len) {
                                break
                            }
                            str.set(to: try remark.get(at: cnt))
                            if str.equals(Constants.fWep) {
                                output(w.description)
                            } else if str.equals(Constants.fDef) {
                                output(d.description)
                            } else {
                                output(str)
                            }
                        }
                        output("\n")
                    }
                    """#,
                type: .void,
                category: .routines,
                isCommittable: true,
                returnHandling: .passthrough
            )
        )
    }
}
