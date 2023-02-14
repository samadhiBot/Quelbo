//
//  ProgramBlockMDLTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 2/8/23.
//

import CustomDump
import Fizmo
import XCTest
@testable import quelbo

final class ProgramBlockMDLTests: QuelboTests {
    let factory = Factories.ProgramBlockMDL.self

    //    override func setUp() {
    //        super.setUp()
    //
    //        try! Game.commit([
    //            .variable(id: "isFunnyReturn", type: .bool, category: .globals),
    //        ])
    //    }

    func testFindFactory() {
        AssertSameFactory(factory, Game.findFactory("PROG", type: .mdl))
    }

}
