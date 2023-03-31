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

    override func setUp() {
        super.setUp()

        process("""
            <DEFINE FUNC1 (X) <* .X .X>>
            <DEFINE FUNC2 (X) <* .X .X .X>>

            <CONSTANT DISPATCH-TBL <VECTOR FUNC1 FUNC2>>
        """)
    }

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("APPLY"))
    }

    func testFunc1() throws {
        XCTAssertNoDifference(
            Game.routines.find("func1"),
            Statement(
                id: "func1",
                code: """
                    @discardableResult
                    /// The `func1` (FUNC1) routine.
                    func func1(x: Int) -> Int {
                        return x.multiply(x)
                    }
                    """,
                type: .int,
                category: .routines,
                isCommittable: true,
                returnHandling: .passthrough
            )
        )
    }

    func testDispatchTbl() throws {
        XCTAssertNoDifference(
            Game.findInstance("dispatchTbl"),
            Instance(Statement(
                id: "dispatchTbl",
                code: """
                    /// The `dispatchTbl` (DISPATCH-TBL) 􀎠[Int] constant.
                    let dispatchTbl = [func1, func2]
                    """,
                type: .int.array,
                category: .constants,
                isCommittable: true,
                isMutable: false
            ))
        )
    }

    func testApply() throws {
        XCTAssertNoDifference(
            process("<APPLY ,<NTH ,DISPATCH-TBL 1> 2>"),
            .statement(
                code: "Constants.dispatchTbl.nthElement(1)(2)",
                type: .int.element
            )
        )

        XCTAssertNoDifference(
            process("<APPLY ,<NTH ,DISPATCH-TBL 2> 2>"),
            .statement(
                code: "Constants.dispatchTbl.nthElement(2)(2)",
                type: .int.element
            )
        )
    }
}
