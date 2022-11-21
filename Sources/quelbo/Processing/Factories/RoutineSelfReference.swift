//
//  RoutineSelfReference.swift
//  Quelbo
//
//  Created by Chris Sessions on 11/4/22.
//

import Foundation

extension Factories {
    /// A symbol factory for recursive function calls.
    ///
    class RoutineSelfReference: RoutineCall {
        override var comment: String {
            " /* 􀤊 Requires manual insertion of parameter names */"
        }

        override func processTokens() throws {
            var routineTokens = tokens

            let zilName = try findName(in: &routineTokens).lowerCamelCase

            self.routine = .init(
                id: zilName,
                code: { _ in zilName },
                type: .unknown
            )

            self.params = try symbolize(routineTokens)
        }
    }
}
