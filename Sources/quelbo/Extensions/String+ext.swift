//
//  String+ext.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/7/22.
//

import AppKit

extension String {
    /// <#Description#>
    var commented: String {
        split(separator: "\n")
            .map { "// \($0)" }
            .joined(separator: "\n")
    }

    /// Returns the `String` split into multiple lines if its length exceeds the specified `limit`.
    ///
    /// - Parameter limit: The maximum line length before splitting into multiple lines.
    ///
    /// - Returns: The converted `String`.
    func convertToMultiline(limit: Int = 60) -> String {
        guard count > limit else { return self }

        let lines = self
            .replacingOccurrences(of: "\n", with: "__CR__\n")
            .split(separator: "\n")
        var multiline: [String] = []

        lines.forEach {
            var line = ""
            var words = $0.replacingOccurrences(of: "__CR__", with: "")
                .rightTrimmed
                .split(separator: " ")
            while !words.isEmpty {
                let word = words.removeFirst()
                if line.count + word.count < limit {
                    line = line.isEmpty ? "\(word)" : "\(line) \(word)"
                } else {
                    multiline.append("\(line) \\")
                    line = "\(word)"
                }
            }
            multiline.append(line)
        }
        return multiline.joined(separator: "\n")
    }

    /// Returns the `String` with each line indented by four spaces.
    var indented: String {
        guard !isEmpty else { return "" }

        return "    \(self.replacingOccurrences(of: "\n", with: "\n    "))".rightTrimmed
    }

    /// Translates a ZIL name `String` from dash-separated ALL-CAPS to camel case with a lowercase
    /// first letter.
    var lowerCamelCase: String {
        scrubbed.split(separator: "_")
            .enumerated()
            .map { $0.offset > 0 ? $0.element.capitalized : $0.element.lowercased() }
            .joined()
    }

    /// Returns the `String` in the appropriate quotes, depending on whether it is a single or
    /// multiline `String`.
    ///
    /// - Parameter indentLevel: The level of indentation, with four spaces per level.
    ///
    /// - Returns: The quoted `String`.
    var quoted: String {
        let text = convertToMultiline()
        if text.contains("\n") {
            return """
                \"""
                \(text.indented)
                    \"""
                """.rightTrimmed
        } else {
            return "\"\(text.replacingOccurrences(of: "\"", with: #"\""#))\""
        }
    }

    /// Returns the `String` with any trailing space characters trimmed.
    var rightTrimmed: String {
        self.replacingOccurrences(of: "\n", with: "__PRE__\n__POST__")
            .split(separator: "\n")
            .map { line in
                var view = line
                    .replacingOccurrences(of: "__PRE__", with: "")
                    .replacingOccurrences(of: "__POST__", with: "")[...]
                while view.last?.isWhitespace == true {
                    view = view.dropLast()
                }
                return String(view)
            }
            .joined(separator: "\n")
    }

    /// <#Description#>
    var sanitized: String {
        replacingOccurrences(of: "\\", with: "")
    }

    /// Removes and/or replaces common ZIL prefixes and suffixes that are either unneeded or illegal
    /// in Swift type and instance names.
    var scrubbed: String {
        var string = self
        if string.hasPrefix(",P?") {
            string.removeFirst(3)
        } else if string.hasPrefix("!.") {
            string.removeFirst(2)
        } else if string.hasPrefix(",") || string.hasPrefix(".") || string.hasPrefix("'") {
            string.removeFirst()
        } else if string.hasSuffix("-F") {
            string.removeLast()
            string.append("FUNC")
        } else if string.hasSuffix("-FCN") {
            string.removeLast(3)
            string.append("FUNC")
        } else if string.hasSuffix("-FUNCTION") {
            string.removeLast(8)
            string.append("FUNC")
        } else if string.hasSuffix("-R") {
            string.removeLast()
            string.append("ROUTINE")
        } else if string.hasSuffix("?") {
            string = "IS-\(string.replacingOccurrences(of: "?", with: ""))"
        } else if string.contains("?") {
            string = "IS-\(string.replacingOccurrences(of: "?", with: "-"))"
        } else if string.hasSuffix("!") {
            // See `ZilSyntaxTests.testSegmentFormWithClosingBang`
            string.removeLast()
        } else if string.hasSuffix("BIT") {
            string.removeLast(3)
            string.append("-BIT")
        }

        if string == "PRSA" {
            string = "PARSED-VERB"
        } else if string == "PRSI" {
            string = "PARSED-INDIRECT-OBJECT"
        } else if string == "PRSO" {
            string = "PARSED-DIRECT-OBJECT"
        }

        return string.replacingOccurrences(of: "-", with: "_")
    }

    /// Translates a multiline `String` from ZIL to Swift syntax formatting.
    var translateMultiline: String {
        self.replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "|\n", with: "__PIPE__")
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "|", with: "\n")
            .replacingOccurrences(of: "__PIPE__", with: "\n")
    }

    /// Translates a ZIL name `String` from dash-separated ALL-CAPS to camel case with a uppercase
    /// first letter.
    var upperCamelCase: String {
        scrubbed.split(separator: "_")
            .map { $0.capitalized }
            .joined()
    }

    /// <#Description#>
    var withDotPrefix: String {
        guard hasPrefix(".") else { return ".\(self)" }
        return self
    }
}
