////
////  MapFirst.swift
////  Quelbo
////
////  Created by Chris Sessions on 5/8/22.
////
//
//import CustomDump
//import Fizmo
//import XCTest
//@testable import quelbo
//
//final class MapFirstTests: QuelboTests {
//    let factory = Factories.MapFirst.self
//
//    func testFindFactory() throws {
//        AssertSameFactory(factory, Game.findFactory("MAPF"))
//    }
//
//    func testMapFirstZorkTell() throws {
//        let symbol = process("""
//            <DEFMAC TELL ("ARGS" A)
//                <FORM PROG ()
//                      !<MAPF ,LIST
//                         <FUNCTION ("AUX" E P O)
//                          <COND (<EMPTY? .A> <MAPSTOP>)
//                            (<SET E <NTH .A 1>>
//                             <SET A <REST .A>>)>
//                          <COND (<TYPE? .E ATOM>
//                             <COND (<OR <=? <SET P <SPNAME .E>>
//                                    "CRLF">
//                                    <=? .P "CR">>
//                                <MAPRET '<CRLF>>)
//                                   (<EMPTY? .A>
//                                <ERROR INDICATOR-AT-END? .E>)
//                                   (ELSE
//                                <SET O <NTH .A 1>>
//                                <SET A <REST .A>>
//                                <COND (<OR <=? <SET P <SPNAME .E>>
//                                           "DESC">
//                                       <=? .P "D">
//                                       <=? .P "OBJ">
//                                       <=? .P "O">>
//                                       <MAPRET <FORM PRINTD .O>>)
//                                      (<OR <=? .P "A">
//                                       <=? .P "AN">>
//                                       <MAPRET <FORM PRINTA .O>>)
//                                      (<OR <=? .P "NUM">
//                                       <=? .P "N">>
//                                       <MAPRET <FORM PRINTN .O>>)
//                                      (<OR <=? .P "CHAR">
//                                       <=? .P "CHR">
//                                       <=? .P "C">>
//                                       <MAPRET <FORM PRINTC .O>>)
//                                      (ELSE
//                                       <MAPRET
//                                     <FORM PRINT
//                                           <FORM GETP .O .E>>>)>)>)
//                            (<TYPE? .E STRING ZSTRING>
//                             <MAPRET <FORM PRINTI .E>>)
//                            (<TYPE? .E FORM LVAL GVAL>
//                             <MAPRET <FORM PRINT .E>>)
//                            (ELSE <ERROR UNKNOWN-TYPE .E>)>>>>>
//        """)
//
//        XCTAssertNoDifference(symbol, .statement(
//            id: "tell",
//            code: """
//            """,
//            type: .bool
//        ))
//    }
//
//    /*
//
//    // https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.vq8v1tpbcqxn
//    func testMapFirstVectorAdd() throws {
//        let symbol = process("""
//            <MAPF ,VECTOR ,+ (1 2 3) [10 11 12]>
//        """) // -> "[11 13 15]"
//
//        XCTAssertNoDifference(symbol, .statement(
//            code: """
//            [
//                .add(1, 10),
//                .add(2, 11),
//                .add(3, 12),
//            ]
//            """,
//            type: .array(.int)
//        ))
//    }
//
//    func testMapFirstStringFirst() throws {
//        let symbol = process("""
//            <MAPF ,STRING 1
//                ["Zil" "is" "lots of" "fun"]>
//        """) // -> "Zilf"
//
//        XCTAssertNoDifference(symbol, .statement(
//            code: """
//            [
//                "Zil".nthElement(1),
//                "is".nthElement(1),
//                "lots of".nthElement(1),
//                "fun".nthElement(1),
//            ].joined()
//            """,
//            type: .string
//        ))
//    }
//
//    func testMapFirstVectorAnonymousFunction() throws {
//        let symbol = process("""
//            <MAPF ,VECTOR
//                <FUNCTION (N) <* .N .N>> (1 2 3)>
//        """) // -> [1 4 9]
//
//        XCTAssertNoDifference(symbol, .statement(
//            code: """
//            [
//                { (n: Int) -> Int in
//                    var n: Int = n
//                    return n.multiply(n)
//                }(1),
//                { (n: Int) -> Int in
//                    var n: Int = n
//                    return n.multiply(n)
//                }(2),
//                { (n: Int) -> Int in
//                    var n: Int = n
//                    return n.multiply(n)
//                }(3),
//            ]
//            """,
//            type: .array(.int)
//        ))
//    }
//
//    // https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.243i4a2
//    func testFirstThree() throws {
//        process("""
//            <DEFINE FIRST-THREE (STRUC "AUX" (I 3))
//                <MAPF ,LIST
//                <FUNCTION (E)
//                    <COND (<0? <SET I <- .I 1>>> <MAPSTOP .E>)>
//                .E> .STRUC>>
//        """)
//
//        let symbol = process("""
//            <FIRST-THREE "ABCDEFG">
//        """)
//
//        XCTAssertNoDifference(symbol,
//            .statement(
//                code: """
//                    {
//                        var i: Int = 3
//                        return [
//                            { (e: <Unknown>) -> <Unknown> in
//                                if i.set(to: i.subtract(1)).isZero {
//                                    return e
//                                }
//                                return e
//                            }("ABCDEFG"),
//                        ]
//                    }()
//                    """,
//                type: .array(.unknown)
//            )
//        ) // -> #"["A", "B", "C"]"#
//    }
//     */
//}
