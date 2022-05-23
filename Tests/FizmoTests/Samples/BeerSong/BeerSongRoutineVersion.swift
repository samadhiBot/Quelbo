//
//  BeerSongRoutineVersion.swift
//  Fizmo
//
//  Created by Chris Sessions on 3/24/22.
//

import Fizmo
import Foundation

// https://foss.heptapod.net/zilf/zilf/-/blob/branch/default/sample/beer/beer.zil

struct BeerSongRoutineVersion {
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
}
