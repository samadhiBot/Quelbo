//
//  DescribeRoomTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 11/3/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class DescribeRoomTests: QuelboTests {
    override func setUp() {
        super.setUp()

        GlobalObjectsTests().sharedSetUp()
    }

    func sharedSetUp(for zorkNumber: ZorkNumber = .zork1) {
        var versionSpecificDefs: String {
            switch zorkNumber {
            case .zork1: return ""
            case .zork2: return """
                    <ROOM ZORK3>
                """
            case .zork3: return """
                    <ROOM DARK-2>
                """
            }
        }

        process("""
            <SETG ZORK-NUMBER \(zorkNumber.rawValue)>

            \(versionSpecificDefs)

            <CONSTANT M-FLASH 4>
            <CONSTANT M-LOOK 3>

            <GLOBAL HERE 0>
            <GLOBAL LIT <>>
            <GLOBAL SPRAYED? <>>
            <GLOBAL SUPER-BRIEF <>>
            <GLOBAL VERBOSE <>>
            <GLOBAL WINNER 0>

            <OBJECT ROOMS (IN TO ROOMS)>

            <ROUTINE NULL-F ("OPTIONAL" A1 A2) <RFALSE>>

            <ROUTINE DESCRIBE-ROOM ("OPTIONAL" (LOOK? <>) "AUX" V? STR AV)
                 <SET V? <OR .LOOK? ,VERBOSE>>
                 <COND (<NOT ,LIT>
                    <TELL "It is pitch black.">
                    <COND (<NOT ,SPRAYED?>
                           <TELL " You are likely to be eaten by a grue.">)>
                    <CRLF>
                    %<COND (<==? ,ZORK-NUMBER 3>
                        '<COND (<EQUAL? ,HERE ,DARK-2>
                                    <TELL
            "The ground continues to slope upwards away from the lake. You can barely
            detect a dim light from the east." CR>)>)
                           (T
                        '<NULL-F>)>
                    <RFALSE>)>
                 <COND (<NOT <FSET? ,HERE ,TOUCHBIT>>
                    <FSET ,HERE ,TOUCHBIT>
                    <SET V? T>)>
                 %<COND (<==? ,ZORK-NUMBER 1>
                     '<COND (<FSET? ,HERE ,MAZEBIT>
                             <FCLEAR ,HERE ,TOUCHBIT>)>)
                    (T
                     '<NULL-F>)>
                 <COND (<IN? ,HERE ,ROOMS>
                    ;"Was <TELL D ,HERE CR>"
                    <TELL D ,HERE>
                    <COND (<FSET? <SET AV <LOC ,WINNER>> ,VEHBIT>
                           <TELL ", in the " D .AV>)>
                    <CRLF>)>
                 <COND (%<COND (<==? ,ZORK-NUMBER 2>
                        '<OR .LOOK? <NOT ,SUPER-BRIEF> <EQUAL? ,HERE ,ZORK3>>)
                           (ELSE
                        '<OR .LOOK? <NOT ,SUPER-BRIEF>>)>
                    <SET AV <LOC ,WINNER>>
                    ;<COND (<FSET? .AV ,VEHBIT>
                           <TELL "(You are in the " D .AV ".)" CR>)>
                    <COND (<AND .V? <APPLY <GETP ,HERE ,P?ACTION> ,M-LOOK>>
                           <RTRUE>)
                          (<AND .V? <SET STR <GETP ,HERE ,P?LDESC>>>
                           <TELL .STR CR>)
                          (T
                           <APPLY <GETP ,HERE ,P?ACTION> ,M-FLASH>)>
                    <COND (<AND <NOT <EQUAL? ,HERE .AV>> <FSET? .AV ,VEHBIT>>
                           <APPLY <GETP .AV ,P?ACTION> ,M-LOOK>)>)>
                 T>
        """)
    }

    func testDescribeRoomZork1() throws {
        sharedSetUp(for: .zork1)

        XCTAssertNoDifference(
            Game.routines.find("describeRoom"),
            Statement(
                id: "describeRoom",
                code: #"""
                    @discardableResult
                    /// The `describeRoom` (DESCRIBE-ROOM) routine.
                    func describeRoom(isLook: Bool = false) -> Bool {
                        var isV = false
                        var str = ""
                        var av: Object?
                        isV.set(to: .or(isLook, Global.verbose))
                        if .isNot(Global.lit) {
                            output("It is pitch black.")
                            if .isNot(Global.isSprayed) {
                                output(" You are likely to be eaten by a grue.")
                            }
                            output("\n")
                            nullFunc()
                            return false
                        }
                        if .isNot(Global.here.hasFlag(.hasBeenTouched)) {
                            Global.here.hasBeenTouched.set(true)
                            isV.set(to: true)
                        }
                        if Global.here.hasFlag(.isMaze) {
                            Global.here.hasBeenTouched.set(false)
                        }
                        if Global.here.isIn(Object.rooms) {
                            // "Was <TELL D ,HERE CR>"
                            output(Global.here.description)
                            if av.set(to: Global.winner.parent).hasFlag(.isVehicle) {
                                output(", in the ")
                                output(av.description)
                            }
                            output("\n")
                        }
                        if .or(isLook, .isNot(Global.superBrief)) {
                            av.set(to: Global.winner.parent)
                            // <COND (<FSET? .AV ,VEHBIT> <TELL "(You are in the " D .AV ".)" CR>)>
                            if _ = .and(isV, Global.here.action(Constant.mLook)) {
                                return true
                            } else if _ = .and(
                                isV,
                                str.set(to: Global.here.longDescription)
                            ) {
                                output(str)
                            } else {
                                Global.here.action(Constant.mFlash)
                            }
                            if .and(
                                .isNot(Global.here.equals(av)),
                                av.hasFlag(.isVehicle)
                            ) {
                                av.action(Constant.mLook)
                            }
                        }
                        return true
                    }
                    """#,
                type: .booleanTrue,
                category: .routines,
                isCommittable: true,
                returnHandling: .passthrough
            )
        )
    }

    func testDescribeRoomZork2() throws {
        sharedSetUp(for: .zork2)

        XCTAssertNoDifference(
            Game.routines.find("describeRoom"),
            Statement(
                id: "describeRoom",
                code: #"""
                    @discardableResult
                    /// The `describeRoom` (DESCRIBE-ROOM) routine.
                    func describeRoom(isLook: Bool = false) -> Bool {
                        var isV = false
                        var str = ""
                        var av: Object?
                        isV.set(to: .or(isLook, Global.verbose))
                        if .isNot(Global.lit) {
                            output("It is pitch black.")
                            if .isNot(Global.isSprayed) {
                                output(" You are likely to be eaten by a grue.")
                            }
                            output("\n")
                            nullFunc()
                            return false
                        }
                        if .isNot(Global.here.hasFlag(.hasBeenTouched)) {
                            Global.here.hasBeenTouched.set(true)
                            isV.set(to: true)
                        }
                        nullFunc()
                        if Global.here.isIn(Object.rooms) {
                            // "Was <TELL D ,HERE CR>"
                            output(Global.here.description)
                            if av.set(to: Global.winner.parent).hasFlag(.isVehicle) {
                                output(", in the ")
                                output(av.description)
                            }
                            output("\n")
                        }
                        if .or(
                            isLook,
                            .isNot(Global.superBrief),
                            Global.here.equals(Room.zork3)
                        ) {
                            av.set(to: Global.winner.parent)
                            // <COND (<FSET? .AV ,VEHBIT> <TELL "(You are in the " D .AV ".)" CR>)>
                            if _ = .and(isV, Global.here.action(Constant.mLook)) {
                                return true
                            } else if _ = .and(
                                isV,
                                str.set(to: Global.here.longDescription)
                            ) {
                                output(str)
                            } else {
                                Global.here.action(Constant.mFlash)
                            }
                            if .and(
                                .isNot(Global.here.equals(av)),
                                av.hasFlag(.isVehicle)
                            ) {
                                av.action(Constant.mLook)
                            }
                        }
                        return true
                    }
                    """#,
                type: .booleanTrue,
                category: .routines,
                isCommittable: true,
                returnHandling: .passthrough
            )
        )
    }

    func testDescribeRoomZork3() throws {
        sharedSetUp(for: .zork3)

        XCTAssertNoDifference(
            Game.routines.find("describeRoom"),
            Statement(
                id: "describeRoom",
                code: #"""
                    @discardableResult
                    /// The `describeRoom` (DESCRIBE-ROOM) routine.
                    func describeRoom(isLook: Bool = false) -> Bool {
                        var isV = false
                        var str = ""
                        var av: Object?
                        isV.set(to: .or(isLook, Global.verbose))
                        if .isNot(Global.lit) {
                            output("It is pitch black.")
                            if .isNot(Global.isSprayed) {
                                output(" You are likely to be eaten by a grue.")
                            }
                            output("\n")
                            if Global.here.equals(Room.dark2) {
                                output("""
                                    The ground continues to slope upwards away from the lake. \
                                    You can barely detect a dim light from the east.
                                    """)
                            }
                            return false
                        }
                        if .isNot(Global.here.hasFlag(.hasBeenTouched)) {
                            Global.here.hasBeenTouched.set(true)
                            isV.set(to: true)
                        }
                        nullFunc()
                        if Global.here.isIn(Object.rooms) {
                            // "Was <TELL D ,HERE CR>"
                            output(Global.here.description)
                            if av.set(to: Global.winner.parent).hasFlag(.isVehicle) {
                                output(", in the ")
                                output(av.description)
                            }
                            output("\n")
                        }
                        if .or(isLook, .isNot(Global.superBrief)) {
                            av.set(to: Global.winner.parent)
                            // <COND (<FSET? .AV ,VEHBIT> <TELL "(You are in the " D .AV ".)" CR>)>
                            if _ = .and(isV, Global.here.action(Constant.mLook)) {
                                return true
                            } else if _ = .and(
                                isV,
                                str.set(to: Global.here.longDescription)
                            ) {
                                output(str)
                            } else {
                                Global.here.action(Constant.mFlash)
                            }
                            if .and(
                                .isNot(Global.here.equals(av)),
                                av.hasFlag(.isVehicle)
                            ) {
                                av.action(Constant.mLook)
                            }
                        }
                        return true
                    }
                    """#,
                type: .booleanTrue,
                category: .routines,
                isCommittable: true,
                returnHandling: .passthrough
            )
        )
    }
}
