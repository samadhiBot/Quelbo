//
//  String+ext.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/7/22.
//

import Foundation

extension String {
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

    /// Returns the `String` with each line indented four spaces per `indentLevel`.
    ///
    /// - Parameter indentLevel: The number of levels to indent the `String`.
    ///
    /// - Returns: The indented `String`.
    func indented(_ indentLevel: Int = 1) -> String {
        let indent = (0..<4 * indentLevel)
            .map { _ in " " }
            .joined(separator: "")
        let indented = self.replacingOccurrences(of: "\n", with: "\n\(indent)")
        return "\(indent)\(indented)"
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
    func quoted(_ indentLevel: Int = 0) -> String {
        let text = convertToMultiline()
        if text.contains("\n") {
            return """
                \"""
                \(text.indented(1))
                    \"""
                """
        } else {
            return "\"\(text)\""
        }
    }

    var rightTrimmed: String {
        var view = self[...]
        while view.last?.isWhitespace == true {
            view = view.dropLast()
        }
        return String(view)
    }

    /// Removes and/or replaces common ZIL prefixes and suffixes that are either unneeded or illegal
    /// in Swift type and instance names.
    var scrubbed: String {
        var string = self
        if string.hasPrefix(",P?") {
            string.removeFirst(3)
        } else if string.hasPrefix(",") || string.hasPrefix(".") {
            string.removeFirst()
        }
        if string.hasSuffix("-F") {
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
            string.removeLast()
            string = "IS-\(string)"
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
}
