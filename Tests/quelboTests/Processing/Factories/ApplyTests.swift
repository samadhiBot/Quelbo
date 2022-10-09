//
//  ApplyTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 10/1/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class ApplyTests: QuelboTests {
    let factory = Factories.Apply.self

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("APPLY"))
    }

    func testApply() throws {
        process("""
            <DEFINE FUNC1 (X) <* .X .X>>
            <DEFINE FUNC2 (X) <* .X .X .X>>

            <CONSTANT DISPATCH-TBL <VECTOR FUNC1 FUNC2>>
        """)

        XCTAssertNoDifference(
            Game.findGlobal("dispatchTbl"),
            Variable(
                id: "dispatchTbl",
                type: .array(.int),
                category: .constants,
                isMutable: false
            )
        )

        XCTAssertNoDifference(
            Game.constants.find("dispatchTbl"),
            Statement(
                id: "dispatchTbl",
                code: """
                    let dispatchTbl: [Int] = [func1, func2]
                    """,
                type: .array(.int),
                category: .constants,
                isCommittable: true
            )
        )

        XCTAssertNoDifference(
            process("<APPLY ,<NTH ,DISPATCH-TBL 1> 2>"),
            .statement(
                code: "dispatchTbl.nthElement(1)(2)",
                type: .int
            )
        )

        XCTAssertNoDifference(
            process("<APPLY ,<NTH ,DISPATCH-TBL 2> 2>"),
            .statement(
                code: "dispatchTbl.nthElement(2)(2)",
                type: .int
            )
        )
    }
}
