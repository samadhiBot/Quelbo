//
//  GameTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/23/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class GameTests: QuelboTests {
    // https://foss.heptapod.net/zilf/zilf/-/blob/branch/default/sample/hello/hello.zil
    func testHello() throws {
        let zil = #"""
            "Hello World sample for ZILF"

            <ROUTINE GO ()
                <PRINTI "Hello, world!">
                <CRLF>>
            """#

        let game = Game.shared
        try game.parse(zil)
        try game.processTokens()

        XCTAssertNoDifference(
            game.output,
            #"""
            // Routines
            // ============================================================

            /// The `go` (GO) routine.
            func go() {
                output("Hello, world!")
                output("\n")
            }
            """#
        )
    }

    // https://foss.heptapod.net/zilf/zilf/-/blob/branch/default/sample/beer/beer.zil
    func testBeer() throws {
        let zil = #"""
            "99 Bottles of Beer sample for ZILF"

            <ROUTINE GO () <SING 3>>

            <ROUTINE SING (N)
                <REPEAT ()
                    <BOTTLES .N>
                    <PRINTI " of beer on the wall,|">
                    <BOTTLES .N>
                    <PRINTI " of beer,|Take one down, pass it around,|">
                    <COND
                        (<DLESS? N 1>
                         <PRINTR "No more bottles of beer on the wall!">
                         <RTRUE>)
                        (ELSE <BOTTLES .N> <PRINTI " of beer on the wall!||">)>>>

            <ROUTINE BOTTLES (N)
                <PRINTN .N>
                <PRINTI " bottle">
                <COND (<N==? .N 1> <PRINTC !\s>)>
                <RTRUE>>
            """#

        let game = Game.shared
        try game.parse(zil)
        try game.processTokens()

        XCTAssertNoDifference(
            game.output,
            #"""
            // Routines
            // ============================================================

            @discardableResult
            /// The `bottles` (BOTTLES) routine.
            func bottles(n: Int) -> Bool {
                output(n)
                output(" bottle")
                if n.isNotEqualTo(1) {
                    output("s")
                }
                return true
            }

            @discardableResult
            /// The `go` (GO) routine.
            func go() -> Bool {
                return sing(n: 3)
            }

            @discardableResult
            /// The `sing` (SING) routine.
            func sing(n: Int) -> Bool {
                var n = n
                while true {
                    bottles(n: n)
                    output("""
                         of beer on the wall,

                        """)
                    bottles(n: n)
                    output("""
                         of beer,
                        Take one down, pass it around,

                        """)
                    if n.decrement().isLessThan(1) {
                        output("No more bottles of beer on the wall!")
                        output("\n")
                        return true
                    } else {
                        bottles(n: n)
                        output("""
                             of beer on the wall!


                            """)
                    }
                }
            }
            """#
        )
    }
}
