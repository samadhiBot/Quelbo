//
//  Muddle+Definition.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/16/22.
//

import Foundation

extension Muddle {
    enum DefType: Equatable {
        case directions
        case global
        case routine
    }

    enum DataType: String {
        case bool   = "Bool"
        case int    = "Int"
        case string = "String"
        case table  = "Table"
    }

    struct Definition: Equatable {
        let name: String
        let code: String
        let dataType: DataType?
        let defType: DefType
    }
}