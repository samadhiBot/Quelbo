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
    class Parser {
        /// A parser that translates raw Zil code into Swift ``Token`` values.
        private let parser: AnyParser<Substring.UTF8View, Array<Token>>

        var parsedTokens: [Token] = []

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

        func parse(_ source: String) throws -> [Token] {
            try parser.parse(source)
        }

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
