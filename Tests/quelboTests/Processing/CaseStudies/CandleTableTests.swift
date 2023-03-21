//
//  CandleTableTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/19/23.
//

import CustomDump
import XCTest
@testable import quelbo

final class CandleTableTests: QuelboTests {
    override func setUp() {
        super.setUp()

        GlobalObjectsTests().sharedSetUp()
        ZmemqTests().sharedSetUp()
        SearchListTests().sharedSetUp()
        DoSlTests().sharedSetUp()
        IsLitTests().sharedSetUp()
        IntTests().sharedSetUp()
        DescribeObjectTests().sharedSetUp()
        DescribeRoomTests().sharedSetUp()
        DescribeObjectsTests().sharedSetUp()
        IsYesTests().sharedSetup()
        FinishTests().sharedSetUp()
        JigsUpTests().sharedSetUp()
        VillainBlowTests().sharedSetUp()
        sharedSetUp()
    }

    func sharedSetUp() {
        process("""
            <GLOBAL CANDLE-TABLE
                <TABLE (PURE)
                       20
                       "The candles grow shorter."
                       10
                       "The candles are becoming quite short."
                       5
                       "The candles won't last long now."
                       0>>

            <OBJECT CANDLES
                (IN SOUTH-TEMPLE)
                (SYNONYM CANDLES PAIR)
                (ADJECTIVE BURNING)
                (DESC "pair of candles")
                (FLAGS TAKEBIT FLAMEBIT ONBIT LIGHTBIT)
                (ACTION CANDLES-FCN)
                (FDESC "On the two ends of the altar are burning candles.")
                (SIZE 10)>

            <ROUTINE HELD? (CAN)
                 <REPEAT ()
                     <SET CAN <LOC .CAN>>
                     <COND (<NOT .CAN> <RFALSE>)
                           (<EQUAL? .CAN ,WINNER> <RTRUE>)>>>

            <ROUTINE LIGHT-INT (OBJ TBL TICK)
                 <COND (<0? .TICK>
                    <FCLEAR .OBJ ,ONBIT>
                    <FSET .OBJ ,RMUNGBIT>)>
                 <COND (<OR <HELD? .OBJ> <IN? .OBJ ,HERE>>
                    <COND (<0? .TICK>
                           <TELL
            "You'd better have more light than from the " D .OBJ "." CR>)
                          (T
                           <TELL <GET .TBL 1> CR>)>)>>

            <ROUTINE I-CANDLES ("AUX" TICK (TBL <VALUE CANDLE-TABLE>))
                 <FSET ,CANDLES ,TOUCHBIT>
                 <ENABLE <QUEUE I-CANDLES <SET TICK <GET .TBL 0>>>>
                 <LIGHT-INT ,CANDLES .TBL .TICK>
                 <COND (<NOT <0? .TICK>>
                    <SETG CANDLE-TABLE <REST .TBL 4>>)>>
        """)
    }

    func testCandleTable() throws {
        XCTAssertNoDifference(
            Game.globals.find("candleTable"),
            Statement(
                id: "candleTable",
                code: """
                    var candleTable = Table(
                        .int(20),
                        .string("The candles grow shorter."),
                        .int(10),
                        .string("The candles are becoming quite short."),
                        .int(5),
                        .string("The candles won't last long now."),
                        .int(0),
                        flags: .pure
                    )
                    """,
                type: .table.root,
                category: .globals,
                isCommittable: true,
                isMutable: true,
                returnHandling: .implicit
            )
        )
    }

    func testCandles() throws {
        XCTAssertNoDifference(
            Game.objects.find("candles"),
            Statement(
                id: "candles",
                code: """
                    /// The `candles` (CANDLES) object.
                    var candles = Object(
                        id: "candles",
                        action: "candlesFunc",
                        adjectives: ["burning"],
                        description: "pair of candles",
                        firstDescription: "On the two ends of the altar are burning candles.",
                        flags: [.isFlammable, .isLight, .isOn, .isTakable],
                        location: "Rooms.southTemple",
                        size: 10,
                        synonyms: ["candles", "pair"]
                    )
                    """,
                type: .object.optional.tableElement,
                category: .objects,
                isCommittable: true
            )
        )
    }

    func testIsHeld() throws {
        XCTAssertNoDifference(
            Game.routines.find("isHeld"),
            Statement(
                id: "isHeld",
                code: """
                    @discardableResult
                    /// The `isHeld` (HELD?) routine.
                    func isHeld(can: Object) -> Bool {
                        var can = can
                        while true {
                            can.set(to: can.parent)
                            if .isNot(can) {
                                return false
                            } else if can.equals(Globals.winner) {
                                return true
                            }
                        }
                    }
                    """,
                type: .booleanTrue,
                category: .routines,
                isCommittable: true,
                returnHandling: .passthrough
            )
        )
    }

    func testLightInt() throws {
        XCTAssertNoDifference(
            Game.routines.find("lightInt"),
            Statement(
                id: "lightInt",
                code: """
                    /// The `lightInt` (LIGHT-INT) routine.
                    func lightInt(obj: Object, tbl: Table, tick: Int) throws {
                        if tick.isZero {
                            obj.isOn.set(false)
                            obj.isDestroyed.set(true)
                        }
                        if .or(isHeld(can: obj), obj.isIn(Globals.here)) {
                            if tick.isZero {
                                output("You'd better have more light than from the ")
                                output(obj.description)
                                output(".")
                            } else {
                                output(try tbl.get(at: 1))
                            }
                        }
                    }
                    """,
                type: .void,
                category: .routines,
                isCommittable: true,
                isThrowing: true,
                returnHandling: .passthrough
            )
        )
    }

    func testICandles() throws {
        XCTAssertNoDifference(
            Game.routines.find("iCandles"),
            Statement(
                id: "iCandles",
                code: """
                    /// The `iCandles` (I-CANDLES) routine.
                    func iCandles() throws {
                        var tick = 0
                        var tbl = Globals.candleTable
                        Objects.candles.hasBeenTouched.set(true)
                        try enable(
                            int: try queue(
                                rtn: iCandles,
                                tick: tick.set(to: try tbl.get(at: 0))
                            )
                        )
                        try lightInt(obj: Objects.candles, tbl: tbl, tick: tick)
                        if .isNot(tick.isZero) {
                            Globals.candleTable.set(to: tbl.rest(bytes: 4))
                        }
                    }
                    """,
                type: .void,
                category: .routines,
                isCommittable: true,
                isThrowing: true,
                returnHandling: .passthrough
            )
        )
    }
}
