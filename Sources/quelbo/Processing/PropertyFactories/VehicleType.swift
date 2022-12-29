//
//  VehicleType.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/15/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the `VTYPE` property of a Zil
    /// [OBJECT](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.38czs75)
    /// type.
    class VehicleType: Factory {
        override class var factoryType: FactoryType {
            .property
        }

        override class var zilNames: [String] {
            ["VTYPE"]
        }

        override func processSymbols() throws {
            try symbols.assert(
                .haveCount(.between(0...1)),
                .haveType(.oneOf([.bool, .int]))
            )
        }

        override func process() throws -> Symbol {
            guard symbols.count > 0 else {
                return .statement(
                    code: { _ in "vehicleType" },
                    type: .bool
                )
            }

            var vehicleType: String {
                switch symbols[0].code {
                case "true", "1": return "true"
                default: return "false"
                }
            }

            return .statement(
                id: "vehicleType",
                code: { _ in
                    "vehicleType: \(vehicleType)"
                },
                type: .bool
            )
        }
    }
}
