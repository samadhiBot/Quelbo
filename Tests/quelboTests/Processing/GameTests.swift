//
//  GameTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/23/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class GameTests: XCTestCase {
    // https://foss.heptapod.net/zilf/zilf/-/blob/branch/default/sample/beer/beer.zil
    func testBeer() throws {
        let zil = #"""
            "99 Bottles of Beer sample for ZILF"

            <ROUTINE GO () <SING 99>>

            <ROUTINE SING (N)
                <REPEAT ()
                    <BOTTLES .N>
                    <PRINTI " of beer on the wall,|">
                    <BOTTLES .N>
                    <PRINTI " of beer,|Take one down, pass it around,|">
                    <COND
                        (<DLESS? N 1> <PRINTR "No more bottles of beer on the wall!">)
                        (ELSE <BOTTLES .N> <PRINTI " of beer on the wall!||">)>>>

            <ROUTINE BOTTLES (N)
                <PRINTN .N>
                <PRINTI " bottle">
                <COND (<N==? .N 1> <PRINTC !\s>)>
                <RTRUE>>
            """#

        var game = Game()
        try game.parse(zil)
        try game.process()

        XCTAssertNoDifference(
            Game.output,
            #"""
            // Routines
            // ================================================================================

            /// The `bottles` (BOTTLES) routine.
            @discardableResult mutating func bottles(_ n: Int) -> Bool {
                output(n)
                output(" bottle")
                if n != 1 {
                    output("s")
                }
                return true
            }

            /// The `go` (GO) routine.
            @discardableResult mutating func go() -> Bool {
                sing(99)
            }

            /// The `sing` (SING) routine.
            mutating func sing(_ n: Int) -> Bool {
                var n = n
                repeat {
                    bottles(n)
                    output("""
                         of beer on the wall,
                        *
                        """)
                    bottles(n)
                    output("""
                         of beer,
                        Take one down, pass it around,
                        *
                        """)
                    if n.decrement() < 1 {
                        output(
                            "No more bottles of beer on the wall!",
                            withCarriageReturn: true
                        )
                    } else {
                        bottles(n)
                        output("""
                             of beer on the wall!
                            *
                            *
                            """)
                    }
                } while n > 0
                return true
            }
            """#.replacingOccurrences(of: "*", with: "")
        )
    }
}
