//
//  Game+Print.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/25/22.
//

import Foundation

extension Game {
    func print() {
        Swift.print(Game.output)
    }
}

extension Game {
    static var output: String {
        var output: [String] = []

        if !Game.directions.isEmpty {
            output.append(display(heading: "Directions", code: Game.directions.code()))
        }
        if !Game.constants.isEmpty {
            output.append(display(heading: "Constants", code: Game.constants.code(false)))
        }
        if !Game.globals.isEmpty {
            output.append(display(heading: "Globals", code: Game.globals.code(false)))
        }
        if !Game.objects.isEmpty {
            output.append(display(heading: "Objects", code: Game.objects.code()))
        }
        if !Game.rooms.isEmpty {
            output.append(display(heading: "Rooms", code: Game.rooms.code()))
        }
        if !Game.routines.isEmpty {
            output.append(display(heading: "Routines", code: Game.routines.code()))
        }

        return output.joined(separator: "\n\n")
    }

    static func display(heading: String, code: String) -> String {
        """
        // \(heading)
        // ================================================================================

        \(code)
        """
    }
}

extension Array where Element == Muddle.Definition {
    func code(_ emptyLineAfter: Bool = true) -> String {
        self.map { $0.code }
            .joined(separator: emptyLineAfter ? "\n\n" : "\n")
    }
}
