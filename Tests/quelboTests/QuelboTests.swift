//
//  QuelboTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/6/22.
//

import XCTest
@testable import quelbo

class QuelboTests: XCTestCase {
    var localVariables: [Variable]!

    let zilParser = Game.Parser()

    override func setUp() {
        super.setUp()
        continueAfterFailure = false

        Game.reset()
        self.localVariables = []
    }

    func AssertSameFactory(
        _ factory1: Factory.Type?,
        _ factory2: Factory.Type?,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard let factory1 = factory1 else {
            return XCTFail("The first factory was not found.", file: file, line: line)
        }
        guard let factory2 = factory2 else {
            return XCTFail("The second factory was not found.", file: file, line: line)
        }
        XCTAssertEqual(
            String(describing: factory1.self),
            String(describing: factory2.self),
            file: file,
            line: line
        )
    }

    /// <#Description#>
    /// - Parameter id: <#id description#>
    /// - Returns: <#description#>
    func findLocalVariable(_ id: String) -> Variable? {
        localVariables.first { $0.id == id }
    }

    /// <#Description#>
    /// - Parameter source: <#source description#>
    /// - Returns: <#description#>
    func parse(_ source: String) throws -> [Token] {
        let parsed = try zilParser.parse(source)
        if parsed.count == 1, case .form(let tokens) = parsed[0] {
            return tokens
        }
        return parsed
    }

    @discardableResult
    /// <#Description#>
    /// - Parameters:
    ///   - zil: <#zil description#>
    /// - Returns: <#description#>
    func process(
        _ zil: String,
        type FactoryType: Factories.FactoryType? = nil,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Symbol {
        let parsed: [Token]
        do {
            parsed = try zilParser.parse(zil)
        } catch {
            XCTFail(
                "Parsing failed for Zil source:\n\(zil)",
                file: file,
                line: line
            )
            return .literal(false)
        }

        var symbols: [Symbol] = []
        for token in parsed {
            do {
                switch token {
                case .form(let tokens):
                    guard case .atom(let zilString) = tokens.first else {
                        throw GameError.unknownDirective(tokens)
                    }
                    let symbol = try Game.process(
                        zil: zilString,
                        tokens: tokens,
                        with: &localVariables,
                        type: .mdl
                    )
                    try Game.commit(symbol)

                    symbols.append(symbol)
                default:
                    XCTFail(
                        "Test processing is not implemented for this token type:\n\(token)",
                        file: file,
                        line: line
                    )
                    return .literal(false)
                }
            } catch {
                XCTFail(
                    "Test processing encountered the following error: \(error)",
                    file: file,
                    line: line
                )
                return .literal(false)
            }
        }

        guard let lastSymbol = symbols.last else {
            XCTFail(
                "Test processing failed to produce any symbols for:\n\(zil)",
                file: file,
                line: line
            )
            return .literal(false)
        }

        return lastSymbol
    }
}

extension QuelboTests {
    enum TestError: Error {
        case emptyProcess(String)
        case expectedOneSymbol(String, got: Int)
        case invalidProcess([Token])
    }
}
