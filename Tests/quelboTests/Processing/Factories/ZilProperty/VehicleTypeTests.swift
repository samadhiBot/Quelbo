//
//  VehicleTypeTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/16/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class VehicleTypeTests: QuelboTests {
    let factory = Factories.VehicleType.self

    func testFindFactory() throws {
        AssertSameFactory(factory, try Game.zilPropertyFactories.find("VTYPE"))
    }

    func testVehicleType() throws {
        let symbol = try factory.init([
            .bool(true)
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "vehicleType",
            code: "vehicleType: true",
            type: .bool,
            children: [
                Symbol("true", type: .bool)
            ]
        ))
    }

    func testVehicleTypeDecimalNonZero() throws {
        let symbol = try factory.init([
            .decimal(1)
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "vehicleType",
            code: "vehicleType: true",
            type: .bool,
            children: [
                Symbol("true", type: .bool)
            ]
        ))
    }

    func testVehicleTypeDecimalZero() throws {
        let symbol = try factory.init([
            .decimal(0)
        ]).process()

        XCTAssertNoDifference(symbol, Symbol(
            id: "vehicleType",
            code: "vehicleType: false",
            type: .bool,
            children: [
                Symbol("false", type: .bool)
            ]
        ))
    }

    func testEmptyThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
            ]).process()
        )
    }

    func testMultipleThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .bool(true),
                .bool(false),
            ]).process()
        )
    }

    func testInvalidTypeThrows() throws {
        XCTAssertThrowsError(
            try factory.init([
                .string("10")
            ]).process()
        )
    }
}
