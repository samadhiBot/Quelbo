//
//  QuelboTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/6/22.
//

import XCTest
@testable import quelbo

/// A test class for the Quelbo module.
class QuelboTests: XCTestCase {
    var localVariables: [Statement] = []

    static let zilParser = Game.Parser()

    override func setUp() {
        super.setUp()
        continueAfterFailure = false

        Game.reset()
        self.localVariables = []
    }

    /// Asserts that the two provided factory types are the same.
    ///
    /// - Parameters:
    ///   - factory1: The first factory type to compare.
    ///   - factory2: The second factory type to compare.
    ///   - file: The file path of the calling function.
    ///   - line: The line number of the calling function.
    func AssertSameFactory(
        _ factory1: Factory.Type?,
        _ factory2: Factory.Type?,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard let factory1 else {
            return XCTFail("The first factory was not found.", file: file, line: line)
        }
        guard let factory2 else {
            return XCTFail("The second factory was not found.", file: file, line: line)
        }
        XCTAssertEqual(
            String(describing: factory1.self),
            String(describing: factory2.self),
            file: file,
            line: line
        )
    }

    /// Evaluates the provided ZIL string and returns the resulting symbol.
    ///
    /// - Parameters:
    ///   - zil: The ZIL string to evaluate.
    ///   - file: The file path of the calling function.
    ///   - line: The line number of the calling function.
    ///
    /// - Returns: The resulting symbol after evaluating the ZIL string.
    @discardableResult
    func evaluate(
        _ zil: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Symbol {
        process(
            zil,
            mode: .evaluate,
            file: file,
            line: line
        )
    }

    /// Finds a local variable with the given identifier.
    ///
    /// - Parameter id: The identifier of the local variable to find.
    ///
    /// - Returns: The local variable if found, otherwise nil.
    func findLocalVariable(_ id: String) -> Statement? {
        localVariables.first { $0.id == id }
    }

    /// Parses the provided source string and returns an array of tokens.
    ///
    /// - Parameter source: The ZIL source string to parse.
    ///
    /// - Returns: An array of tokens parsed from the source string.
    ///
    /// - Throws: Any errors that occur during parsing.
    func parse(_ source: String) throws -> [Token] {
        let parsed = try Self.zilParser.parse(source)
        if parsed.count == 1, case .form(let tokens) = parsed[0] {
            return tokens
        }
        return parsed
    }

    /// Processes the provided ZIL string and returns the resulting symbol.
    ///
    /// - Parameters:
    ///   - zil: The ZIL string to process.
    ///   - factoryType: The factory type to use during processing (optional, default: .mdl).
    ///   - factoryMode: The factory mode to use during processing (optional, default: .process).
    ///   - injectedLocalVariables: An array of local variables to inject (optional, default: []).
    ///   - file: The file path of the calling function.
    ///   - line: The line number of the calling function.
    ///
    /// - Returns: The resulting symbol after processing the ZIL string.
    @discardableResult
    func process(
        _ zil: String,
        type factoryType: Factories.FactoryType? = .mdl,
        mode factoryMode: Factory.FactoryMode = .process,
        with injectedLocalVariables: [Statement] = [],
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Symbol {
        do {
            let parsed = try Self.zilParser.parse(zil)

            var symbols: [Symbol] = []
            for token in parsed {
                self.localVariables = injectedLocalVariables
                do {
                    switch token {
                    case .eval(let evalToken):
                        guard
                            case .form(let evalFormTokens) = evalToken,
                            case .atom(let zilString) = evalFormTokens.first
                        else {
                            throw GameError.unknownRootEvaluation(token)
                        }
                        _ = try Game.Element(
                            zil: zilString,
                            tokens: evalFormTokens,
                            with: &localVariables,
                            type: .mdl,
                            mode: .evaluate
                        ).process()

                    case .form(let tokens):
                        guard case .atom(let zilString) = tokens.first else {
                            throw GameError.unknownDirective(tokens)
                        }
                        let symbol = try Game.Element(
                            zil: zilString,
                            tokens: tokens,
                            with: &localVariables,
                            type: factoryType,
                            mode: factoryMode
                        ).process()

                        symbols.append(symbol)

                    case .commented, .string:
                        break

                    default:
                        XCTFail(
                            "Test processing is not implemented for this token type:\n\(token)",
                            file: file,
                            line: line
                        )
                        return .false
                    }
                } catch {
                    XCTFail(
                        "Test processing encountered the following error: \(error)",
                        file: file,
                        line: line
                    )
                    return .false
                }
            }

            guard let lastSymbol = symbols.last else {
                XCTFail(
                    "Test processing failed to produce any symbols for:\n\(zil)",
                    file: file,
                    line: line
                )
                return .false
            }

            return lastSymbol

        } catch {
            XCTFail(
                "Parsing failed for Zil source:\n\(error)",
                file: file,
                line: line
            )
            return .false
        }
    }
}

// MARK: - ZorkNumber

extension QuelboTests {
    /// An enumeration representing the different Zork game numbers.
    enum ZorkNumber: Int {
        case zork1 = 1
        case zork2 = 2
        case zork3 = 3
    }
}
