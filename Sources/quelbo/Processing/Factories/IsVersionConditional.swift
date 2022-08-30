//
//  IsVersionConditional.swift
//  Quelbo
//
//  Created by Chris Sessions on 7/28/22.
//

import Foundation

extension Factories {
    /// A symbol factory for a single conditional predicate and associated expressions within a
    /// Quelbo ``Condition``.
    class IsVersionConditional: Conditional {
        override func ifStatement(for predicateCode: String) -> String {
            switch predicateCode {
            case "else", "t", "true": return ""
            default: return "if zMachineVersion == .\(predicateCode) "
            }
        }
    }
}
