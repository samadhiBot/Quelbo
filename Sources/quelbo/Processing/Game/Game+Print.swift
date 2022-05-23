//
//  Game+Print.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/25/22.
//

import Foundation

extension Game {
    func printSymbols() {
        print(output)
    }
}

extension Game {
    var output: String {
        var output: [String] = []

        if !Game.directions.isEmpty {
            output.append(display(
                heading: "Directions",
                code: Game.directions.codeValues(.doubleLineBreak)
            ))
        }
        if !Game.constants.isEmpty {
            output.append(display(
                heading: "Constants",
                code: Game.constants.codeValues(.singleLineBreak)
            ))
        }
        if !Game.globals.isEmpty {
            output.append(display(
                heading: "Globals",
                code: Game.globals.codeValues(.singleLineBreak)
            ))
        }
        if !Game.objects.isEmpty {
            output.append(display(
                heading: "Objects",
                code: Game.objects.sorted.codeValues(.doubleLineBreak)
            ))
        }
        if !Game.rooms.isEmpty {
            output.append(display(
                heading: "Rooms",
                code: Game.rooms.sorted.codeValues(.doubleLineBreak)
            ))
        }
        if !Game.routines.isEmpty {
            output.append(display(
                heading: "Routines",
                code: Game.routines.sorted.codeValues(.doubleLineBreak)
            ))
        }

        return output.joined(separator: "\n\n")
    }

    func display(heading: String, code: String) -> String {
        """
        // \(heading)
        // ============================================================

        \(code)
        """
    }
}
