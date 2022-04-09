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
                code: Game.directions.codeValues(lineBreaks: 2)
            ))
        }
        if !Game.constants.isEmpty {
            output.append(display(
                heading: "Constants",
                code: Game.constants.codeValues(separator: ",")
            ))
        }
        if !Game.globals.isEmpty {
            output.append(display(
                heading: "Globals",
                code: Game.globals.codeValues(separator: ",")
            ))
        }
        if !Game.objects.isEmpty {
            output.append(display(
                heading: "Objects",
                code: Game.objects.codeValues(lineBreaks: 2, sorted: true)
            ))
        }
        if !Game.rooms.isEmpty {
            output.append(display(
                heading: "Rooms",
                code: Game.rooms.codeValues(lineBreaks: 2, sorted: true)
            ))
        }
        if !Game.routines.isEmpty {
            output.append(display(
                heading: "Routines",
                code: Game.routines.codeValues(lineBreaks: 2, sorted: true)
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
