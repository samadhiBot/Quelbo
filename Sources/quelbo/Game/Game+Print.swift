//
//  Game+Print.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/25/22.
//

import Foundation
import SwiftPrettyPrint
import os.log

extension Game {
    struct Print {
        static func comment(_ title: String, _ code: String) -> String {
            """
            // \(title)
            // =====================================================================

            \(code)

            """
        }

        static func heading(_ title: String, _ code: String = "") {
            Logger.heading.info(
                "\("\(title) \(code)".trimmingCharacters(in: .whitespacesAndNewlines), privacy: .public)"
            )

            print(
                """
                \(title)
                ========================================================================
                \(code.isEmpty ? "" : code)
                """
            )
        }

        static func symbols() {
            let directions = Game.directions.sorted
            if !directions.isEmpty {
                print(
                    Self.comment("Directions", directions.codeValues(.singleLineBreak))
                )
            }

            let constants = Game.constants.sorted
            if !constants.isEmpty {
                print(
                    Self.comment("Constants", constants.codeValues(.singleLineBreak))
                )
            }

            let globals = Game.globals.sorted
            if !globals.isEmpty {
                print(
                    Self.comment("Globals", globals.codeValues(.singleLineBreak))
                )
            }

            let objects = Game.objects.sorted
            if !objects.isEmpty {
                print(
                    Self.comment(
                        "Objects",
                        objects.sorted(by: { $0.code < $1.code })
                               .codeValues(.doubleLineBreak)
                    )
                )
            }

            let rooms = Game.rooms.sorted
            if !rooms.isEmpty {
                print(
                    Self.comment("Rooms", rooms.codeValues(.doubleLineBreak))
                )
            }

            let routines = Game.routines.sorted
            if !routines.isEmpty {
                print(
                    Self.comment("Routines", routines.codeValues(.doubleLineBreak))
                )
            }
        }

        static func tokens(_ tokens: [Token]) {
            heading(
                """

                􀪄  Zil tokens
                """
            )
            Pretty.prettyPrint(tokens)
        }
    }
}
