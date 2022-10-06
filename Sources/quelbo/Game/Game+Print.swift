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
            // ============================================================

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

        static var output: String {
            var output: [String] = []

            if !Game.directions.isEmpty {
                output.append(
                    Self.comment("Directions", Game.directions.codeValues(.singleLineBreak))
                )
            }
            if !Game.constants.isEmpty {
                output.append(
                    Self.comment("Constants", Game.constants.codeValues(.singleLineBreak))
                )
            }
            if !Game.globals.isEmpty {
                output.append(
                    Self.comment("Globals", Game.globals.codeValues(.singleLineBreak))
                )
            }
            if !Game.objects.isEmpty {
                output.append(
                    Self.comment("Objects", Game.objects.sorted(by: { $0.code < $1.code }).codeValues(.doubleLineBreak))
                )
            }
            if !Game.rooms.isEmpty {
                output.append(
                    Self.comment("Rooms", Game.rooms.codeValues(.doubleLineBreak))
                )
            }
            if !Game.routines.isEmpty {
                output.append(
                    Self.comment("Routines", Game.routines.codeValues(.doubleLineBreak))
                )
            }

            return output.joined(separator: "\n\n")
        }

        static func symbols() {
            print(output)
        }

        static func tokens(_ tokens: [Token]) {
            heading(
                """

                🎟  Zil tokens
                """
            )
            Pretty.prettyPrint(tokens)
        }
    }
}
