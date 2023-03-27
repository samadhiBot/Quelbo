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

        GlobalObjectsTests().sharedSetUp()
        ZmemqTests().sharedSetUp()
        SearchListTests().sharedSetUp()
        DoSlTests().sharedSetUp()
        IsLitTests().sharedSetUp()
        sharedSetUp()
    }

    func sharedSetUp() {
        process("""
            <GLOBAL HERE 0>
            <GLOBAL LIT <>>
            <GLOBAL P-IT-OBJECT <>>
            <GLOBAL PLAYER <>>

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
            Game.findInstance("pItObject"),
            Instance(Statement(
                id: "pItObject",
                code: """
                    /// The `pItObject` (P-IT-OBJECT) 􀎠Object? global.
                    var pItObject: Object?
                    """,
                type: .object.optional,
                category: .globals,
                isCommittable: true,
                isMutable: true
            ))
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
                        var olit = false
                        if obj.equals(Globals.pItObject) {
                            Globals.pItObject.set(to: nil)
                        }
                        olit.set(to: Globals.lit)
                        obj.remove()
                        Globals.lit.set(to: try isLit(rm: Globals.here))
                        if .and(olit, .isNot(olit.equals(Globals.lit))) {
                            output("You are left in the dark...")
                        }
                        return true
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
