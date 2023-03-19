//
//  ClauseTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 1/22/23.
//

import CustomDump
import XCTest
@testable import quelbo

final class ClauseTests: QuelboTests {
    override func setUp() {
        super.setUp()

        GlobalObjectsTests().sharedSetUp()
        ZmemqTests().sharedSetUp()
        SearchListTests().sharedSetUp()
        DoSlTests().sharedSetUp()
        GlobalCheckTests().sharedSetUp()
        OrphanTests().sharedSetUp()
        IsAccessibleTests().sharedSetUp()
        BufferPrintTests().sharedSetUp()
        WhichPrintTests().sharedSetUp()
        GetObjectTests().sharedSetUp()
        sharedSetUp()
    }

    func sharedSetUp() {
        process(#"""
            <CONSTANT O-PTR 0>    "word pointer to unknown token in P-LEXV"
            <CONSTANT P-LEXELEN 2>
            <CONSTANT P-PREP1 2>
            <CONSTANT P-VERB 0>
            <CONSTANT P-VERBN 1>

            <GLOBAL OOPS-TABLE <TABLE <> <> <> <>>>
            <GLOBAL P-ITBL <TABLE 0 0 0 0 0 0 0 0 0 0>>
            <GLOBAL P-LEN 0>
            <GLOBAL P-LEXV <ITABLE 59 (LEXV) 0 #BYTE 0 #BYTE 0> ;<ITABLE BYTE 120>>
            <GLOBAL P-NCN 0>

            <ROUTINE CANT-USE (PTR "AUX" BUF)
                <COND (<VERB? SAY>
                       <TELL "Nothing happens." CR>
                       <RFALSE>)>
                <TELL "You used the word \"">
                <WORD-PRINT <GETB <REST ,P-LEXV <SET BUF <* .PTR 2>>> 2>
                        <GETB <REST ,P-LEXV .BUF> 3>>
                <TELL "\" in a way that I don't understand." CR>
                <SETG QUOTE-FLAG <>>
                <SETG P-OFLAG <>>>

            <ROUTINE NUMBER? (PTR "AUX" CNT BPTR CHR (SUM 0) (TIM <>))
                 <SET CNT <GETB <REST ,P-LEXV <* .PTR 2>> 2>>
                 <SET BPTR <GETB <REST ,P-LEXV <* .PTR 2>> 3>>
                 <REPEAT ()
                     <COND (<L? <SET CNT <- .CNT 1>> 0> <RETURN>)
                           (T
                        <SET CHR <GETB ,P-INBUF .BPTR>>
                        <COND (<EQUAL? .CHR 58>
                               <SET TIM .SUM>
                               <SET SUM 0>)
                              (<G? .SUM 10000> <RFALSE>)
                              (<AND <L? .CHR 58> <G? .CHR 47>>
                               <SET SUM <+ <* .SUM 10> <- .CHR 48>>>)
                              (T <RFALSE>)>
                        <SET BPTR <+ .BPTR 1>>)>>
                 <PUT ,P-LEXV .PTR ,W?INTNUM>
                 <COND (<G? .SUM 1000> <RFALSE>)
                       (.TIM
                    <COND (<L? .TIM 8> <SET TIM <+ .TIM 12>>)
                          (<G? .TIM 23> <RFALSE>)>
                    <SET SUM <+ .SUM <* .TIM 60>>>)>
                 <SETG P-NUMBER .SUM>
                 ,W?INTNUM>

            <ROUTINE UNKNOWN-WORD (PTR "AUX" BUF)
                <PUT ,OOPS-TABLE ,O-PTR .PTR>
                <COND (<VERB? SAY>
                       <TELL "Nothing happens." CR>
                       <RFALSE>)>
                <TELL "I don't know the word \"">
                <WORD-PRINT <GETB <REST ,P-LEXV <SET BUF <* .PTR 2>>> 2>
                        <GETB <REST ,P-LEXV .BUF> 3>>
                <TELL "\"." CR>
                <SETG QUOTE-FLAG <>>
                <SETG P-OFLAG <>>>

            <ROUTINE CLAUSE (PTR VAL WRD "AUX" OFF NUM (ANDFLG <>) (FIRST?? T) NW (LW 0))
                <SET OFF <* <- ,P-NCN 1> 2>>
                <COND (<NOT <EQUAL? .VAL 0>>
                       <PUT ,P-ITBL <SET NUM <+ ,P-PREP1 .OFF>> .VAL>
                       <PUT ,P-ITBL <+ .NUM 1> .WRD>
                       <SET PTR <+ .PTR ,P-LEXELEN>>)
                      (T <SETG P-LEN <+ ,P-LEN 1>>)>
                <COND (<ZERO? ,P-LEN> <SETG P-NCN <- ,P-NCN 1>> <RETURN -1>)>
                <PUT ,P-ITBL <SET NUM <+ ,P-NC1 .OFF>> <REST ,P-LEXV <* .PTR 2>>>
                <COND (<EQUAL? <GET ,P-LEXV .PTR> ,W?THE ,W?A ,W?AN>
                       <PUT ,P-ITBL .NUM <REST <GET ,P-ITBL .NUM> 4>>)>
                <REPEAT ()
                    <COND (<L? <SETG P-LEN <- ,P-LEN 1>> 0>
                           <PUT ,P-ITBL <+ .NUM 1> <REST ,P-LEXV <* .PTR 2>>>
                           <RETURN -1>)>
                    <COND (<OR <SET WRD <GET ,P-LEXV .PTR>>
                           <SET WRD <NUMBER? .PTR>>>
                           <COND (<ZERO? ,P-LEN> <SET NW 0>)
                             (T <SET NW <GET ,P-LEXV <+ .PTR ,P-LEXELEN>>>)>
                           <COND (<EQUAL? .WRD ,W?AND ,W?COMMA> <SET ANDFLG T>)
                             (<EQUAL? .WRD ,W?ALL ,W?ONE ;,W?BOTH>
                              <COND (<EQUAL? .NW ,W?OF>
                                 <SETG P-LEN <- ,P-LEN 1>>
                                 <SET PTR <+ .PTR ,P-LEXELEN>>)>)
                             (<OR <EQUAL? .WRD ,W?THEN ,W?PERIOD>
                              <AND <WT? .WRD ,PS?PREPOSITION>
                                   <GET ,P-ITBL ,P-VERB>
                                      ;"ADDED 4/27 FOR TURTLE,UP"
                                   <NOT .FIRST??>>>
                              <SETG P-LEN <+ ,P-LEN 1>>
                              <PUT ,P-ITBL
                               <+ .NUM 1>
                               <REST ,P-LEXV <* .PTR 2>>>
                              <RETURN <- .PTR ,P-LEXELEN>>)
                             (<WT? .WRD ,PS?OBJECT>
                              <COND (<AND <G? ,P-LEN 0>
                                  <EQUAL? .NW ,W?OF>
                                  <NOT <EQUAL? .WRD ,W?ALL ,W?ONE>>>
                                 T)
                                (<AND <WT? .WRD
                                       ,PS?ADJECTIVE
                                       ,P1?ADJECTIVE>
                                  <NOT <EQUAL? .NW 0>>
                                  <WT? .NW ,PS?OBJECT>>)
                                (<AND <NOT .ANDFLG>
                                  <NOT <EQUAL? .NW ,W?BUT ,W?EXCEPT>>
                                  <NOT <EQUAL? .NW ,W?AND ,W?COMMA>>>
                                 <PUT ,P-ITBL
                                  <+ .NUM 1>
                                  <REST ,P-LEXV <* <+ .PTR 2> 2>>>
                                 <RETURN .PTR>)
                                (T <SET ANDFLG <>>)>)
                             (<AND <OR ,P-MERGED
                                   ,P-OFLAG
                                   <NOT <EQUAL? <GET ,P-ITBL ,P-VERB> 0>>>
                               <OR <WT? .WRD ,PS?ADJECTIVE>
                                   <WT? .WRD ,PS?BUZZ-WORD>>>)
                             (<AND .ANDFLG
                               <OR <WT? .WRD ,PS?DIRECTION>
                                   <WT? .WRD ,PS?VERB>>>
                              <SET PTR <- .PTR 4>>
                              <PUT ,P-LEXV <+ .PTR 2> ,W?THEN>
                              <SETG P-LEN <+ ,P-LEN 2>>)
                             (<WT? .WRD ,PS?PREPOSITION> T)
                             (T
                              <CANT-USE .PTR>
                              <RFALSE>)>)
                          (T <UNKNOWN-WORD .PTR> <RFALSE>)>
                    <SET LW .WRD>
                    <SET FIRST?? <>>
                    <SET PTR <+ .PTR ,P-LEXELEN>>>>
        """#)
    }

    func testCantUse() throws {
        XCTAssertNoDifference(
            Game.routines.find("cantUse"),
            Statement(
                id: "cantUse",
                code: #"""
                    @discardableResult
                    /// The `cantUse` (CANT-USE) routine.
                    func cantUse(ptr: Int) -> Bool {
                        var buf = 0
                        if isParsedVerb(.say) {
                            output("Nothing happens.")
                            return false
                        }
                        output("You used the word \"")
                        wordPrint(
                            cnt: try Globals.pLexv.rest(bytes: buf.set(to: .multiply(ptr, 2))).get(at: 2),
                            buf: try Globals.pLexv.rest(bytes: buf).get(at: 3)
                        )
                        output("\" in a way that I don't understand.")
                        quoteFlag.set(to: false)
                        Globals.pOflag.set(to: false)
                    }
                    """#,
                type: .booleanFalse,
                category: .routines,
                isCommittable: true,
                returnHandling: .passthrough
            )
        )
    }

    func testIsNumber() throws {
        XCTAssertNoDifference(
            Game.routines.find("isNumber"),
            Statement(
                id: "isNumber",
                code: """
                    @discardableResult
                    /// The `isNumber` (NUMBER?) routine.
                    func isNumber(ptr: Int) -> Word? {
                        var cnt = 0
                        var bptr = 0
                        var chr = 0
                        var sum: Int? = 0
                        var tim: Int? = 0
                        cnt.set(to: try Globals.pLexv.rest(bytes: .multiply(ptr, 2)).get(at: 2))
                        bptr.set(to: try Globals.pLexv.rest(bytes: .multiply(ptr, 2)).get(at: 3))
                        while true {
                            if cnt.set(to: .subtract(cnt, 1)).isLessThan(0) {
                                break
                            } else {
                                chr.set(to: try Globals.pInbuf.get(at: bptr))
                                if chr.equals(58) {
                                    tim.set(to: sum)
                                    sum.set(to: 0)
                                } else if sum.isGreaterThan(10000) {
                                    return nil
                                } else if .and(chr.isLessThan(58), chr.isGreaterThan(47)) {
                                    sum.set(to: .add(.multiply(sum, 10), .subtract(chr, 48)))
                                } else {
                                    return nil
                                }
                                bptr.set(to: .add(bptr, 1))
                            }
                        }
                        try Globals.pLexv.put(
                            element: Word.intnum,
                            at: ptr
                        )
                        if sum.isGreaterThan(1000) {
                            return nil
                        } else if let tim {
                            if tim.isLessThan(8) {
                                tim.set(to: .add(tim, 12))
                            } else if tim.isGreaterThan(23) {
                                return nil
                            }
                            sum.set(to: .add(sum, .multiply(tim, 60)))
                        }
                        Globals.pNumber.set(to: sum)
                        return Word.intnum
                    }
                    """,
                type: .word.optional.tableElement,
                category: .routines,
                isCommittable: true,
                returnHandling: .passthrough
            )
        )
    }

    func testUnknownWord() throws {
        XCTAssertNoDifference(
            Game.routines.find("unknownWord"),
            Statement(
                id: "unknownWord",
                code: #"""
                    @discardableResult
                    /// The `unknownWord` (UNKNOWN-WORD) routine.
                    func unknownWord(ptr: Int) -> Bool {
                        var buf = 0
                        try Globals.oopsTable.put(
                            element: ptr,
                            at: Constants.oPtr
                        )
                        if isParsedVerb(.say) {
                            output("Nothing happens.")
                            return false
                        }
                        output("I don't know the word \"")
                        wordPrint(
                            cnt: try Globals.pLexv.rest(bytes: buf.set(to: .multiply(ptr, 2))).get(at: 2),
                            buf: try Globals.pLexv.rest(bytes: buf).get(at: 3)
                        )
                        output("\".")
                        quoteFlag.set(to: false)
                        Globals.pOflag.set(to: false)
                    }
                    """#,
                type: .booleanFalse,
                category: .routines,
                isCommittable: true,
                returnHandling: .passthrough
            )
        )
    }

    func testClause() throws {
        XCTAssertNoDifference(
            Game.routines.find("clause"),
            Statement(
                id: "clause",
                code: """
                    @discardableResult
                    /// The `clause` (CLAUSE) routine.
                    func clause(ptr: Int, val: Int, wrd: Word) -> Int? {
                        var off = 0
                        var num = 0
                        var andflg = false
                        var isFirst = true
                        var nw: Word?
                        var lw: Word?
                        var ptr = ptr
                        var wrd = wrd
                        off.set(to: .multiply(.subtract(Globals.pNcn, 1), 2))
                        if .isNot(val.equals(0)) {
                            try Globals.pItbl.put(
                                element: val,
                                at: num.set(to: .add(Constants.pPrep1, off))
                            )
                            try Globals.pItbl.put(
                                element: wrd,
                                at: .add(num, 1)
                            )
                            ptr.set(to: .add(ptr, Constants.pLexelen))
                        } else {
                            Globals.pLen.set(to: .add(Globals.pLen, 1))
                        }
                        if Globals.pLen.isZero {
                            Globals.pNcn.set(to: .subtract(Globals.pNcn, 1))
                            return -1
                        }
                        try Globals.pItbl.put(
                            element: Globals.pLexv.rest(bytes: .multiply(ptr, 2)),
                            at: num.set(to: .add(Constants.pNc1, off))
                        )
                        if try Globals.pLexv.get(at: ptr).equals(Word.the, Word.a, Word.an) {
                            try Globals.pItbl.put(
                                element: try Globals.pItbl.get(at: num).rest(bytes: 4),
                                at: num
                            )
                        }
                        while true {
                            if Globals.pLen.set(to: .subtract(Globals.pLen, 1)).isLessThan(0) {
                                try Globals.pItbl.put(
                                    element: Globals.pLexv.rest(bytes: .multiply(ptr, 2)),
                                    at: .add(num, 1)
                                )
                                return -1
                            }
                            if _ = .or(
                                wrd.set(to: try Globals.pLexv.get(at: ptr)),
                                wrd.set(to: isNumber(ptr: ptr))
                            ) {
                                if Globals.pLen.isZero {
                                    nw.set(to: nil)
                                } else {
                                    nw.set(to: try Globals.pLexv.get(at: .add(ptr, Constants.pLexelen)))
                                }
                                if wrd.equals(Word.and, Word.comma) {
                                    andflg.set(to: true)
                                } else if wrd.equals(Word.all, Word.one) {
                                    if nw.equals(Word.of) {
                                        Globals.pLen.set(to: .subtract(Globals.pLen, 1))
                                        ptr.set(to: .add(ptr, Constants.pLexelen))
                                    }
                                } else if .or(
                                    wrd.equals(Word.then, Word.period),
                                    .and(
                                        isWt(ptr: wrd, bit: PartsOfSpeech.preposition),
                                        try Globals.pItbl.get(at: Constants.pVerb),
                                        .isNot(isFirst)
                                    )
                                ) {
                                    Globals.pLen.set(to: .add(Globals.pLen, 1))
                                    try Globals.pItbl.put(
                                        element: Globals.pLexv.rest(bytes: .multiply(ptr, 2)),
                                        at: .add(num, 1)
                                    )
                                    return .subtract(ptr, Constants.pLexelen)
                                } else if isWt(ptr: wrd, bit: PartsOfSpeech.object) {
                                    if .and(
                                        Globals.pLen.isGreaterThan(0),
                                        nw.equals(Word.of),
                                        .isNot(wrd.equals(Word.all, Word.one))
                                    ) {
                                        return 1
                                    } else if .and(
                                        isWt(
                                            ptr: wrd,
                                            bit: PartsOfSpeech.adjective,
                                            b1: PartsOfSpeech.adjectiveFirst
                                        ),
                                        .isNot(nw.equals(nil)),
                                        isWt(ptr: nw, bit: PartsOfSpeech.object)
                                    ) {
                                        // do nothing
                                    } else if .and(
                                        .isNot(andflg),
                                        .isNot(nw.equals(Word.but, Word.except)),
                                        .isNot(nw.equals(Word.and, Word.comma))
                                    ) {
                                        try Globals.pItbl.put(
                                            element: Globals.pLexv.rest(bytes: .multiply(.add(ptr, 2), 2)),
                                            at: .add(num, 1)
                                        )
                                        return ptr
                                    } else {
                                        andflg.set(to: false)
                                    }
                                } else if .and(
                                    .or(
                                        Globals.pMerged,
                                        Globals.pOflag,
                                        .isNot(try Globals.pItbl.get(at: Constants.pVerb).equals(0))
                                    ),
                                    .or(
                                        isWt(ptr: wrd, bit: PartsOfSpeech.adjective),
                                        isWt(ptr: wrd, bit: PartsOfSpeech.buzzWord)
                                    )
                                ) {
                                    // do nothing
                                } else if .and(
                                    andflg,
                                    .or(
                                        isWt(ptr: wrd, bit: PartsOfSpeech.direction),
                                        isWt(ptr: wrd, bit: PartsOfSpeech.verb)
                                    )
                                ) {
                                    ptr.set(to: .subtract(ptr, 4))
                                    try Globals.pLexv.put(
                                        element: Word.then,
                                        at: .add(ptr, 2)
                                    )
                                    Globals.pLen.set(to: .add(Globals.pLen, 2))
                                } else if isWt(ptr: wrd, bit: PartsOfSpeech.preposition) {
                                    return 1
                                } else {
                                    cantUse(ptr: ptr)
                                    return nil
                                }
                            } else {
                                unknownWord(ptr: ptr)
                                return nil
                            }
                            lw.set(to: wrd)
                            isFirst.set(to: false)
                            ptr.set(to: .add(ptr, Constants.pLexelen))
                        }
                    }
                    """,
                type: .int.optional.tableElement,
                category: .routines,
                isCommittable: true,
                returnHandling: .passthrough
            )
        )
    }
}
