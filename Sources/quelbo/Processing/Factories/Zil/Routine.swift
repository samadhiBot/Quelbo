//
//  Routine.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/2/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the Zil
    /// [ROUTINE](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.22vxnjd)
    /// function.
    class Routine: ZilFactory {
        override class var zilNames: [String] {
            ["ROUTINE"]
        }

        var nameSymbol: Symbol!
        var parameterSymbols: [Symbol] = []
        var warnings: [String] = []
        var auxiliaries: [Symbol] = []

        override func processTokens() throws {
            var tokens = tokens

            self.nameSymbol = try findNameSymbol(in: &tokens)
            self.parameterSymbols = try findParameterSymbols(in: &tokens)
            self.symbols = try symbolize(tokens)
        }

        override func process() throws -> Symbol {
            print("  + Processing routine \(nameSymbol.code)")

            let code = try validateCode(symbols)
            let parameters = try validateParameters(parameterSymbols, against: code.children)
            let returnValue = code.type.hasReturnValue ? " -> \(code.type)" : ""

            let symbol = Symbol(
                id: nameSymbol.code,
                code: """
                    /// The `\(nameSymbol.code)` (\(nameSymbol.id)) routine.
                    func \(nameSymbol.code)(\(parameters))\(returnValue) {
                    \(warningComments)\(auxiliaryDefs)\(code.code.indented())
                    }
                    """,
                type: code.type,
                category: .routines,
                children: parameters.children
            )
            try Game.commit(symbol)
            return symbol
        }
    }
}

extension Factories.Routine {
    enum ParameterContext {
        case normal
        case auxiliary
        case optional

        func defaultValue(for symbol: Symbol) -> String {
            guard self == .optional else {
                return ""
            }
            switch symbol.type {
                case .array: return "? = []"
                case .bool:  return " = false"
                default:     return "? = nil"
            }
        }
    }

    func validateCode(_ symbols: [Symbol]) throws -> Symbol {
//        var symbols = symbols
        let returnType = symbols
            .map { $0.type }
            .filter { $0 != .comment }
            .last

        var returned = false
        let codeLines = symbols.reversed().map { (symbol: Symbol) -> String in
            if !returned && symbol.type.hasReturnValue && symbols.count > 1 {
                returned = true
                if symbol.code.hasPrefix("return ") {
                    return symbol.code
                } else {
                    return "return \(symbol)"
                }
            } else {
                return symbol.code
            }
        }.reversed()

        return Symbol(
            codeLines.joined(separator: "\n"),
            type: returnType ?? .unknown,
            children: symbols
        )
    }

    func validateParameters(
        _ symbols: [Symbol],
        against codes: [Symbol]
    ) throws -> Symbol {
        var context: ParameterContext = .normal
        var parameters: [Symbol] = []
        var symbols = symbols

        while let param = symbols.shift() {
            switch param.id {
                case #""AUX""#, #""EXTRA""#:
                    context = .auxiliary
                    continue
                case #""OPT""#, #""OPTIONAL""#:
                    context = .optional
                    continue
                default:
                    break
            }

            let paramSymbol: Symbol
            if param.type == .list {
                guard
                    param.children.count == 2,
                    let nameSymbol = param.children.first,
                    let valueSymbol = param.children.last
                else {
                    throw FactoryError.invalidParameter(param.children)
                }
                paramSymbol = param.with(
                    code: "\(nameSymbol.id): \(valueSymbol.type) = \(valueSymbol.code)"
                )
            } else if let found = codes.find(id: param.id) {
                paramSymbol = found.with(
                    code: "\(found.id): \(found.type)\(context.defaultValue(for: found))"
                )
            } else {
                warnings.append("// Parameter `\(param)` was specified but unused")
                continue
            }

            switch context {
                case .normal, .optional:
                    parameters.append(paramSymbol)
                case .auxiliary:
                    auxiliaries.append(paramSymbol.with(code: "var \(paramSymbol.code)"))
            }
        }
        return Symbol(parameters.codeValues(separator: ","), children: parameters)
    }
}

extension Factories.Routine {
    var auxiliaryDefs: String {
        guard !auxiliaries.isEmpty else { return "" }
        return auxiliaries
            .codeValues(lineBreaks: 1)
            .indented(1)
            .appending("\n\n")
    }

    var warningComments: String {
        guard !warnings.isEmpty else { return "" }
        return warnings
            .joined(separator: "\n")
            .indented(1)
            .appending("\n\n")
    }
}
