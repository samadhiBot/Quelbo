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

        let applyFunc1 = process("<APPLY ,<NTH ,DISPATCH-TBL 1> 2>") // --> 4
        let applyFunc2 = process("<APPLY ,<NTH ,DISPATCH-TBL 2> 2>") // --> 8
    }
}
