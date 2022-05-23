//
//  SyntaxTests.swift
//  Fizmo
//
//  Created by Chris Sessions on 5/5/22.
//

import CustomDump
import XCTest
import Fizmo

final class SyntaxTests: XCTestCase {
    func testQuitSyntax() {
        _ = Syntax(
            verb: "quit",
            actionRoutineName: "vQuit"
        )
    }

    func testContemplateSyntax() {
        _ = Syntax(
            verb: "contemplate",
            directObject: Syntax.Object(),
            actionRoutineName: "vThinkAbout"
        )
    }

    func testTakeSyntax() {
        _ = Syntax(
            verb: "take",
            directObject: Syntax.Object(
                where: .isTakable,
                search: [.many, .onGround, .inRoom]
            ),
            actionRoutineName: "vTake"
        )
    }

    func test() {
        _ = Syntax(
            verb: "put",
            directObject: Syntax.Object(
                search: [.carried, .held, .many, .take]
            ),
            indirectObject: Syntax.Object(
                preposition: "in",
                where: .isContainer,
                search: [.inRoom, .many, .onGround]
            ),
            actionRoutineName: "vPutIn",
            preActionRoutineName: "prePutIn"
        )
    }
}
