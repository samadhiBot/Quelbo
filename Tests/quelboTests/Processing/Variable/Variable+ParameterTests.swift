//
//  Variable+ParameterTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/10/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class VariableParameterTests: XCTestCase {
    func testAtomSTRCLS() throws {
        let param = try Variable.Parameter(.atom("STRCLS"), .normal)
        XCTAssertNoDifference(param, .init(
            name: "closeText",
            type: "String",
            defaultValue: "",
            context: .normal
        ))
        XCTAssertNoDifference(param.definition, "closeText: String")
    }

    func testAtomOBJ() throws {
        let param = try Variable.Parameter(.atom("OBJ"), .normal)
        XCTAssertNoDifference(param, .init(
            name: "object",
            type: "Object",
            defaultValue: "",
            context: .normal
        ))
        XCTAssertNoDifference(param.definition, "object: Object")
    }

    func testAtomSTROPN() throws {
        let param = try Variable.Parameter(.atom("STROPN"), .normal)
        XCTAssertNoDifference(param, .init(
            name: "openText",
            type: "String",
            defaultValue: "",
            context: .normal
        ))
        XCTAssertNoDifference(param.definition, "openText: String")
    }

    func testAtomRARG() throws {
        let param = try Variable.Parameter(.atom("RARG"), .normal)
        XCTAssertNoDifference(param, .init(
            name: "rarg",
            type: "RoomArg",
            defaultValue: "",
            context: .normal
        ))
        XCTAssertNoDifference(param.definition, "rarg: RoomArg")
    }

    func testAtomTBL() throws {
        let param = try Variable.Parameter(.atom("TBL"), .normal)
        XCTAssertNoDifference(param, .init(
            name: "table",
            type: "ZIL.Table",
            defaultValue: "",
            context: .normal
        ))
        XCTAssertNoDifference(param.definition, "table: ZIL.Table")
    }

    func testAtomUnknown() throws {
        let param = try Variable.Parameter(.atom("CHERRY-PIE"), .normal)
        XCTAssertNoDifference(param, .init(
            name: "cherryPie",
            type: "Unknown",
            defaultValue: "",
            context: .normal
        ))
        XCTAssertNoDifference(param.definition, "cherryPie: Unknown")
    }

    func testAtomUnknownWithQuestionMark() throws {
        let param = try Variable.Parameter(.atom("HERE?"), .normal)
        XCTAssertNoDifference(param, .init(
            name: "isHere",
            type: "Bool",
            defaultValue: "",
            context: .normal
        ))
        XCTAssertNoDifference(param.definition, "isHere: Bool")
    }

    func testListWithBoolDefault() throws {
        let param = try Variable.Parameter(
            .list([
                .atom("E?"),
                .bool(false)
            ]),
            .normal
        )
        XCTAssertNoDifference(param, .init(
            name: "isE",
            type: "Bool",
            defaultValue: " = false",
            context: .normal
        ))
        XCTAssertNoDifference(param.definition, "isE: Bool = false")
    }
}
