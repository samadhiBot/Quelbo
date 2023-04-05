//
//  ShakeLoopTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 11/7/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class ShakeLoopTests: QuelboTests {
    override func setUp() {
        super.setUp()

        GlobalObjectsTests().sharedSetUp()
        sharedSetUp()
    }

    func sharedSetUp() {
        process("""
            <SETG ZORK-NUMBER 1>

            <OBJECT PSEUDO-OBJECT
                (IN LOCAL-GLOBALS)
                (DESC "pseudo")
                (ACTION CRETIN-FCN)>

            <ROOM PATH
                  (IN ROOMS)
                  (LDESC
            "This is a path winding through a dimly lit forest. The path heads
            north-south here. One particularly large tree with some low branches
            stands at the edge of the path.")
                  (DESC "Forest Path")
                  (UP TO UP-A-TREE)
                  (NORTH TO GRATING-CLEARING)
                  (EAST TO FOREST-2)
                  (SOUTH TO NORTH-OF-HOUSE)
                  (WEST TO FOREST-1)
                  (ACTION FOREST-ROOM)
                  (FLAGS RLANDBIT ONBIT SACREDBIT)
                  (GLOBAL TREE SONGBIRD WHITE-HOUSE FOREST)>

            <ROOM UP-A-TREE
                  (IN ROOMS)
                  (DESC "Up a Tree")
                  (DOWN TO PATH)
                  (UP "You cannot climb any higher.")
                  (ACTION TREE-ROOM)
                  (FLAGS RLANDBIT ONBIT SACREDBIT)
                  (GLOBAL TREE FOREST SONGBIRD WHITE-HOUSE)>

            <ROUTINE SHAKE-LOOP ("AUX" X)
                 <REPEAT ()
                     <COND (<SET X <FIRST? ,PRSO>>
                        <FSET .X ,TOUCHBIT>
                        <MOVE .X
                              %<COND (<==? ,ZORK-NUMBER 1>
                                  '<COND (<EQUAL? ,HERE ,UP-A-TREE>
                                          ,PATH)
                                         (<NOT <FSET? ,HERE ,RLANDBIT>>
                                          ,PSEUDO-OBJECT)
                                         (T
                                          ,HERE)>)
                                 (<==? ,ZORK-NUMBER 2>
                                  '<COND (<EQUAL? .X ,WATER>
                                          ,PSEUDO-OBJECT)
                                         (<NOT <FSET? ,HERE ,RLANDBIT>>
                                          ,PSEUDO-OBJECT)
                                         (T
                                          ,HERE)>)
                                 (T
                                  '<COND (<EQUAL? ,HERE ,ON-LAKE>
                                      ,IN-LAKE)
                                     (T
                                      ,HERE)>)>>)
                           (T
                        <RETURN>)>>>
        """)
    }

    func testShakeLoop() throws {
        XCTAssertNoDifference(
            Game.routines.find("shakeLoop"),
            Statement(
                id: "shakeLoop",
                code: """
                    /// The `shakeLoop` (SHAKE-LOOP) routine.
                    func shakeLoop() {
                        var x: Object?
                        while true {
                            if _ = x.set(to: Globals.parsedDirectObject?.firstChild) {
                                x.hasBeenTouched.set(true)
                                x.move(to: {
                                    if Globals.here?.equals(Rooms.upATree) {
                                        return Rooms.path
                                    } else if .isNot(Globals.here?.hasFlag(.isDryLand)) {
                                        return Objects.pseudoObject
                                    } else {
                                        return Globals.here
                                    }
                                }())
                            } else {
                                break
                            }
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
