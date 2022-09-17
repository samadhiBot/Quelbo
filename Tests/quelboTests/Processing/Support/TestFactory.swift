//
//  TestFactory.swift
//  Quelbo
//
//  Created by Chris Sessions on 9/1/22.
//

@testable import quelbo

class TestFactory: Factory {
    override func process() throws -> Symbol {
        let symbols = try symbolize(tokens)
        return symbols[0]
    }
}
