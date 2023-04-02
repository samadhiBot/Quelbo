//
//  Action.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/15/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the `ACTION` property of a Zil
    /// [OBJECT](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.38czs75)
    /// type.
    class Action: Factory {
        override class var factoryType: FactoryType {
            .property
        }

        override class var zilNames: [String] {
            ["ACTION"]
        }

        var propertyName: String {
            "action"
        }

        override func processSymbols() throws {
            try symbols.assert(
                .haveCount(.between(0...1)),
                .haveType(.routine)
            )

            guard let routineID = symbols.first?.id else { return }

            Game.registerAction(routineID)

            if let routine = try Game.find(routineID) {
                routine.assertIsActionRoutine()
            }
        }

        override func process() throws -> Symbol {
            let propertyName = propertyName

            guard let actionID = symbols.first?.id else {
                return .statement(
                    code: { _ in propertyName },
                    type: .routine
                )
            }

            return .statement(
                code: { _ in
                    "\(propertyName): \(actionID.quoted)"
                },
                type: .routine
            )
        }
    }
}
