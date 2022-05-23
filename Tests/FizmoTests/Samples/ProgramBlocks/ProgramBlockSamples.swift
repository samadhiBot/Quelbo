//
//  ProgramBlockSamples.swift
//  Fizmo
//
//  Created by Chris Sessions on 4/23/22.
//

import Fizmo
import Foundation

struct ProgramBlockSamples {
    let isFunnyReturn: Bool = true

    // MARK: - AGAIN

    // https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.1au1eum

    /// The `testAgain1` (TEST-AGAIN-1) routine.
    func testAgain1() {
        var x: Int = 0
        while true {
            x.set(to: x.add(1))
            output(x)
            output(" ")
            if x.equals(5) {
                break
            }
            continue
            /* Start routine again, X keeps value */
        }
    }

    /// The `testAgain2` (TEST-AGAIN-2) routine.
    func testAgain2() {
        while true {
            var x: Int = 0
            x.set(to: x.add(1))
            output(x)
            output(" ")
            if x.equals(5) {
                break
            }
            /* Never reached */
            continue
            /* Start routine again, X reinitialize to 0 */
        }
    }

    /// The `testAgain3` (TEST-AGAIN-3) routine.
    func testAgain3() {
        var x: Int = 0
        act1: while true {
            x.set(to: x.add(1))
            output(x)
            output(" ")
            if x.equals(5) {
                break
            }
            continue act1
            /* Start block again from ACT1, */
        }
    }

    /// The `testAgain4` (TEST-AGAIN-4) routine.
    func testAgain4() {
        var x: Int = 0
        while true {
            /* PROG generates default activation */
            x.set(to: x.add(1))
            output(x)
            output(" ")
            if x.equals(5) {
                break
            }
            continue
            /* Start block again from PROG, */
        }
    }

    // MARK: - BIND

    // https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.12jfdx2

    /// The `testBind1` (TEST-BIND-1) routine.
    func testBind1() {
        var x: Int = 0
        output("START ")
        x.set(to: 1)
        do {
            var x: Int = 0
            x.set(to: 2)
            output(x)
            output(" ")
            /* --> 2 (Inner X) */
        }
        output(x)
        output(" ")
        /* --> 1 (Outer X) */
        output("END")
    }

    /// The `testBind2` (TEST-BIND-2) routine.
    func testBind2() {
        var x: Int = 0
        defaultAct: while true {
            output("START ")
            do {
                x.set(to: x.add(1))
                output(x)
                output(" ")
                if x.equals(3) {
                    break defaultAct
                }
                /* --> exit routine */
                continue
                /* --> top of routine */
            }
            // output("END") "Will never be executed"
            /* Never reached */
        }
    }
    // "START 1 START 2 START 3 "

    // MARK: - DEFINE

    @discardableResult
    /// The `incForm` (INC-FORM) function.
    func incForm(a: Int) -> Int {
        var a = a
        return a.set(to: .add(1, a))
    }

    @discardableResult
    /// The `myadd` (MYADD) function.
    func myadd(x1: Int, x2: Int) -> Int {
        var x1 = x1
        return x1.add(x2)
    }

    @discardableResult
    /// The `powerTo` (POWER-TO) function.
    func powerTo(x: Int, y: Int = 2) -> Int {
        if y.equals(0) {
            return 1
        }
        var z: Int = 1
        var i: Int = 0
        while true {
            z.set(to: z.multiply(x))
            i.set(to: i.add(1))
            if i.equals(y) {
                return z
            }
        }
    }

    @discardableResult
    /// The `square` (SQUARE) function.
    func square(x: Int) -> Int {
        var x = x
        return x.multiply(x)
    }
    
    // MARK: - PROG

    // https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.1bkyn9b

    /// The `testProg1` (TEST-PROG-1) routine.
    func testProg1() {
        var x: Int = 0
        x.set(to: 2)
        output("START: ")
        do {
            var x: Int = 0
            x.set(to: 1)
            output(x)
            output(" ")
            /* Inner X */
        }
        output(x)
        /* Outer X */
        output(" END")
    }

    /// The `testProg2` (TEST-PROG-2) routine.
    func testProg2() {
        output("START: ")
        var x: Int = 0
        while true {
            /* X is not reinitialized between iterations. Default ACTIVATION created. */
            x.set(to: x.add(1))
            output(x)
            output(" ")
            if x.equals(3) {
                break
            }
            /* Bare RETURN without ACTIVATION will exit BLOCK */
            continue
            /* AGAIN without ACTIVATION will redo BLOCK */
        }
        output("RETURN EXIT BLOCK")
    }

    @discardableResult
    /// The `testProg3` (TEST-PROG-3) routine.
    func testProg3() -> Bool {
        output("START: ")
        var x: Int = 0
        while true {
            /* X is not reinitialized between iterations. Default ACTIVATION created. */
            x.set(to: x.add(1))
            output(x)
            output(" ")
            if x.equals(3) {
                if isFunnyReturn {
                    output("RETURN EXIT ROUTINE")
                }
                return true
            }
            /* RETURN with value but without ACTIVATION will exit ROUTINE (FUNNY-RETURN = TRUE) */
            continue
            /* AGAIN without ACTIVATION will redo BLOCK */
        }
        // output("RETURN EXIT BLOCK") "Will never be executed"
    }
    // "START: 1 2 3 RETURN EXIT BLOCK"

    // MARK: - REPEAT

    // https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.hkkpf6

    /// The `testRepeat1` (TEST-REPEAT-1) routine.
    func testRepeat1() {
        output("START: ")
        var x: Int = 0
        while true {
            /* X is not reinitialized between iterations. Default ACTIVATION created. */
            x.set(to: x.add(1))
            output(x)
            output(" ")
            if x.equals(3) {
                break
            }
            /* Bare RETURN without ACTIVATION will exit BLOCK */
        }
        output("RETURN EXIT BLOCK")
    }

    @discardableResult
    /// The `testRepeat2` (TEST-REPEAT-2) routine.
    func testRepeat2() -> Bool {
        output("START: ")
        var x: Int = 0
        while true {
            /* X is not reinitialized between iterations. Default ACTIVATION created. */
            x.set(to: x.add(1))
            output(x)
            output(" ")
            if x.equals(3) {
                if isFunnyReturn {
                    output("RETURN EXIT ROUTINE")
                }
                return true
            }
            /* RETURN with value but without ACTIVATION will exit ROUTINE (FUNNY-RETURN = TRUE) */
        }
        // output("RETURN EXIT BLOCK") "Will never be executed"
    }
    // "START: 1 2 3 RETURN EXIT BLOCK"
}
