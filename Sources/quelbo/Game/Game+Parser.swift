//
//  Game+Parser.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/7/22.
//

import Files
import Parsing
import Progress
import os.log

extension Game {
    /// A class responsible for parsing a ZIL game source code into Swift ``Token`` values.
    class Parser {
        /// A parser that translates raw Zil code into Swift ``Token`` values.
        private let parser: AnyParser<Substring.UTF8View, Array<Token>>

        /// An array of parsed tokens.
        var parsedTokens: [Token] = []

        /// Initializes a new instance of the `Parser` class.
        init() {
            let syntax = ZilSyntax().parser

            let parser = Parse {
                Many {
                    syntax
                } separator: {
                    Whitespace()
                }
                End()
            }
            .eraseToAnyParser()

            self.parser = parser
        }

        /// Parses the provided ZIL source code into an array of tokens.
        ///
        /// - Parameter source: The ZIL source code to parse.
        ///
        /// - Returns: An array of parsed tokens.
        ///
        /// - Throws: An error if the parser fails to parse the source code.
        func parse(_ source: String) throws -> [Token] {
            try parser.parse(source)
        }

        /// Parses ZIL source files at the specified path.
        ///
        /// - Parameter path: The path to the ZIL source files.
        ///
        /// - Throws: An error if unable to read or parse the source files.
        func parseZilSource(at path: String) throws {
            let gameFiles = try gameFiles(at: path)
            var progressBar = ProgressBar(
                count: gameFiles.count - 1,
                configuration: [
                    ProgressBarLine(barLength: 65),
                    ProgressPercent(),
                ]
            )

            Game.Print.heading("􀉂  Parsing Zil source")

            for file in gameFiles {
                Logger.parse.info("􀈷 Parsing \(file.name, privacy: .public)")

                progressBar.next()
                let zilSource = try file.readAsString()
                parsedTokens.append(
                    contentsOf: try parse(zilSource)
                )
            }
        }
    }
}

extension Game.Parser {
    /// Returns an array of game files with the `.zil` extension at the specified path.
    ///
    /// - Parameter path: The path where the game files are located.
    ///
    /// - Returns: An array of game files with the `.zil` extension.
    ///
    /// - Throws: An error if unable to find the folder or read the file.
    private func gameFiles(at path: String) throws -> [File] {
        guard let folder = try? Files.Folder(path: path) else {
            let file = try Files.File(path: path)
            return [file]
        }
        return folder.files.compactMap { file in
            guard file.extension?.lowercased() == "zil" else {
                return nil
            }
            return file
        }
    }
}
