//
//  DescriptionFunctionTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/16/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class DescriptionFunctionTests: QuelboTests {
    let factory = Factories.DescriptionFunction.self

    override func setUp() {
        super.setUp()

        process("""
            <CONSTANT M-OBJDESC? 6>

            <ROOM INSIDE-BUILDING
                (FLAGS LIGHTBIT SACREDBIT)>

            <OBJECT BRASS-LANTERN
                (DESCFCN BRASS-LANTERN-DESCFCN)>

            <ROUTINE BRASS-LANTERN-DESCFCN (ARG)
                <COND (<=? .ARG ,M-OBJDESC?> <RTRUE>)
                      (<FSET? ,BRASS-LANTERN ,LIGHTBIT>
                       <TELL "Your lamp is here, gleaming brightly." CR>)
                      (ELSE <TELL "There is a shiny brass lamp nearby." CR>)>>
        """)
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("DESCFCN", type: .property))
    }

    func testObject() throws {
        XCTAssertNoDifference(
            Game.objects.find("brassLantern"),
            Statement(
                id: "brassLantern",
                code: """
                    /// The `brassLantern` (BRASS-LANTERN) object.
                    var brassLantern = Object(
                        id: "brassLantern",
                        descriptionFunction: "brassLanternDescFunc"
                    )
                    """,
                type: .object,
                category: .objects,
                isCommittable: true
            )
        )
    }

    func testDescriptionFunction() throws {
        XCTAssertNoDifference(
            Game.actionRoutines.find("brassLanternDescFunc"),
            Statement(
                id: "brassLanternDescFunc",
                code: """
                    @discardableResult
                    /// The `brassLanternDescFunc` (BRASS-LANTERN-DESCFCN) action routine.
                    func brassLanternDescFunc(arg: Int) -> Bool {
                        if arg.equals(Constants.isMObjdesc) {
                            return true
                        } else if Objects.brassLantern.hasFlag(.isLight) {
                            output("Your lamp is here, gleaming brightly.")
                        } else {
                            output("There is a shiny brass lamp nearby.")
                        }
                    }
                    """,
                type: .booleanTrue,
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
            code: "descriptionFunction",
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
