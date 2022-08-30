//
//  Logger+ext.swift
//  Quelbo
//
//  Created by Chris Sessions on 8/26/22.
//

import Foundation
import os.log

extension Logger {
    static let process = Logger(
        subsystem: "com.samadhiBot.Quelbo",
        category: "process"
    )
}
