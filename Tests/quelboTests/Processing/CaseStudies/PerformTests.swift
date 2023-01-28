//
//  PerformTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 11/3/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class PerformTests: QuelboTests {
    override func setUp() {
        super.setUp()

        GlobalObjectsTests().sharedSetUp()
        ZmemqTests().sharedSetUp()
        IsAccessibleTests().sharedSetUp()
        BufferPrintTests().sharedSetUp()
        NotHereTests().sharedSetUp()
        sharedSetUp()
    }

    func sharedSetUp() {
        process("""
            <CONSTANT M-BEG 1>

            <SETG DEBUG <>>

            <OBJECT IT
                (IN GLOBAL-OBJECTS)
                (SYNONYM IT THEM HER HIM)
                (DESC "random object")
                (FLAGS NDESCBIT TOUCHBIT)>

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

            <ROUTINE DD-APPLY (STR OBJ FCN "OPTIONAL" (FOO <>))
                <COND (,DEBUG <TELL "[" D .OBJ "=]">)>
                <D-APPLY .STR .FCN .FOO>>

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
        """)
    }

    func testIt() throws {
        XCTAssertNoDifference(
            Game.objects.find("it"),
            Statement(
                id: "it",
                code: """
                    /// The `it` (IT) object.
                    var it = Object(
                        id: "it",
                        description: "random object",
                        flags: [
                            .hasBeenTouched,
                            .omitDescription,
                        ],
                        location: globalObjects,
                        synonyms: [
                            "it",
                            "them",
                            "her",
                            "him",
                        ]
                    )
                    """,
                type: .object.optional.property.tableElement,
                category: .objects,
                isCommittable: true
            )
        )
    }

    func testDApply() throws {
        XCTAssertNoDifference(
            Game.routines.find("dApply"),
            Statement(
                id: "dApply",
                code: #"""
                    @discardableResult
                    /// The `dApply` (D-APPLY) routine.
                    func dApply(
                        str: String,
                        fcn: Routine,
                        foo: Int? = 0
                    ) -> Int? {
                        var res: Int? = 0
                        if .isNot(fcn) {
                            return 0
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
                            res.set(to: {
                                if foo.isAssigned {
                                    fcn(foo)
                                } else {
                                    fcn()
                                }
                            }())
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
                type: .int.optional,
                category: .routines,
                isCommittable: true,
                returnHandling: .passthrough
            )
        )
    }

    func testDDApply() throws {
        XCTAssertNoDifference(
            Game.routines.find("ddApply"),
            Statement(
                id: "ddApply",
                code: """
                    @discardableResult
                    /// The `ddApply` (DD-APPLY) routine.
                    func ddApply(
                        str: String,
                        obj: Object,
                        fcn: Routine,
                        foo: Int = 0
                    ) -> Int? {
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
                    """,
                type: .int.optional,
                category: .routines,
                isCommittable: true,
                returnHandling: .passthrough
            )
        )
    }

    func testPerform() throws {
        XCTAssertNoDifference(
            Game.routines.find("perform"),
            Statement(
                id: "perform",
                code: #"""
                    @discardableResult
                    /// The `perform` (PERFORM) routine.
                    func perform(
                        a: Int,
                        o: Object = nil,
                        i: Object = nil
                    ) -> Int? {
                        var v: Int? = 0
                        var oa: Verb? = nil
                        var oo: Object? = nil
                        var oi: Object? = nil
                        var o: Object? = nil
                        var i: Object? = nil
                        if debug {
                            output("** PERFORM: PRSA = ")
                            output(actions.nthElement(.add(.multiply(a, 2), 1)))
                            if .and(
                                o,
                                .isNot(a.equals(Verb.walk))
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
                        oa.set(to: parsedVerb)
                        oo.set(to: parsedDirectObject)
                        oi.set(to: parsedIndirectObject)
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
                        parsedVerb.set(to: a)
                        parsedDirectObject.set(to: o)
                        if _ = .and(
                            .object(parsedDirectObject),
                            .isNot(isParsedVerb(.walk))
                        ) {
                            pItObject.set(to: parsedDirectObject)
                        }
                        parsedIndirectObject.set(to: i)
                        if _ = .and(
                            notHereObject.equals(
                                parsedDirectObject,
                                parsedIndirectObject
                            ),
                            v.set(to: dApply(
                                str: "Not Here",
                                fcn: notHereObjectFunc
                            ))
                        ) {
                            return v
                        } else {
                            o.set(to: parsedDirectObject)
                            i.set(to: parsedIndirectObject)
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
                                .isNot(a.equals(Verb.walk)),
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
                                .isNot(a.equals(Verb.walk)),
                                v.set(to: dApply(
                                    str: "PRSO",
                                    fcn: o.action
                                ))
                            ) {
                                return v
                            } else if _ = v.set(to: dApply(
                                str: nil,
                                fcn: try actions.get(at: a)
                            )) {
                                return v
                            }
                        }
                        parsedVerb.set(to: oa)
                        parsedDirectObject.set(to: oo)
                        parsedIndirectObject.set(to: oi)
                        return v
                    }
                    """#,
                type: .int.optional,
                category: .routines,
                isCommittable: true,
                returnHandling: .passthrough
            )
        )
    }
}
