//
//  PerformTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 9/30/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class PerformTests: QuelboTests {
    override func setUp() {
        super.setUp()

        process("""
            <CONSTANT M-BEG 1>
            <GLOBAL P-IT-OBJECT <>>
            <SETG DEBUG <>>
            <SETG WINNER ,PRSO>

            <DEFINE D-APPLY (STR FCN "OPTIONAL" FOO "AUX" RES)
                <COND (<NOT .FCN> <>)
                      (T
                       <COND (,DEBUG
                          <COND (<NOT .STR>
                             <TELL CR "  Default ->" CR>)
                            (T <TELL CR "  " .STR " -> ">)>)>
                       <SET RES
                        <COND (<ASSIGNED? FOO>
                           <APPLY .FCN .FOO>)
                          (T <APPLY .FCN>)>>
                       <COND (<AND ,DEBUG .STR>
                          <COND (<==? .RES 2>
                             <TELL "Fatal" CR>)
                            (<NOT .RES>
                             <TELL "Not handled">)
                            (T <TELL "Handled" CR>)>)>
                       .RES)>>

            <OBJECT IT
                (IN GLOBAL-OBJECTS)
                (SYNONYM IT THEM HER HIM)
                (DESC "random object")
                (FLAGS NDESCBIT TOUCHBIT)>

            <OBJECT NOT-HERE-OBJECT
                (DESC "such thing" ;"[not here]")
                (ACTION NOT-HERE-OBJECT-F)>

            <ROUTINE DD-APPLY (STR OBJ FCN "OPTIONAL" (FOO <>))
                <COND (,DEBUG <TELL "[" D .OBJ "=]">)>
                <D-APPLY .STR .FCN .FOO>>

            <DEFMAC VERB? ("ARGS" ATMS) <RTRUE>>

            <ROUTINE ACCESSIBLE? (OBJ "AUX" (L <LOC .OBJ>)) <RTRUE>>

            <ROUTINE NOT-HERE-OBJECT-F ("AUX" TBL (PRSO? T) OBJ) <RTRUE>>
        """, type: .mdl)
    }

    func testDDApply() {
        XCTAssertNoDifference(
            Game.routines.find("ddApply"),
            Statement(
                id: "ddApply",
                code: #"""
                    @discardableResult
                    /// The `ddApply` (DD-APPLY) routine.
                    func ddApply(
                        str: String,
                        obj: Object,
                        fcn: <Unknown>,
                        foo: Bool = false
                    ) -> Int {
                        if debug {
                            output("[")
                            output(obj.description)
                            output("=]")
                        }
                        return dApply(
                            str: str,
                            fcn: fcn,
                            foo: foo
                        )
                    }
                    """#,
                type: .int,
                category: .routines,
                isCommittable: true
            )
        )
    }

    func testDApply() {
        XCTAssertNoDifference(
            Game.routines.find("dApply"),
            Statement(
                id: "dApply",
                code: #"""
                    @discardableResult
                    /// The `dApply` (D-APPLY) routine.
                    func dApply(
                        str: String,
                        fcn: <Unknown>,
                        foo: Bool = false
                    ) -> Int {
                        var res: Int = 0
                        if .isNot(fcn) {
                            return false
                        } else {
                            if debug {
                                if .isNot(str) {
                                    output("\n")
                                } else {
                                    output("\n")
                                    output(str)
                                    output(" -> ")
                                }
                            }
                            res.set(to: if foo.isAssigned {
                                fcn(foo)
                            } else {
                                fcn()
                            })
                            if .and(debug, str) {
                                if res.equals(2) {
                                    output("Fatal")
                                } else if .isNot(res) {
                                    output("Not handled")
                                } else {
                                    output("Handled")
                                }
                            }
                            return res
                        }
                    }
                    """#,
                type: .int,
                category: .routines,
                isCommittable: true
            )
        )
    }

    func testProcessPerformZorkDefinition() throws {
        let symbol = process("""
            <ROUTINE PERFORM (A "OPTIONAL" (O <>) (I <>) "AUX" V OA OO OI)
                #DECL ((A) FIX (O) <OR FALSE OBJECT FIX> (I) <OR FALSE OBJECT> (V) ANY)
                <COND (,DEBUG
                       <TELL "** PERFORM: PRSA = ">
                       <PRINC <NTH ,ACTIONS <+ <* .A 2> 1>>>
                       <COND (<AND .O <NOT <==? .A ,V?WALK>>>
                          <TELL " | PRSO = " D .O>)>
                       <COND (.I <TELL " | PRSI = " D .I>)>)>
                <SET OA ,PRSA>
                <SET OO ,PRSO>
                <SET OI ,PRSI>
                <COND (<AND <EQUAL? ,IT .I .O>
                        <NOT <ACCESSIBLE? ,P-IT-OBJECT>>>
                       <TELL "I don't see what you are referring to." CR>
                       <RFATAL>)>
                <COND (<==? .O ,IT> <SET O ,P-IT-OBJECT>)>
                <COND (<==? .I ,IT> <SET I ,P-IT-OBJECT>)>
                <SETG PRSA .A>
                <SETG PRSO .O>
                <COND (<AND ,PRSO <NOT <VERB? WALK>>>
                       <SETG P-IT-OBJECT ,PRSO>)>
                <SETG PRSI .I>
                <COND (<AND <EQUAL? ,NOT-HERE-OBJECT ,PRSO ,PRSI>
                        <SET V <D-APPLY "Not Here" ,NOT-HERE-OBJECT-F>>> .V)
                      (T
                       <SET O ,PRSO>
                       <SET I ,PRSI>
                       <COND (<SET V <DD-APPLY "Actor" ,WINNER
                                  <GETP ,WINNER ,P?ACTION>>> .V)
                         (<SET V <D-APPLY "Room (M-BEG)"
                                  <GETP <LOC ,WINNER> ,P?ACTION>
                                  ,M-BEG>> .V)
                         (<SET V <D-APPLY "Preaction"
                                  <GET ,PREACTIONS .A>>> .V)
                         (<AND .I <SET V <D-APPLY "PRSI"
                                      <GETP .I ,P?ACTION>>>> .V)
                         (<AND .O
                           <NOT <==? .A ,V?WALK>>
                           <LOC .O>
                           <GETP <LOC .O> ,P?CONTFCN>
                           <SET V <DD-APPLY "Container" <LOC .O>
                                   <GETP <LOC .O> ,P?CONTFCN>>>>
                          .V)
                         (<AND .O
                           <NOT <==? .A ,V?WALK>>
                           <SET V <D-APPLY "PRSO"
                                   <GETP .O ,P?ACTION>>>>
                          .V)
                         (<SET V <D-APPLY <>
                                  <GET ,ACTIONS .A>>> .V)>)>
                <SETG PRSA .OA>
                <SETG PRSO .OO>
                <SETG PRSI .OI>
                .V>
            """
        )

        XCTAssertNoDifference(symbol, .statement(
            id: "perform",
            code: #"""
                @discardableResult
                /// The `perform` (PERFORM) routine.
                func perform(
                    a: Int,
                    o: Object = nil,
                    i: Object = nil
                ) -> Int {
                    var v: Int = 0
                    var oa: Int = 0
                    var oo: Object? = nil
                    var oi: Object? = nil
                    var o: Object? = nil
                    var i: Object? = nil
                    if debug {
                        output("** PERFORM: PRSA = ")
                        output(actions.nthElement(.add(.multiply(a, 2), 1)))
                        if .and(
                            o,
                            .isNot(a.equals(WALK))
                        ) {
                            output("""

                                 PRSO =
                                """)
                            output(o.description)
                        }
                        if _ = i {
                            output("""

                                 PRSI =
                                """)
                            output(i.description)
                        }
                    }
                    oa.set(to: prsa)
                    oo.set(to: prso)
                    oi.set(to: prsi)
                    if .and(
                        it.equals(i, o),
                        .isNot(isAccessible(obj: pItObject))
                    ) {
                        output("I don't see what you are referring to.")
                        returnFatal()
                    }
                    if o.equals(it) {
                        o.set(to: pItObject)
                    }
                    if i.equals(it) {
                        i.set(to: pItObject)
                    }
                    prsa.set(to: a)
                    prso.set(to: o)
                    if _ = .and(
                        prso,
                        .isNot(isVerb(.walk))
                    ) {
                        pItObject.set(to: prso)
                    }
                    prsi.set(to: i)
                    if .and(
                        notHereObject.equals(prso, prsi),
                        v.set(to: dApply(
                            str: "Not Here",
                            fcn: @discardableResult
                            /// The `notHereObjectFunc` (NOT-HERE-OBJECT-F) routine.
                            func notHereObjectFunc() -> Bool {
                                var tbl: <Unknown> = <Unknown>
                                var isPrso: Bool = true
                                var obj: Object? = nil
                                return true
                            }
                        ))
                    ) {
                        return v
                    } else {
                        o.set(to: prso)
                        i.set(to: prsi)
                        if _ = v.set(to: ddApply(
                            str: "Actor",
                            obj: winner,
                            fcn: winner.action
                        )) {
                            return v
                        } else if _ = v.set(to: dApply(
                            str: "Room (M-BEG)",
                            fcn: winner.parent.action,
                            foo: mBeg
                        )) {
                            return v
                        } else if _ = v.set(to: dApply(
                            str: "Preaction",
                            fcn: try preactions.get(at: a)
                        )) {
                            return v
                        } else if _ = .and(
                            i,
                            v.set(to: dApply(
                                str: "PRSI",
                                fcn: i.action
                            ))
                        ) {
                            return v
                        } else if _ = .and(
                            o,
                            .isNot(a.equals(WALK)),
                            o.parent,
                            o.parent.containerFunction,
                            v.set(to: ddApply(
                                str: "Container",
                                obj: o.parent,
                                fcn: o.parent.containerFunction
                            ))
                        ) {
                            return v
                        } else if _ = .and(
                            o,
                            .isNot(a.equals(WALK)),
                            v.set(to: dApply(
                                str: "PRSO",
                                fcn: o.action
                            ))
                        ) {
                            return v
                        } else if _ = v.set(to: dApply(
                            str: false,
                            fcn: try actions.get(at: a)
                        )) {
                            return v
                        }
                    }
                    prsa.set(to: oa)
                    prso.set(to: oo)
                    prsi.set(to: oi)
                    return v
                }
                """#,
            type: .int,
            category: .routines,
            isCommittable: true
        ))
    }
}
