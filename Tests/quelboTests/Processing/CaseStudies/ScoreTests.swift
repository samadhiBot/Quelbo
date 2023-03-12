//
//  ScoreTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 1/18/23.
//

import CustomDump
import XCTest
@testable import quelbo

final class ScoreTests: QuelboTests {
    func testScoreSyntaxDefinedFirst() throws {
        process("""
            <SYNTAX SCORE = V-SCORE>

            <GLOBAL MOVES 0>
            <GLOBAL SCORE 0>

            \(Self.vScoreZil)
        """)

        XCTAssertNoDifference(
            Game.globals.find("score"),
            Statement(
                id: "score",
                code: "var score: Int = 0",
                type: .int,
                category: .globals,
                isCommittable: true
            )
        )

        XCTAssertNoDifference(
            Game.syntax.find("score"),
            Statement(
                id: "score",
                code: """
                    Syntax(
                        verb: "score",
                        action: "vScore"
                    )
                    """,
                type: .void,
                category: .syntax,
                isCommittable: true
            )
        )
    }

    func testScoreGlobalDefinedFirst() throws {
        process("""
            <GLOBAL MOVES 0>
            <GLOBAL SCORE 0>

            <SYNTAX SCORE = V-SCORE>

            \(Self.vScoreZil)
        """)

        XCTAssertNoDifference(
            Game.globals.find("score"),
            Statement(
                id: "score",
                code: "var score: Int = 0",
                type: .int,
                category: .globals,
                isCommittable: true
            )
        )

        XCTAssertNoDifference(
            Game.syntax.find("score"),
            Statement(
                id: "score",
                code: """
                    Syntax(
                        verb: "score",
                        action: "vScore"
                    )
                    """,
                type: .void,
                category: .syntax,
                isCommittable: true
            )
        )
    }

    func testVScore() {
        process("""
            <SYNTAX SCORE = V-SCORE>

            <GLOBAL MOVES 0>
            <GLOBAL SCORE 0>

            \(Self.vScoreZil)
        """)

        XCTAssertNoDifference(
            Game.routines.find("vScore"),
            Statement(
                id: "vScore",
                code: #"""
                    @discardableResult
                    /// The `vScore` (V-SCORE) routine.
                    func vScore(isAsk: Bool = true) -> Int {
                        output("Your score is ")
                        output(score)
                        output(" (total of 350 points), in ")
                        output(moves)
                        if moves.isOne {
                            output(" move.")
                        } else {
                            output(" moves.")
                        }
                        output("\n")
                        output("This gives you the rank of ")
                        if score.equals(350) {
                            output("Master Adventurer")
                        } else if score.isGreaterThan(330) {
                            output("Wizard")
                        } else if score.isGreaterThan(300) {
                            output("Master")
                        } else if score.isGreaterThan(200) {
                            output("Adventurer")
                        } else if score.isGreaterThan(100) {
                            output("Junior Adventurer")
                        } else if score.isGreaterThan(50) {
                            output("Novice Adventurer")
                        } else if score.isGreaterThan(25) {
                            output("Amateur Adventurer")
                        } else {
                            output("Beginner")
                        }
                        output(".")
                        return score
                    }
                    """#,
                type: .int,
                category: .routines,
                isCommittable: true,
                returnHandling: .passthrough
            )
        )
    }
}

extension ScoreTests {
    static let vScoreZil = """
        <ROUTINE V-SCORE ("OPTIONAL" (ASK? T))
             #DECL ((ASK?) <OR ATOM FALSE>)
             <TELL "Your score is ">
             <TELL N ,SCORE>
             <TELL " (total of 350 points), in ">
             <TELL N ,MOVES>
             <COND (<1? ,MOVES> <TELL " move.">) (ELSE <TELL " moves.">)>
             <CRLF>
             <TELL "This gives you the rank of ">
             <COND (<EQUAL? ,SCORE 350> <TELL "Master Adventurer">)
                   (<G? ,SCORE 330> <TELL "Wizard">)
                   (<G? ,SCORE 300> <TELL "Master">)
                   (<G? ,SCORE 200> <TELL "Adventurer">)
                   (<G? ,SCORE 100> <TELL "Junior Adventurer">)
                   (<G? ,SCORE 50> <TELL "Novice Adventurer">)
                   (<G? ,SCORE 25> <TELL "Amateur Adventurer">)
                   (T <TELL "Beginner">)>
             <TELL "." CR>
             ,SCORE>
    """
}
