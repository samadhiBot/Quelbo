//
//  RemoveCarefullyTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 10/9/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class RemoveCarefullyTests: QuelboTests {
    override func setUp() {
        super.setUp()

        process("""
            <GLOBAL HERE 0>
            <GLOBAL LIT <>>
            <GLOBAL P-IT-OBJECT <>>
            <GLOBAL PLAYER <>>

            <OBJECT GLOBAL-OBJECTS (FLAGS ONBIT)>

            ;"This is an abridged version of LIT? with extraneous details removed"
            <ROUTINE LIT? (RM "OPTIONAL" (RMBIT T) "AUX" OHERE (LIT <>))
                <SET OHERE ,HERE>
                <SETG HERE .RM>
                <COND (<AND .RMBIT
                        <FSET? .RM ,ONBIT>>
                       <SET LIT T>)
                      (T
                       <COND (<EQUAL? .OHERE .RM>
                          <COND (<IN? ,PLAYER .RM>
                             <TELL "DO-SL">)>)>
                       <SET LIT T>)>
                <SETG HERE .OHERE>
                .LIT>

            <ROUTINE REMOVE-CAREFULLY (OBJ "AUX" OLIT)
                 <COND (<EQUAL? .OBJ ,P-IT-OBJECT>
                    <SETG P-IT-OBJECT <>>)>
                 <SET OLIT ,LIT>
                 <REMOVE .OBJ>
                 <SETG LIT <LIT? ,HERE>>
                 <COND (<AND .OLIT <NOT <EQUAL? .OLIT ,LIT>>>
                    <TELL "You are left in the dark..." CR>)>
                 T>
        """)
    }

    func testGlobals() throws {
        XCTAssertNoDifference(
            Game.findGlobal("pItObject"),
            Instance(Statement(
                id: "pItObject",
                code: "var pItObject: Object?",
                type: .object.optional,
                category: .globals,
                isCommittable: true,
                isMutable: true
            ))
        )
    }

    func testIsLit() throws {
        XCTAssertNoDifference(
            Game.routines.find("isLit"),
            Statement(
                id: "isLit",
                code: """
                    @discardableResult
                    /// The `isLit` (LIT?) routine.
                    func isLit(
                        rm: Object,
                        rmBit: Bool = true
                    ) -> Bool {
                        var ohere: Object? = nil
                        var lit: Bool = false
                        ohere.set(to: here)
                        here.set(to: rm)
                        if .and(
                            rmBit,
                            rm.hasFlag(isOn)
                        ) {
                            lit.set(to: true)
                        } else {
                            if ohere.equals(rm) {
                                if .object(player).isIn(rm) {
                                    output("DO-SL")
                                }
                            }
                            lit.set(to: true)
                        }
                        here.set(to: ohere)
                        return lit
                    }
                    """,
                type: .bool,
                category: .routines,
                isCommittable: true
            )
        )
    }

    func testRemoveCarefully() throws {
        XCTAssertNoDifference(
            Game.routines.find("removeCarefully"),
            Statement(
                id: "removeCarefully",
                code: """
                    @discardableResult
                    /// The `removeCarefully` (REMOVE-CAREFULLY) routine.
                    func removeCarefully(obj: Object) -> Bool {
                        var olit: Bool = false
                        if obj.equals(pItObject) {
                            pItObject.set(to: nil)
                        }
                        olit.set(to: lit)
                        obj.remove()
                        lit.set(to: isLit(rm: here))
                        if .and(
                            olit,
                            .isNot(olit.equals(lit))
                        ) {
                            output("You are left in the dark...")
                        }
                        return true
                    }
                    """,
                type: .booleanTrue,
                payload: .init(
                    parameters: [
                        Instance(
                            Statement(
                                id: "obj",
                                type: .object
                            )
                        ),
                    ]
                ),
                category: .routines,
                isCommittable: true
            )
        )
    }
}
