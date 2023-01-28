//
//  DescribeObjectTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 11/22/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class DescribeObjectTests: QuelboTests {
    override func setUp() {
        super.setUp()

        GlobalObjectsTests().sharedSetUp()
    }

    func sharedSetUp(for zorkNumber: ZorkNumber = .zork1) {
        var versionSpecificDefs: String {
            switch zorkNumber {
            case .zork1: return """
                    <OBJECT TROPHY-CASE (FLAGS TRANSBIT CONTBIT NDESCBIT TRYTAKEBIT SEARCHBIT)>
                """
                
            case .zork2: return """
                    <CONSTANT S-FANTASIZE 12>

                    <GLOBAL FANTASIES
                        <LTABLE "pile of jewels" "gold ingot" "basilisk"
                            "bulging chest" "yellow sphere" "grue"
                            "convention of wizards" "copy of ZORK I">>
                    <GLOBAL SPELL-USED <>>
                    <GLOBAL SPELL-VICTIM <>>
                    <GLOBAL SPELL? <>>
                """
            case .zork3: return ""
            }
        }

        process("""
            <SETG ZORK-NUMBER \(zorkNumber.rawValue)>

            \(versionSpecificDefs)

            <CONSTANT M-OBJDESC 5>

            <GLOBAL INDENTS
                <TABLE (PURE)
                       ""
                       "  "
                       "    "
                       "      "
                       "        "
                       "          ">>
            <GLOBAL LIT <>>
            <GLOBAL WINNER 0>

            <OBJECT ADVENTURER (FLAGS NDESCBIT INVISIBLE SACREDBIT ACTORBIT)>
            <OBJECT ROOMS (IN TO ROOMS)>

            <DEFMAC PROB ('BASE? "OPTIONAL" 'LOSER?)
                <COND (<ASSIGNED? LOSER?> <FORM ZPROB .BASE?>)
                      (ELSE <FORM G? .BASE? '<RANDOM 100>>)>>

            <ROUTINE FIRSTER (OBJ LEVEL)
                 <COND %<COND (<==? ,ZORK-NUMBER 1>
                           '(<EQUAL? .OBJ ,TROPHY-CASE>
                             <TELL "Your collection of treasures consists of:" CR>))
                          (T
                           '(<NULL-F> <RTRUE>))>
                       (<EQUAL? .OBJ ,WINNER>
                    <TELL "You are carrying:" CR>)
                       (<NOT <IN? .OBJ ,ROOMS>>
                    <COND (<G? .LEVEL 0>
                           <TELL <GET ,INDENTS .LEVEL>>)>
                    <COND (<FSET? .OBJ ,SURFACEBIT>
                           <TELL "Sitting on the " D .OBJ " is: " CR>)
                          (<FSET? .OBJ ,ACTORBIT>
                           <TELL "The " D .OBJ " is holding: " CR>)
                          (T
                           <TELL "The " D .OBJ " contains:" CR>)>)>>

            <ROUTINE SEE-INSIDE? (OBJ)
                 <AND <NOT <FSET? .OBJ ,INVISIBLE>>
                      <OR <FSET? .OBJ ,TRANSBIT> <FSET? .OBJ ,OPENBIT>>>>

            <ROUTINE PICK-ONE (FROB
                       "AUX" (L <GET .FROB 0>) (CNT <GET .FROB 1>) RND MSG RFROB)
                 <SET L <- .L 1>>
                 <SET FROB <REST .FROB 2>>
                 <SET RFROB <REST .FROB <* .CNT 2>>>
                 <SET RND <RANDOM <- .L .CNT>>>
                 <SET MSG <GET .RFROB .RND>>
                 <PUT .RFROB .RND <GET .RFROB 1>>
                 <PUT .RFROB 1 .MSG>
                 <SET CNT <+ .CNT 1>>
                 <COND (<==? .CNT .L> <SET CNT 0>)>
                 <PUT .FROB 0 .CNT>
                 .MSG>

            <ROUTINE PRINT-CONT (OBJ "OPTIONAL" (V? <>) (LEVEL 0)
                         "AUX" Y 1ST? SHIT AV STR (PV? <>) (INV? <>))
                 <COND (<NOT <SET Y <FIRST? .OBJ>>> <RTRUE>)>
                 <COND (<AND <SET AV <LOC ,WINNER>> <FSET? .AV ,VEHBIT>>
                    T)
                       (ELSE <SET AV <>>)>
                 <SET 1ST? T>
                 <SET SHIT T>
                 <COND (<EQUAL? ,WINNER .OBJ <LOC .OBJ>>
                    <SET INV? T>)
                       (ELSE
                    <REPEAT ()
                        <COND %<COND (<==? ,ZORK-NUMBER 2>
                                  '(<NOT .Y>
                                <COND (<AND <0? .LEVEL>
                                        <==? ,SPELL? ,S-FANTASIZE>
                                        <PROB 20>>
                                       <TELL "There is a "
                                         <PICK-ONE ,FANTASIES>
                                         " here." CR>
                                       <SET 1ST? <>>)>
                                <RETURN>))
                                 (ELSE
                                  '(<NOT .Y>
                                <RETURN>))>
                              (<EQUAL? .Y .AV> <SET PV? T>)
                              (<EQUAL? .Y ,WINNER>)
                              (<AND <NOT <FSET? .Y ,INVISIBLE>>
                                <NOT <FSET? .Y ,TOUCHBIT>>
                                <SET STR <GETP .Y ,P?FDESC>>>
                               <COND (<NOT <FSET? .Y ,NDESCBIT>>
                                  <TELL .STR CR>
                                  <SET SHIT <>>
                                  ;<SET 1ST? <>>)>
                               <COND (<AND <SEE-INSIDE? .Y>
                                   <NOT <GETP <LOC .Y> ,P?DESCFCN>>
                                   <FIRST? .Y>>
                                  <COND (<PRINT-CONT .Y .V? 0>
                                     <SET 1ST? <>>)>)>)>
                        <SET Y <NEXT? .Y>>>)>
                 <SET Y <FIRST? .OBJ>>
                 <REPEAT ()
                     <COND (<NOT .Y>
                        <COND (<AND .PV? .AV <FIRST? .AV>>
                               <SET LEVEL <+ .LEVEL 1>> ;"not in Zork III"
                               <PRINT-CONT .AV .V? .LEVEL>)>
                        <RETURN>)
                           (<EQUAL? .Y .AV ,ADVENTURER>)
                           (<AND <NOT <FSET? .Y ,INVISIBLE>>
                             <OR .INV?
                             <FSET? .Y ,TOUCHBIT>
                             <NOT <GETP .Y ,P?FDESC>>>>
                        <COND (<NOT <FSET? .Y ,NDESCBIT>>
                               <COND (.1ST?
                                  <COND (<FIRSTER .OBJ .LEVEL>
                                     <COND (<L? .LEVEL 0>
                                        <SET LEVEL 0>)>)>
                                  <SET LEVEL <+ 1 .LEVEL>>
                                  <SET 1ST? <>>)>
                               <COND (<L? .LEVEL 0> <SET LEVEL 0>)>
                               <DESCRIBE-OBJECT .Y .V? .LEVEL>)
                              (<AND <FIRST? .Y> <SEE-INSIDE? .Y>>
                               <SET LEVEL <+ .LEVEL 1>> ;"not in Zork III"
                               <PRINT-CONT .Y .V? .LEVEL>
                               <SET LEVEL <- .LEVEL 1>> ;"not in Zork III")>)>
                     <SET Y <NEXT? .Y>>>
                 <COND (<AND .1ST? .SHIT> <RFALSE>) (T <RTRUE>)>>

            <ROUTINE DESCRIBE-OBJECT (OBJ V? LEVEL "AUX" (STR <>) AV)
                 <SETG DESC-OBJECT .OBJ>
                 <COND (<AND <0? .LEVEL>
                         <APPLY <GETP .OBJ ,P?DESCFCN> ,M-OBJDESC>>
                    <RTRUE>)
                       (<AND <0? .LEVEL>
                         <OR <AND <NOT <FSET? .OBJ ,TOUCHBIT>>
                              <SET STR <GETP .OBJ ,P?FDESC>>>
                         <SET STR <GETP .OBJ ,P?LDESC>>>>
                    <TELL .STR>)
                       (<0? .LEVEL>
                    <TELL "There is a " D .OBJ " here">
                    <COND (<FSET? .OBJ ,ONBIT>
                           <TELL " (providing light)">)>
                    <TELL ".">)
                       (T
                    <TELL <GET ,INDENTS .LEVEL>>
                    <TELL "A " D .OBJ>
                    <COND (<FSET? .OBJ ,ONBIT>
                           <TELL " (providing light)">)
                          (<AND <FSET? .OBJ ,WEARBIT>
                            <IN? .OBJ ,WINNER>>
                           <TELL " (being worn)">)>)>
                 %<COND (<==? ,ZORK-NUMBER 2>
                     '<COND (<AND <EQUAL? .OBJ ,SPELL-VICTIM>
                                  <EQUAL? ,SPELL-USED ,W?FLOAT>>
                             <TELL " (floating in midair)">)>)
                    (T
                     '<NULL-F>)>
                 <COND (<AND <0? .LEVEL>
                         <SET AV <LOC ,WINNER>>
                         <FSET? .AV ,VEHBIT>>
                    <TELL " (outside the " D .AV ")">)>
                 <CRLF>
                 <COND (<AND <SEE-INSIDE? .OBJ> <FIRST? .OBJ>>
                    <PRINT-CONT .OBJ .V? .LEVEL>)>>
        """)
    }

    func testDescribeObjectZork1() throws {
        sharedSetUp(for: .zork1)

        XCTAssertNoDifference(
            Game.routines.find("describeObject"),
            Statement(
                id: "describeObject",
                code: #"""
                    @discardableResult
                    /// The `describeObject` (DESCRIBE-OBJECT) routine.
                    func describeObject(
                        obj: Object,
                        isV: Bool,
                        level: Int
                    ) -> Bool {
                        var str: String? = nil
                        var av: Object? = nil
                        descObject.set(to: obj)
                        if _ = .and(
                            level.isZero,
                            obj.descriptionFunction(mObjdesc)
                        ) {
                            return true
                        } else if _ = .and(
                            level.isZero,
                            .or(
                                .and(
                                    .isNot(obj.hasFlag(.hasBeenTouched)),
                                    str.set(to: obj.firstDescription)
                                ),
                                str.set(to: obj.longDescription)
                            )
                        ) {
                            output(str)
                        } else if level.isZero {
                            output("There is a ")
                            output(obj.description)
                            output(" here")
                            if obj.hasFlag(.isOn) {
                                output(" (providing light)")
                            }
                            output(".")
                        } else {
                            output(try indents.get(at: level))
                            output("A ")
                            output(obj.description)
                            if obj.hasFlag(.isOn) {
                                output(" (providing light)")
                            } else if .and(
                                obj.hasFlag(.isWearable),
                                obj.isIn(winner)
                            ) {
                                output(" (being worn)")
                            }
                        }
                        nullFunc()
                        if .and(
                            level.isZero,
                            av.set(to: winner.parent),
                            av.hasFlag(.isVehicle)
                        ) {
                            output(" (outside the ")
                            output(av.description)
                            output(")")
                        }
                        output("\n")
                        if .and(
                            isSeeInside(obj: obj),
                            obj.firstChild
                        ) {
                            printCont(
                                obj: obj,
                                isV: isV,
                                level: level
                            )
                        }
                    }
                    """#,
                type: .booleanTrue,
                category: .routines,
                isCommittable: true,
                returnHandling: .passthrough
            )
        )
    }

    func testDescribeObjectZork2() throws {
        sharedSetUp(for: .zork2)

        XCTAssertNoDifference(
            Game.routines.find("describeObject"),
            Statement(
                id: "describeObject",
                code: #"""
                    @discardableResult
                    /// The `describeObject` (DESCRIBE-OBJECT) routine.
                    func describeObject(
                        obj: Object,
                        isV: Bool,
                        level: Int
                    ) -> Bool {
                        var str: String? = nil
                        var av: Object? = nil
                        descObject.set(to: obj)
                        if _ = .and(
                            level.isZero,
                            obj.descriptionFunction(mObjdesc)
                        ) {
                            return true
                        } else if _ = .and(
                            level.isZero,
                            .or(
                                .and(
                                    .isNot(obj.hasFlag(.hasBeenTouched)),
                                    str.set(to: obj.firstDescription)
                                ),
                                str.set(to: obj.longDescription)
                            )
                        ) {
                            output(str)
                        } else if level.isZero {
                            output("There is a ")
                            output(obj.description)
                            output(" here")
                            if obj.hasFlag(.isOn) {
                                output(" (providing light)")
                            }
                            output(".")
                        } else {
                            output(try indents.get(at: level))
                            output("A ")
                            output(obj.description)
                            if obj.hasFlag(.isOn) {
                                output(" (providing light)")
                            } else if .and(
                                obj.hasFlag(.isWearable),
                                obj.isIn(winner)
                            ) {
                                output(" (being worn)")
                            }
                        }
                        if .and(
                            obj.equals(spellVictim),
                            spellUsed.equals(Word.float)
                        ) {
                            output(" (floating in midair)")
                        }
                        if .and(
                            level.isZero,
                            av.set(to: winner.parent),
                            av.hasFlag(.isVehicle)
                        ) {
                            output(" (outside the ")
                            output(av.description)
                            output(")")
                        }
                        output("\n")
                        if .and(
                            isSeeInside(obj: obj),
                            obj.firstChild
                        ) {
                            printCont(
                                obj: obj,
                                isV: isV,
                                level: level
                            )
                        }
                    }
                    """#,
                type: .booleanTrue,
                category: .routines,
                isCommittable: true,
                returnHandling: .passthrough
            )
        )
    }

    func testPrintContZork1() throws {
        sharedSetUp(for: .zork1)

        XCTAssertNoDifference(
            Game.routines.find("printCont"),
            Statement(
                id: "printCont",
                code: """
                    @discardableResult
                    /// The `printCont` (PRINT-CONT) routine.
                    func printCont(
                        obj: Object,
                        isV: Bool = false,
                        level: Int = 0
                    ) -> Bool {
                        var y: Object? = nil
                        var is1St: Bool = false
                        var shit: Bool = false
                        var av: Object? = nil
                        var str: String = ""
                        var isPv: Bool = false
                        var isInv: Bool = false
                        var level: Int = 0
                        if .isNot(y.set(to: obj.firstChild)) {
                            return true
                        }
                        if _ = .and(
                            av.set(to: winner.parent),
                            av.hasFlag(.isVehicle)
                        ) {
                            return true
                        } else {
                            av.set(to: nil)
                        }
                        is1St.set(to: true)
                        shit.set(to: true)
                        if winner.equals(obj, obj.parent) {
                            isInv.set(to: true)
                        } else {
                            while true {
                                if .isNot(y) {
                                    break
                                } else if y.equals(av) {
                                    isPv.set(to: true)
                                } else if y.equals(winner) {
                                    // do nothing
                                } else if _ = .and(
                                    .isNot(y.hasFlag(.isInvisible)),
                                    .isNot(y.hasFlag(.hasBeenTouched)),
                                    str.set(to: y.firstDescription)
                                ) {
                                    if .isNot(y.hasFlag(.omitDescription)) {
                                        output(str)
                                        shit.set(to: false)
                                        // <SET 1ST? false>
                                    }
                                    if .and(
                                        isSeeInside(obj: y),
                                        .isNot(y.parent.descriptionFunction),
                                        y.firstChild
                                    ) {
                                        if printCont(
                                            obj: y,
                                            isV: isV,
                                            level: 0
                                        ) {
                                            is1St.set(to: false)
                                        }
                                    }
                                }
                                y.set(to: y.nextSibling)
                            }
                        }
                        y.set(to: obj.firstChild)
                        while true {
                            if .isNot(y) {
                                if _ = .and(
                                    isPv,
                                    av,
                                    av.firstChild
                                ) {
                                    level.set(to: .add(level, 1))
                                    // "not in Zork III"
                                    printCont(
                                        obj: av,
                                        isV: isV,
                                        level: level
                                    )
                                }
                                break
                            } else if y.equals(av, adventurer) {
                                // do nothing
                            } else if .and(
                                .isNot(y.hasFlag(.isInvisible)),
                                .or(
                                    isInv,
                                    y.hasFlag(.hasBeenTouched),
                                    .isNot(y.firstDescription)
                                )
                            ) {
                                if .isNot(y.hasFlag(.omitDescription)) {
                                    if is1St {
                                        if firster(
                                            obj: obj,
                                            level: level
                                        ) {
                                            if level.isLessThan(0) {
                                                level.set(to: 0)
                                            }
                                        }
                                        level.set(to: .add(1, level))
                                        is1St.set(to: false)
                                    }
                                    if level.isLessThan(0) {
                                        level.set(to: 0)
                                    }
                                    describeObject(
                                        obj: y,
                                        isV: isV,
                                        level: level
                                    )
                                } else if _ = .and(
                                    y.firstChild,
                                    isSeeInside(obj: y)
                                ) {
                                    level.set(to: .add(level, 1))
                                    // "not in Zork III"
                                    printCont(
                                        obj: y,
                                        isV: isV,
                                        level: level
                                    )
                                    level.set(to: .subtract(level, 1))
                                    // "not in Zork III"
                                }
                            }
                            y.set(to: y.nextSibling)
                        }
                        if .and(is1St, shit) {
                            return false
                        } else {
                            return true
                        }
                    }
                    """,
                type: .bool,
                category: .routines,
                isCommittable: true,
                returnHandling: .passthrough
            )
        )
    }

    func testPrintContZork2() throws {
        sharedSetUp(for: .zork2)

        XCTAssertNoDifference(
            Game.routines.find("printCont"),
            Statement(
                id: "printCont",
                code: """
                    @discardableResult
                    /// The `printCont` (PRINT-CONT) routine.
                    func printCont(
                        obj: Object,
                        isV: Bool = false,
                        level: Int = 0
                    ) -> Bool {
                        var y: Object? = nil
                        var is1St: Bool = false
                        var shit: Bool = false
                        var av: Object? = nil
                        var str: String = ""
                        var isPv: Bool = false
                        var isInv: Bool = false
                        var level: Int = 0
                        if .isNot(y.set(to: obj.firstChild)) {
                            return true
                        }
                        if _ = .and(
                            av.set(to: winner.parent),
                            av.hasFlag(.isVehicle)
                        ) {
                            return true
                        } else {
                            av.set(to: nil)
                        }
                        is1St.set(to: true)
                        shit.set(to: true)
                        if winner.equals(obj, obj.parent) {
                            isInv.set(to: true)
                        } else {
                            while true {
                                if .isNot(y) {
                                    if .and(
                                        level.isZero,
                                        isSpell.equals(sFantasize),
                                        prob(isBase: 20)
                                    ) {
                                        output("There is a ")
                                        output(pickOne(frob: fantasies))
                                        output(" here.")
                                        is1St.set(to: false)
                                    }
                                    break
                                } else if y.equals(av) {
                                    isPv.set(to: true)
                                } else if y.equals(winner) {
                                    // do nothing
                                } else if _ = .and(
                                    .isNot(y.hasFlag(.isInvisible)),
                                    .isNot(y.hasFlag(.hasBeenTouched)),
                                    str.set(to: y.firstDescription)
                                ) {
                                    if .isNot(y.hasFlag(.omitDescription)) {
                                        output(str)
                                        shit.set(to: false)
                                        // <SET 1ST? false>
                                    }
                                    if .and(
                                        isSeeInside(obj: y),
                                        .isNot(y.parent.descriptionFunction),
                                        y.firstChild
                                    ) {
                                        if printCont(
                                            obj: y,
                                            isV: isV,
                                            level: 0
                                        ) {
                                            is1St.set(to: false)
                                        }
                                    }
                                }
                                y.set(to: y.nextSibling)
                            }
                        }
                        y.set(to: obj.firstChild)
                        while true {
                            if .isNot(y) {
                                if _ = .and(
                                    isPv,
                                    av,
                                    av.firstChild
                                ) {
                                    level.set(to: .add(level, 1))
                                    // "not in Zork III"
                                    printCont(
                                        obj: av,
                                        isV: isV,
                                        level: level
                                    )
                                }
                                break
                            } else if y.equals(av, adventurer) {
                                // do nothing
                            } else if .and(
                                .isNot(y.hasFlag(.isInvisible)),
                                .or(
                                    isInv,
                                    y.hasFlag(.hasBeenTouched),
                                    .isNot(y.firstDescription)
                                )
                            ) {
                                if .isNot(y.hasFlag(.omitDescription)) {
                                    if is1St {
                                        if firster(
                                            obj: obj,
                                            level: level
                                        ) {
                                            if level.isLessThan(0) {
                                                level.set(to: 0)
                                            }
                                        }
                                        level.set(to: .add(1, level))
                                        is1St.set(to: false)
                                    }
                                    if level.isLessThan(0) {
                                        level.set(to: 0)
                                    }
                                    describeObject(
                                        obj: y,
                                        isV: isV,
                                        level: level
                                    )
                                } else if _ = .and(
                                    y.firstChild,
                                    isSeeInside(obj: y)
                                ) {
                                    level.set(to: .add(level, 1))
                                    // "not in Zork III"
                                    printCont(
                                        obj: y,
                                        isV: isV,
                                        level: level
                                    )
                                    level.set(to: .subtract(level, 1))
                                    // "not in Zork III"
                                }
                            }
                            y.set(to: y.nextSibling)
                        }
                        if .and(is1St, shit) {
                            return false
                        } else {
                            return true
                        }
                    }
                    """,
                type: .bool,
                category: .routines,
                isCommittable: true,
                returnHandling: .passthrough
            )
        )
    }
}
