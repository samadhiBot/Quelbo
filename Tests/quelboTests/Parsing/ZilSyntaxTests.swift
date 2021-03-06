//
//  ZilSyntaxTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/6/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class ZilSyntaxTests: QuelboTests {
    let parser = ZilSyntax().parser

    // MARK: - Atoms

    func testAtomFoo() {
        let input = "FOO"
        XCTAssertNoDifference(
            try parser.parse(input),
            .atom("FOO")
        )
    }

    func testAtomFrequentWords() {
        let input = "FREQUENT-WORDS?"
        XCTAssertNoDifference(
            try parser.parse(input),
            .atom("FREQUENT-WORDS?")
        )
    }

    func testAtomFooBar() {
        let input = "FOO-BAR"
        XCTAssertNoDifference(
            try parser.parse(input),
            .atom("FOO-BAR")
        )
    }

    func testAtomDashBar() {
        let input = "-BAR"
        XCTAssertNoDifference(
            try parser.parse(input),
            .atom("-BAR")
        )
    }

    func testAtomSlash123() {
        let input = #"\123"#
        XCTAssertNoDifference(
            try parser.parse(input),
            .atom(#"\123"#)
        )
    }

    func testAtomSlashDash123() {
        let input = #"\-123"#
        XCTAssertNoDifference(
            try parser.parse(input),
            .atom(#"\-123"#)
        )
    }

    func testAtomIsZero() {
        let input = "0?"
        XCTAssertNoDifference(
            try parser.parse(input),
            .atom("0?")
        )
    }

    func testAtomIsOne() {
        let input = "1?"
        XCTAssertNoDifference(
            try parser.parse(input),
            .atom("1?")
        )
    }

    // MARK: - Bools

    func testTrue() {
        let input = "T"
        XCTAssertNoDifference(
            try parser.parse(input),
            .atom("T") // Must handle specially when boolean true is needed
        )
    }

    func testFalse() {
        let input = "<>"
        XCTAssertNoDifference(
            try parser.parse(input),
            .bool(false)
        )
    }

    // MARK: - ChangeType

    func testChangeType() {
        let input = "#FIX"
        XCTAssertNoDifference(
            try parser.parse(input),
            .type("FIX")
        )
    }

    // MARK: - Character

    func testCharacter() {
        let input = #"!\A"#
        XCTAssertNoDifference(
            try parser.parse(input),
            .character("A")
        )
    }

    // MARK: - Comments

    func testCommentedString() {
        let input = #";"This is a commented string.""#
        XCTAssertNoDifference(
            try parser.parse(input),
            .commented(
                .string("This is a commented string.")
            )
        )
    }

    func testCommentedList() {
        let input = ";(This is a commented list)"
        XCTAssertNoDifference(
            try parser.parse(input),
            .commented(
                .list([
                    .atom("This"),
                    .atom("is"),
                    .atom("a"),
                    .atom("commented"),
                    .atom("list"),
                ])
            )
        )
    }

    func testCommentedForm() {
        let input = ";<THIS IS A <COMMENTED <FORM> (WITH LIST) AND #OTHER STUFF>>"
        XCTAssertNoDifference(
            try parser.parse(input),
            .commented(
                .form([
                    .atom("THIS"),
                    .atom("IS"),
                    .atom("A"),
                    .form(
                        [
                            .atom("COMMENTED"),
                            .form(
                                [
                                    .atom("FORM")
                                ]
                            ),
                            .list(
                                [
                                    .atom("WITH"),
                                    .atom("LIST")
                                ]
                            ),
                            .atom("AND"),
                            .type("OTHER"),
                            .atom("STUFF")
                        ]
                    )
                ])
            )
        )
    }

    // MARK: - Decimal numbers

    func testDecimal() {
        let input = "1234567890"
        XCTAssertNoDifference(
            try parser.parse(input),
            .decimal(1234567890)
        )
    }

    func testNegativeDecimal() {
        let input = "-1234567890"
        XCTAssertNoDifference(
            try parser.parse(input),
            .decimal(-1234567890)
        )
    }

    // MARK: - Forms

    func testSimpleForm() {
        let input = "<RFALSE>"
        XCTAssertNoDifference(
            try parser.parse(input),
            .form([
                .atom("RFALSE")
            ])
        )
    }

    func testTwoElementForm() {
        let input = "<FIND-WEAPON .VILLAIN>"
        XCTAssertNoDifference(
            try parser.parse(input),
            .form([
                .atom("FIND-WEAPON"),
                .local("VILLAIN"),
            ])
        )
    }

    func testComplexForm() {
        let input = "<THIS IS A <FORM (WITH LIST) AND #OTHER STUFF 123>>"
        XCTAssertNoDifference(
            try parser.parse(input),
            .form([
                .atom("THIS"),
                .atom("IS"),
                .atom("A"),
                .form(
                    [
                        .atom("FORM"),
                        .list([
                            .atom("WITH"),
                            .atom("LIST"),
                        ]),
                        .atom("AND"),
                        .type("OTHER"),
                        .atom("STUFF"),
                        .decimal(123)
                    ]
                )
            ])
        )
    }

    func testFormWithMultilineString() {
        let input = """
            <ROOM FOYER
                (DESC "Foyer of the Opera House")
                (IN ROOMS)
                (LDESC "You are standing in a spacious hall, splendidly decorated in red
            and gold, with glittering chandeliers overhead. The entrance from
            the street is to the north, and there are doorways south and west.")
                (SOUTH TO BAR)
                (WEST TO CLOAKROOM)
                (NORTH SORRY "You've only just arrived, and besides, the weather outside
            seems to be getting worse.")
                (FLAGS LIGHTBIT)>
            """
        XCTAssertNoDifference(
            try parser.parse(input),
            .form(
                [
                    .atom("ROOM"),
                    .atom("FOYER"),
                    .list(
                        [
                            .atom("DESC"),
                            .string("Foyer of the Opera House")
                        ]
                    ),
                    .list(
                        [
                            .atom("IN"),
                            .atom("ROOMS")
                        ]
                    ),
                    .list(
                        [
                            .atom("LDESC"),
                            .string("You are standing in a spacious hall, splendidly decorated in red and gold, with glittering chandeliers overhead. The entrance from the street is to the north, and there are doorways south and west.")
                        ]
                    ),
                    .list(
                        [
                            .atom("SOUTH"),
                            .atom("TO"),
                            .atom("BAR")
                        ]
                    ),
                    .list(
                        [
                            .atom("WEST"),
                            .atom("TO"),
                            .atom("CLOAKROOM")
                        ]
                    ),
                    .list(
                        [
                            .atom("NORTH"),
                            .atom("SORRY"),
                            .string("You\'ve only just arrived, and besides, the weather outside seems to be getting worse.")
                        ]
                    ),
                    .list(
                        [
                            .atom("FLAGS"),
                            .atom("LIGHTBIT")
                        ]
                    )
                ]
            )
        )
    }

    // MARK: - Global

    func testGlobal() {
        let input = ",FOO"
        XCTAssertNoDifference(
            try parser.parse(input),
            .global("FOO")
        )
    }

    // MARK: - Lists

    //(THIS IS A (NESTED LIST (WITH MORE (NESTING))))
    func testSimpleList() {
        let input = "(PURE)"
        XCTAssertNoDifference(
            try parser.parse(input),
            .list([
                .atom("PURE")
            ])
        )
    }

    // MARK: - Local

    func testLocal() {
        let input = ".FOO"
        XCTAssertNoDifference(
            try parser.parse(input),
            .local("FOO")
        )
    }

    // MARK: - Property

    func testProperty() {
        let input = ",P?FOO"
        XCTAssertNoDifference(
            try parser.parse(input),
            .property("FOO")
        )
    }

    // MARK: - Quote

    func testQuote() {
        let input = "'<INC X 2>"
        XCTAssertNoDifference(
            try parser.parse(input),
            .quote(
                .form(
                    [
                        .atom("INC"),
                        .atom("X"),
                        .decimal(2)
                    ]
                )
            )
        )
    }

    // MARK: - Segment

    func testSegmentLocal() {
        let input = "!.FOO"
        XCTAssertNoDifference(
            try parser.parse(input),
            .segment(.local("FOO"))
        )
    }

    func testSegmentForm() {
        let input = "!<SUBSTRUC .L1 0 3>"
        XCTAssertNoDifference(
            try parser.parse(input),
            .segment(
                .form(
                    [
                        .atom("SUBSTRUC"),
                        .local("L1"),
                        .decimal(0),
                        .decimal(3)
                    ]
                )
            )
        )
    }

    func testSegmentFormWithClosingBang() {
        let input = "!<LVAL L1!>"
        XCTAssertNoDifference(
            try parser.parse(input),
            .segment(
                .form(
                    [
                        .atom("LVAL"),
                        .atom("L1!"), // Bang suffix removed in `String.scrubbed`
                    ]
                )
            )
        )
    }

    // MARK: - Strings

    func testSimpleString() {
        let input = #""This string is simple.""#
        XCTAssertNoDifference(
            try parser.parse(input),
            .string("This string is simple.")
        )
    }

    func testMultilineString() {
        let input = """
            "This string|
            spans multiple|
            lines"
            """
        XCTAssertNoDifference(
            try parser.parse(input),
            .string(
                """
                This string
                spans multiple
                lines
                """
            )
        )
    }

    func testNestedQuotesString() {
        let input = #""This string has \"nested\" quotes.""#
        XCTAssertNoDifference(
            try parser.parse(input),
            .string(#"This string has "nested" quotes."#)
        )
    }

    // MARK: - Vectors

    func testVector() {
        let input = #"[1 2 "AB" !\C]"#
        XCTAssertNoDifference(
            try parser.parse(input),
            .vector([
                .decimal(1),
                .decimal(2),
                .string("AB"),
                .character("C"),
            ])
        )
    }
}

// MARK: - Sample tokens to test against

/*
 ;From https://foss.heptapod.net/zilf/zilf/-/blob/branch/default/EditorSupport/sample.zil

 "Syntax Highlighting Sample"

 "=== Comments ==="

 ;"This is a commented string."

 ;(This is a commented list)

 ;[This is a commented vector]

 ;![This is a commented uvector]
 ;![This one ends with a bang bracket !]

 ;<THIS IS A <COMMENTED <FORM> (WITH LIST) AND #OTHER STUFF>>

 ;.COMMENTED-LVAL
 ;,COMMENTED-GVAL
 ;'COMMENTED-QUOTE
 ;!.COMMENTED-SEG-LVAL
 ;!,COMMENTED-SEG-GVAL
 ;!<COMMENTED-SEGMENT>
 ;%<COMMENTED-MACRO>
 ;%%<COMMENTED-VMACRO>

 ; "Comment with space after semicolon"
 ; <WORKS FOR THESE TOO>

 "=== Quotations ==="

 '"This is a quoted string."
 '<THIS IS A <QUOTED <FORM (ET CETERA)>>>
 '.QUOTED-LVAL
 ',QUOTED-GVAL
 ''QUOTED-QUOTATION
 '!.QUOTED-SEGMENT
 '%<QUOTED-MACRO>
 '%%<QUOTED-VMACRO>

 "=== Structures ==="

 <THIS IS A <FORM (WITH LIST) AND #OTHER STUFF 123>>

 (THIS IS A (NESTED LIST (WITH MORE (NESTING))))

 [THIS IS A VECTOR [WITH INNER VECTOR]]
 ![THIS IS A UVECTOR ![INNER ONE ENDS WITH BANG BRACKET !] ]

 <TELL "This string has \"nested\" quotes.">
 <TELL "This string|
 spans multiple|
 lines">

 "=== Local and global variable references ==="
 .LVAL
 . LVAL-WITH-SPACE
 ,GVAL
 , GVAL-WITH-SPACE
 ..LVAL-LVAL
 .,LVAL-GVAL
 ,,GVAL-GVAL
 ,.GVAL-LVAL
 .<LVAL-FORM>
 ,<GVAL-FORM>

 "=== Segments ==="
 !.SEG-LVAL
 !,SEG-GVAL
 !<SEGMENT>

 ! .SEG-WITH-SPACE
 ! ,SEG-WITH-SPACE
 ! <SEG-WITH-SPACE>

 "=== READ Macros==="
 %<MACRO>
 %%<VMACRO>
 %.FOO
 %%.FOO
 %,FOO
 %%,FOO

 <FOO %<MACRO>>        ;"call FOO with macro result arg"

 "=== Character literals ==="
 !\C        ;"literal C"
 !\         ;"literal space"
 !\CDEF        ;"literal C followed by atom DEF"

 "=== Decimal numbers ==="
 1234567890
 -1234567890

 "=== Octal numbers ==="
 *12345670*
 *123*\A        ;"octal 123 followed by atom A"
 *123*,A        ;"octal 123 followed by gval ,A"

 "=== Binary numbers ==="
 #2 11001010

 "=== Hashed (chtyped) expressions ==="
 #FALSE (HEY NOW)
 #BYTE 255
 #HASH ATOM

 "=== False ==="
 <>

 "=== Atoms ==="
 FOO
 FOO-BAR
 -BAR
 FOO\<BAR
 ATOM-WITH-TRAILING-SPACE\
 ATOM\ WITH\ INNER\ SPACES
 \123
 \-123
 12\3
 -12\3

 "=== Atoms that start out looking like numbers ==="
 1234567890?
 -1234567890?
 123-
 -123-
 --123
 --
 -

 "=== Atoms that start out looking like octal numbers ==="
 **
 ***
 *12345670
 *12345670**
 *12345678*
 *1234567A*
 *123*.A        ;"dot is allowed in an atom"
 \*123*
 *1\23*
 *123\*

 */
