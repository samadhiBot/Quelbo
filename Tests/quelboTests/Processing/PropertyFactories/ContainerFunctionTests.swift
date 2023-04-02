//
//  ContainerFunctionTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 2/13/23.
//

import CustomDump
import XCTest
@testable import quelbo

final class ContainerFunctionTests: QuelboTests {
    let factory = Factories.ContainerFunction.self

    override func setUp() {
        super.setUp()

        process("""
            <OBJECT BOTTLE
                (CONTFCN BOTTLE-CONTFCN)>

            <ROUTINE BOTTLE-CONTFCN ()
                <COND (<VERB? TAKE> <TELL "You're holding that already (in " T ,BOTTLE ")." CR>)>>
        """)
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("CONTFCN", type: .property))
    }

    func testObject() throws {
        XCTAssertNoDifference(
            Game.objects.find("bottle"),
            Statement(
                id: "bottle",
                code: """
                    /// The `bottle` (BOTTLE) object.
                    var bottle = Object(
                        id: "bottle",
                        containerFunction: "bottleContFunc"
                    )
                    """,
                type: .object,
                category: .objects,
                isCommittable: true
            )
        )
    }

    func testContainerFunction() throws {
        XCTAssertNoDifference(
            Game.actionRoutines.find("bottleContFunc"),
            Statement(
                id: "bottleContFunc",
                code: """
                    /// The `bottleContFunc` (BOTTLE-CONTFCN) action routine.
                    func bottleContFunc() {
                        if isParsedVerb(.take) {
                            output("You're holding that already (in ")
                            output(true)
                            output(Objects.bottle)
                            output(").")
                        }
                    }
                    """,
                type: .void,
                category: .routines,
                isActionRoutine: true,
                isCommittable: true,
                returnHandling: .passthrough
            )
        )
    }

    func testEmptyReturnsPropertyName() throws {
        let symbol = try factory.init([], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: "containerFunction",
            type: .routine
        ))
    }

    func testMultipleThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .atom("WHITE-HOUSE"),
                .atom("RED-HOUSE"),
            ], with: &localVariables).process()
        )
    }
}
