//
//  StatementPayloadTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/3/23.
//

import CustomDump
import XCTest
@testable import quelbo

final class StatementPayloadTests: QuelboTests {
    func testSignatureTypeBoolToOptionalRoutine() {
        XCTAssertNoDifference(
            Statement(
                id: "deadFunc",
                type: .void,
                payload: .init(
                    parameters: [
                        Instance(.init(type: .bool)),
                    ],
                    symbols: [
                        .instance(.init(type: .routine.optional)),
                    ]
                )
            ).signature,
            ".boolToOptionalRoutine(deadFunc)"
        )
    }

    func testSignatureTypeIntToBool() {
        XCTAssertNoDifference(
            Statement(
                id: "southTempleFunc",
                type: .void,
                payload: .init(
                    parameters: [
                        Instance(.init(type: .int)),
                    ],
                    symbols: [
                        .instance(.init(type: .bool)),
                    ]
                )
            ).signature,
            ".intToBool(southTempleFunc)"
        )
    }

    func testSignatureTypeIntToVoid() {
        XCTAssertNoDifference(
            Statement(
                id: "boomRoom",
                type: .void,
                payload: .init(
                    parameters: [
                        Instance(.init(type: .int)),
                    ]
                )
            ).signature,
            ".intToVoid(boomRoom)"
        )
    }

    func testSignatureTypeOptionalIntToBool() {
        XCTAssertNoDifference(
            Statement(
                id: "deepCanyonFunc",
                type: .void,
                payload: .init(
                    parameters: [
                        Instance(.init(type: .int.optional)),
                    ],
                    symbols: [
                        .instance(.init(type: .bool)),
                    ]
                )
            ).signature,
            ".optionalIntToBool(deepCanyonFunc)"
        )
    }

    func testSignatureTypeOptionalIntToVoid() {
        XCTAssertNoDifference(
            Statement(
                id: "eastHouse",
                type: .void,
                payload: .init(
                    parameters: [
                        Instance(.init(type: .int.optional)),
                    ]
                )
            ).signature,
            ".optionalIntToVoid(eastHouse)"
        )
    }

    func testSignatureTypeThrowingIntToVoid() {
        XCTAssertNoDifference(
            Statement(
                id: "cave2Room",
                type: .void,
                payload: .init(
                    parameters: [
                        Instance(.init(type: .int)),
                    ]
                ),
                isThrowing: true
            ).signature,
            ".throwingIntToVoid(cave2Room)"
        )
    }

    func testSignatureTypeThrowingOptionalIntToBool() {
        XCTAssertNoDifference(
            Statement(
                id: "robberFunc",
                type: .void,
                payload: .init(
                    parameters: [
                        Instance(.init(type: .int.optional)),
                    ],
                    symbols: [
                        .instance(.init(type: .bool)),
                    ]
                ),
                isThrowing: true
            ).signature,
            ".throwingOptionalIntToBool(robberFunc)"
        )
    }

    func testSignatureTypeThrowingOptionalIntToVoid() {
        XCTAssertNoDifference(
            Statement(
                id: "forestRoom",
                type: .void,
                payload: .init(
                    parameters: [
                        Instance(.init(type: .int.optional)),
                    ]
                ),
                isThrowing: true
            ).signature,
            ".throwingOptionalIntToVoid(forestRoom)"
        )
    }

    func testSignatureTypeThrowingVoidToBool() {
        XCTAssertNoDifference(
            Statement(
                id: "grateFunc",
                type: .void,
                payload: .init(
                    symbols: [
                        .instance(.init(type: .bool)),
                    ]
                ),
                isThrowing: true
            ).signature,
            ".throwingVoidToBool(grateFunc)"
        )
    }

    func testSignatureTypeThrowingVoidToVoid() {
        XCTAssertNoDifference(
            Statement(
                id: "hotBellFunc",
                type: .void,
                isThrowing: true
            ).signature,
            ".throwingVoidToVoid(hotBellFunc)"
        )
    }

    func testSignatureTypeVoidToBool() {
        XCTAssertNoDifference(
            Statement(
                id: "mirrorMirror",
                type: .void,
                payload: .init(
                    symbols: [
                        .instance(.init(type: .bool)),
                    ]
                )
            ).signature,
            ".voidToBool(mirrorMirror)"
        )
    }

    func testSignatureTypeVoidToRoutine() {
        XCTAssertNoDifference(
            Statement(
                id: "skeleton",
                type: .void,
                payload: .init(
                    symbols: [
                        .instance(.init(type: .routine)),
                    ]
                )
            ).signature,
            ".voidToRoutine(skeleton)"
        )
    }

    func testSignatureTypeVoidToVoid() {
        XCTAssertNoDifference(
            Statement(
                id: "bagOfCoinsFunc",
                type: .void
            ).signature,
            ".voidToVoid(bagOfCoinsFunc)"
        )
    }
}
