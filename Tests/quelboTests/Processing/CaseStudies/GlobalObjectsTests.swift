//
//  GlobalObjectsTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 10/9/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class GlobalObjectsTests: QuelboTests {
    override func setUp() {
        super.setUp()
        sharedSetup()
    }

    func sharedSetup() {
        process("""
            <OBJECT GLOBAL-OBJECTS
                (FLAGS RMUNGBIT INVISIBLE TOUCHBIT SURFACEBIT TRYTAKEBIT
                       OPENBIT SEARCHBIT TRANSBIT ONBIT RLANDBIT FIGHTBIT
                       STAGGERED WEARBIT)>

            ;"Objects below are intended to provide definitions for other tests."

            <OBJECT WEIRDO (FLAGS ACTORBIT)>

            <OBJECT INFLATED-BOAT (FLAGS TAKEBIT BURNBIT VEHBIT)>

            <ROOM MAZE-1 (FLAGS RLANDBIT MAZEBIT)>
        """)
    }

    func testGlobalObjects() throws {
        XCTAssertNoDifference(
            Game.objects.find("globalObjects"),
            Statement(
                id: "globalObjects",
                code: """
                    /// The `globalObjects` (GLOBAL-OBJECTS) object.
                    var globalObjects = Object(
                        flags: [
                            hasBeenTouched,
                            isDestroyed,
                            isDryLand,
                            isFightable,
                            isInvisible,
                            isOn,
                            isOpen,
                            isSearchable,
                            isStaggered,
                            isSurface,
                            isTransparent,
                            isWearable,
                            noImplicitTake,
                        ]
                    )
                    """,
                type: .object,
                category: .objects,
                isCommittable: true
            )
        )
    }
}
