//
//  Variable+Known.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/13/22.
//

import Foundation

extension Variable {
    enum Known: String {
        case carriageReturn =  "CR"
        case closeText =       "STRCLS"
        case object =          "OBJ"
        case directObject =    "PRSO"
        case indirectObject =  "PRSI"
        case longDescription = "LDESC"
        case openText =        "STROPN"
        case rarg =            "RARG"
        case table =           "TBL"
        case takeValue =       "TVALUE"

        var name: String {
            switch self {
            case .carriageReturn:  return "carriageReturn"
            case .closeText:       return "closeText"
            case .object:          return "object"
            case .directObject:    return "directObject"
            case .indirectObject:  return "indirectObject"
            case .longDescription: return "longDescription"
            case .openText:        return "openText"
            case .rarg:            return "rarg"
            case .table:           return "table"
            case .takeValue:       return "takeValue"
            }
        }

        var type: String {
            switch self {
            case .carriageReturn:  return "String"
            case .closeText:       return "String"
            case .object:          return "Object"
            case .directObject:    return "Object"
            case .indirectObject:  return "Object"
            case .longDescription: return "String"
            case .openText:        return "String"
            case .rarg:            return "RoomArg"
            case .table:           return "ZIL.Table"
            case .takeValue:       return "Int"
            }
        }
    }
}
