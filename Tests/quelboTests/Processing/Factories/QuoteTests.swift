//
//  QuoteTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 8/4/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class QuoteTests: QuelboTests {
    let factory = Factories.Quote.self

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("QUOTE"))
    }

    func testQuoteAtom() throws {
        localVariables.append(.init(id: "obj", type: .object))

        let symbol = try factory.init([
            .atom("OBJ")
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .instance(.init(
            id: "obj",
            type: .object
        )))
    }

    func testQuoteForm() throws {
        let symbol = try factory.init([
            .form([
                .atom("RANDOM"),
                .decimal(100)
            ])
        ], with: &localVariables).process()

        XCTAssertNoDifference(symbol, .statement(
            code: ".random(100)",
            type: .int
        ))
    }

    func testQuoteGlobal() throws {
        process("""
            <OBJECT TORCH (FLAGS FLAMEBIT ONBIT)>

            <DEFMAC FLAMING? ('OBJ)
                <FORM AND <FORM FSET? .OBJ ',FLAMEBIT>
                          <FORM FSET? .OBJ ',ONBIT>>>
        """)

        XCTAssertNoDifference(
            Game.findRoutine("isFlaming"),
            Statement(
                id: "isFlaming",
                code: """
                    @discardableResult
                    /// The `isFlaming` (FLAMING?) macro.
                    func isFlaming(obj: Object) -> Bool {
                        return .and(
                            obj.hasFlag(.isFlammable),
                            obj.hasFlag(.isOn)
                        )
                    }
                    """,
                type: .bool,
                category: .routines,
                isCommittable: true,
                returnHandling: .passthrough
            )
        )
    }
}
