//
//  Logger+ext.swift
//  Quelbo
//
//  Created by Chris Sessions on 8/26/22.
//

import Foundation
import os.log

extension Logger {
    static let heading = Logger(
        subsystem: "com.samadhiBot.Quelbo",
        category: "headings"
    )

    static let package = Logger(
        subsystem: "com.samadhiBot.Quelbo",
        category: "packager"
    )

    static let parse = Logger(
        subsystem: "com.samadhiBot.Quelbo",
        category: "parser"
    )

    static let process = Logger(
        subsystem: "com.samadhiBot.Quelbo",
        category: "processor"
    )
}
