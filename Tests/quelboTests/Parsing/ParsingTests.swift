//
//  ParsingTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 9/27/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class ParsingTests: QuelboTests {
    func testAtom() throws {
        let parsed = try zilParser.parse("""
            WHITE-HOUSE
        """).first

        XCTAssertNoDifference(parsed, .atom("WHITE-HOUSE"))
    }

    func testAtomIsFirst() throws {
        let parsed = try zilParser.parse("""
            1ST?
        """).first

        XCTAssertNoDifference(parsed, .atom("1ST?"))
    }

    func testAtomIsOne() throws {
        let parsed = try zilParser.parse("""
            1?
        """).first

        XCTAssertNoDifference(parsed, .atom("1?"))
    }

    func testAtomIsZero() throws {
        let parsed = try zilParser.parse("""
            0?
        """).first

        XCTAssertNoDifference(parsed, .atom("0?"))
    }

    func testBoolFalse() throws {
        let parsed = try zilParser.parse("""
            <>
        """).first

        XCTAssertNoDifference(parsed, .bool(false))
    }

    func testCharacter() throws {
        let parsed = try zilParser.parse(#"""
            !\z
        """#).first

        XCTAssertNoDifference(parsed, .character("z"))
    }

    func testCommentedAtom() throws {
        let parsed = try zilParser.parse("""
            ;COFFIN-CURE
        """).first

        XCTAssertNoDifference(parsed, .commented(.atom("COFFIN-CURE")))
    }

    func testCommentedForm() throws {
        let parsed = try zilParser.parse("""
            ;<ITABLE BYTE 120>
        """).first

        XCTAssertNoDifference(
            parsed,
            .commented(
                .form([
                    .atom("ITABLE"),
                    .atom("BYTE"),
                    .decimal(120),
                ])
            )
        )
    }

    func testCommentedGlobal() throws {
        let parsed = try zilParser.parse("""
            ;,ACT?ASK
        """).first

        XCTAssertNoDifference(parsed, .commented(.global(.atom("ACT?ASK"))))
    }

    func testCommentedList() throws {
        let parsed = try zilParser.parse("""
            ;(<EQUAL? .WRD ,W?$BUZZ> T)
        """).first

        XCTAssertNoDifference(
            parsed,
            .commented(
                .list([
                    .form([
                        .atom("EQUAL?"),
                        .local("WRD"),
                        .global(.atom("W?$BUZZ"))
                    ]),
                    .atom("T")
                ])
            )
        )
    }

    func testCommentedMultiple() throws {
        let parsed = try zilParser.parse("""
            <VERB? TELL ;WHERE ;WHAT ;WHO>
        """).first

        XCTAssertNoDifference(
            parsed,
            .form([
               .atom("VERB?"),
               .atom("TELL"),
               .commented(.atom("WHERE")),
               .commented(.atom("WHAT")),
               .commented(.atom("WHO")),
            ])
        )
    }

    func testCommentedString() throws {
        let parsed = try zilParser.parse("""
            ;"-TOSSED"
        """).first

        XCTAssertNoDifference(parsed, .commented(.string("-TOSSED")))
    }

    func testEval() throws {
        let parsed = try zilParser.parse("""
            %<COND (<==? ,ZORK-NUMBER 3>)>
        """).first

        XCTAssertNoDifference(
            parsed,
            .eval(
                .form([
                    .atom("COND"),
                    .list([
                        .form([
                            .atom("==?"),
                            .global(.atom("ZORK-NUMBER")),
                            .decimal(3)
                        ])
                    ])
                ])
            )
        )
    }

    func testForm() throws {
        let parsed = try zilParser.parse("""
            <TELL "You will be lost without me!" CR>
        """).first

        XCTAssertNoDifference(
            parsed,
            .form([
                .atom("TELL"),
                .string("You will be lost without me!"),
                .atom("CR"),
            ])
        )
    }

    func testGlobal() throws {
        let parsed = try zilParser.parse("""
            ,ON-LAKE
        """).first

        XCTAssertNoDifference(parsed, .global(.atom("ON-LAKE")))
    }

    func testInt() throws {
        let parsed = try zilParser.parse("""
            42
        """).first

        XCTAssertNoDifference(parsed, .decimal(42))
    }

    func testList() throws {
        let parsed = try zilParser.parse("""
            (FLAGS RLANDBIT ONBIT SACREDBIT)
        """).first

        XCTAssertNoDifference(
            parsed,
            .list([
                .atom("FLAGS"),
                .atom("RLANDBIT"),
                .atom("ONBIT"),
                .atom("SACREDBIT")
            ])
        )
    }

    func testLocal() throws {
        let parsed = try zilParser.parse("""
            .RARG
        """).first

        XCTAssertNoDifference(parsed, .local("RARG"))
    }

    func testProperty() throws {
        let parsed = try zilParser.parse("""
            ,P?STRENGTH
        """).first

        XCTAssertNoDifference(parsed, .property("STRENGTH"))
    }

    func testQuotedForm() throws {
        let parsed = try zilParser.parse("""
            '<NULL-F>
        """).first

        XCTAssertNoDifference(
            parsed,
            .quote(
                .form([
                    .atom("NULL-F")
                ])
            )
        )
    }

    func testQuotedList() throws {
        let parsed = try zilParser.parse("""
            '(,DEAD
                <COND (.VB
                    <TELL "Your hand passes through its object." CR>)>
                    <RFALSE>)
        """).first

        XCTAssertNoDifference(
            parsed,
            .quote(
                .list([
                    .global(.atom("DEAD")),
                    .form([
                        .atom("COND"),
                        .list([
                            .local("VB"),
                            .form([
                                .atom("TELL"),
                                .string("Your hand passes through its object."),
                                .atom("CR")
                            ])
                        ])
                    ]),
                    .form([
                        .atom("RFALSE")
                    ])
                ])
            )
        )
    }

    func testSegmentedForm() throws {
        let parsed = try zilParser.parse("""
            !<IFFLAG (DEBUG '(XTRACE)) (ELSE '())>
        """).first

        XCTAssertNoDifference(
            parsed,
            .segment(
                .form([
                    .atom("IFFLAG"),
                    .list([
                        .atom("DEBUG"),
                        .quote(
                            .list([
                                .atom("XTRACE")
                            ])
                        )
                    ]),
                    .list([
                        .atom("ELSE"),
                        .quote(
                            .list([])
                        )
                    ])
                ])
            )
        )
    }

    func testSegmentedGlobal() throws {
        let parsed = try zilParser.parse("""
            !,EXTRA-FLAGS
        """).first

        XCTAssertNoDifference(parsed, .segment(.global(.atom("EXTRA-FLAGS"))))
    }

    func testString() throws {
        let parsed = try zilParser.parse("""
            "There is an object which looks like a tube of toothpaste here."
        """).first

        XCTAssertNoDifference(
            parsed,
            .string("There is an object which looks like a tube of toothpaste here.")
        )
    }

    func testType() throws {
        let parsed = try zilParser.parse("""
            #BYTE
        """).first

        XCTAssertNoDifference(parsed, .type("BYTE"))
    }

    func testVector() throws {
        let parsed = try zilParser.parse("""
            [BITS .BITS]
        """).first

        XCTAssertNoDifference(
            parsed,
            .vector([
                .atom("BITS"),
                .local("BITS")
            ])
        )
    }

    func testVerb() throws {
        let parsed = try zilParser.parse("""
            ,V?LOOK-INSIDE
        """).first

        XCTAssertNoDifference(parsed, .verb("LOOK-INSIDE"))
    }
}
