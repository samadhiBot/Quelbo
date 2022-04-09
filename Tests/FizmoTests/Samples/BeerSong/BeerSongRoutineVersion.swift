//
//  BeerSongRoutineVersion.swift
//  Fizmo
//
//  Created by Chris Sessions on 3/24/22.
//

import Foundation
import Fizmo

// https://foss.heptapod.net/zilf/zilf/-/blob/branch/default/sample/beer/beer.zil

struct BeerSongRoutineVersion {
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
        sing(3)
    }

    /// The `sing` (SING) routine.
    mutating func sing(_ n: Int) -> Bool {
        var n = n
        repeat {
            bottles(n)
            output("""
                 of beer on the wall,

                """)
            bottles(n)
            output("""
                 of beer,
                Take one down, pass it around,

                """)
            if n.decrement() < 1 {
                output("No more bottles of beer on the wall!", withCarriageReturn: true)
            } else {
                bottles(n)
                output("""
                     of beer on the wall!


                    """)
            }
        } while n > 0
        return true
    }
}
