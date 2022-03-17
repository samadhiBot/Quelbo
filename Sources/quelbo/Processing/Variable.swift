//
//  Variable.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/13/22.
//

import Foundation

/// <#Description#>
struct Variable: Equatable {
    /// The variable's Swift name.
    let name: String

    /// The variable's Swift type, if known.
    let type: String?

    /// The variable's original name in ZIL.
    let zil: String
}

extension Variable {
    init(_ zil: String, _ value: Token? = nil) {
        var isGlobal = false
        var zil = zil

        if zil.hasPrefix(",P?") {
            zil.removeFirst(3)
        } else if zil.hasPrefix(",") {
            isGlobal = true
            zil.removeFirst()
        } else if zil.hasPrefix(".") {
            zil.removeFirst()
        }
        self.zil = zil

        let name = zil.lowerCamelCase

        if let known = Known(rawValue: zil) {
            self.name = isGlobal ? "World.\(known.name)" : known.name
            self.type = known.type
        } else if let routine = Game.routines.first(where: { $0.name == name }) {
            self.name = "\(routine.name)()"
            self.type = routine.dataType?.rawValue
        } else {
            switch value {
            case .bool:      self.type = "Bool"
            case .commented: self.type = "String"
            case .decimal:   self.type = "Int"
            case .quoted:    self.type = "String"
            case .string:    self.type = "String"
            default:         self.type = zil.contains("?") ? "Bool" : nil
            }
            self.name = isGlobal ? "World.\(name)" : name
        }
    }

    var typeOrUnknown: String {
        type ?? "Unknown"
    }
}
