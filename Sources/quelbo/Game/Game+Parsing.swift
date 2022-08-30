//
//  Game+Parsing.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/7/22.
//

import Files
import Parsing
import Progress

extension Game {
    func parseZilSource(at path: String) throws {
        let gameFiles = try gameFiles(at: path)
        var progressBar = ProgressBar(
            count: gameFiles.count - 1,
            configuration: [
                ProgressBarLine(barLength: 65),
                ProgressPercent(),
            ]
        )

        printHeading("⚗️  Parsing Zil source")

        try gameFiles.forEach { file in
            progressBar.next()
            let zil = try file.readAsString()
            try parse(zil)
        }
    }
}

extension Game {
    func gameFiles(at path: String) throws -> [File] {
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

    func parse(_ source: String) throws {
        let fileTokens = try parser.parse(source)
        tokens.append(contentsOf: fileTokens)
    }
}
