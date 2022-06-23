//
//  Game+Print.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/25/22.
//

import CustomDump
import Foundation

extension Game {
    func comment(_ title: String, _ code: String) -> String {
        """
        // \(title)
        // ============================================================

        \(code)
        """
    }

    func printHeading(_ title: String, _ code: String = "") {
        print(
            """
            \(title)
            ========================================================================
            \(code.isEmpty ? "" : code)
            """
        )
    }

    var output: String {
        var output: [String] = []

        if !Game.directions.isEmpty {
            output.append(comment("Directions", Game.directions.codeValues(.singleLineBreak)))
        }
        if !Game.constants.isEmpty {
            output.append(comment("Constants", Game.constants.codeValues(.singleLineBreak)))
        }
        if !Game.globals.isEmpty {
            output.append(comment("Globals", Game.globals.codeValues(.singleLineBreak)))
        }
        if !Game.objects.isEmpty {
            output.append(comment("Objects", Game.objects.sorted.codeValues(.doubleLineBreak)))
        }
        if !Game.rooms.isEmpty {
            output.append(comment("Rooms", Game.rooms.codeValues(.doubleLineBreak)))
        }
        if !Game.routines.isEmpty {
            output.append(comment("Routines", Game.routines.codeValues(.doubleLineBreak)))
        }
        if !Game.functions.isEmpty {
            output.append(comment("Functions", Game.functions.codeValues(.doubleLineBreak)))
        }

        return output.joined(separator: "\n\n")
    }

    func printSymbols() {
        print(output)
    }

    func printTokens() {
        printHeading(
            """

            🎟  Zil tokens
            """
        )
        customDump(gameTokens)
    }
}
