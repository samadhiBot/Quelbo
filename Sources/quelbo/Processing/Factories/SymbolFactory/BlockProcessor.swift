//
//  BlockProcessor.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/23/22.
//

import Foundation

/// A symbol factory for Zil code blocks.
///
/// See the _ZILF Reference Guide_ entries on the
/// [BIND](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.12jfdx2),
/// [PROG](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.1bkyn9b),
/// [RETURN](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.2fugb6e) and
/// [AGAIN](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.1au1eum)
/// functions for detailed information.
class BlockProcessor: SymbolFactory {
    override class var zilNames: [String] {
        ["<BlockProcessor>"]
    }

    var code = Symbol("TBD")
    var params = Symbol("TBD")

    private var auxiliaries: [Symbol] = []
    private var warnings: [String] = []

    override func processTokens() throws {
        var tokens = tokens

        if case .atom(let activation) = tokens.first {
            blockType?.setActivation(activation.lowerCamelCase)
            tokens.removeFirst()
        }

        let paramSymbols = try findParameterSymbols(in: &tokens)
        let codeSymbols = try symbolize(tokens)

        self.code = try validateCode(codeSymbols)
        self.params = try validateParameters(paramSymbols, against: code)
    }
}

// MARK: - BlockProcessor.Context

extension BlockProcessor {
    enum Context {
        case normal
        case local
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
}

// MARK: - Computed properties

extension BlockProcessor {
    /// The block activation, if one has been assigned.
    var activation: String {
        switch blockType! {
        case .blockWithActivation(let activation):
            return "\(activation): "
        case .repeatingWithActivation(let activation):
            return "\(activation): "
        default:
            return ""
        }
    }

    func auxiliaryDefs(indented: Bool = false) -> String {
        emit(
            auxiliaries.compactMap {
                guard !$0.code.contains("=") else {
                    return nil
                }
                return $0.localVariable
            },
            shouldIndent: indented
        )
    }

    func auxiliaryDefsWithDefaultValues(indented: Bool = false) -> String {
        emit(
            auxiliaries.compactMap {
                guard $0.code.contains("=") else {
                    return nil
                }
                return $0.localVariable
            },
            shouldIndent: indented
        )
    }

    var children: [Symbol] {
        code.children
    }

    var codeBlock: String {
        if isRepeating {
            return """
                \(deepParameters)\
                \(activation)\
                while true {
                \(auxiliaryDefsWithDefaultValues(indented: true))\
                \(code.code.indented)
                }
                """
        } else {
            return """
                \(auxiliaryDefsWithDefaultValues())\
                \(code.code)
                """
        }
    }

    var deepParameters: String {
        guard let deepParams = code.children.deepParamDeclarations else {
            return ""
        }
        return deepParams.appending("\n")
    }

    var discardableResult: String {
        code.type.hasReturnValue ? "@discardableResult\n" : ""
    }

    var isRepeating: Bool {
        if blockType?.isRepeating == true {
            return true
        }
        if children.deepRepeating == true {
            blockType?.setActivation("defaultAct")
            return true
        }
        return false
    }

    var metaData: [Symbol.MetaData] {
        guard let type = blockType else {
            return []
        }
        switch type {
        case .repeatingWithoutDefaultActivation:
            let params = params.children
                .map { $0.localVariable }
                .joined(separator: "\n")
            return [
                .blockType(type),
                .paramDeclarations(params),
            ]
        default:
            return [.blockType(type)]
        }
    }

    func paramDeclarations(indented: Bool = false) -> String {
        guard blockType != .repeatingWithoutDefaultActivation else {
            return ""
        }
        return emit(
            params.children.map { $0.localVariable },
            shouldIndent: indented
        )
    }

    var returnValue: String {
        code.type.hasReturnValue ? " -> \(code.type)" : ""
    }

    var type: Symbol.DataType {

        code.type
    }

    func warningComments(indented: Bool = false) -> String {
        emit(
            warnings,
            shouldIndent: indented
        )
    }
}

extension BlockProcessor {
    private func emit(
        _ values: [String],
        shouldIndent: Bool
    ) -> String {
        guard !values.isEmpty else { return "" }
        if shouldIndent {
            return values
                .joined(separator: "\n")
                .indented
                .appending("\n")
        } else {
            return values
                .joined(separator: "\n")
                .appending("\n")
        }
    }
}

// MARK: - Validation

extension BlockProcessor {
    func validateCode(_ codeSymbols: [Symbol]) throws -> Symbol {
        var codeLines: [String] = []
        var symbols = codeSymbols
        var returnType: Symbol.DataType? = codeSymbols.deepReturnDataType

        while let symbol = symbols.shift() {
            if symbol.isAgainStatement {
                blockType?.makeRepeating()
            }
            if symbols.isEmpty && returnType == nil && symbol.type.hasReturnValue {
                returnType = symbol.type
                codeLines.append("return \(symbol.code)")
            } else if !symbol.code.isEmpty {
                codeLines.append(symbol.code)
            }
        }

        return Symbol(
            codeLines.joined(separator: "\n"),
            type: returnType ?? .void,
            children: codeSymbols
        )
    }

    func validateParameters(
        _ symbols: [Symbol],
        against validatedCode: Symbol
    ) throws -> Symbol {
        var context: Context = .normal
        var parameters: [Symbol] = []
        var symbols = symbols

        while let param = symbols.shift() {
            switch param.id {
            case "<Arguments>":
                context = .normal
                continue
            case "<Locals>":
                context = .local
                continue
            case "<Optionals>":
                context = .optional
                continue
            default:
                break
            }

            var paramSymbol: Symbol
            if case .array(var type) = param.type {
                guard
                    param.children.count == 2,
                    let nameSymbol = param.children.first,
                    let valueSymbol = param.children.last
                else {
                    throw FactoryError.invalidParameter(param.children)
                }
                if type == .unknown {
                    type = types[nameSymbol.id] ?? types[valueSymbol.id] ?? .unknown
                }
                paramSymbol = param.with(
                    code: "\(nameSymbol.id): \(type) = \(valueSymbol.code)"
                )
                types.register(id: nameSymbol.id, as: type)
                types.register(id: valueSymbol.id, as: type)

            } else if let found = validatedCode.children.find(id: param.id) {
                paramSymbol = found.with(
                    code: "\(found.id): \(found.type)\(context.defaultValue(for: found))"
                )
            } else if let type = types[param.id] {
                paramSymbol = param.with(
                    code: "\(param.id): \(type)"
                )
            } else {
                warnings.append("// Parameter `\(param)` was specified but unused")
                continue
            }

            switch context {
            case .normal, .optional:
                parameters.append(paramSymbol)
                if paramSymbol.isMutating(in: validatedCode.children) == true {
                    auxiliaries.append(Symbol(
                        "\(paramSymbol.id) = \(paramSymbol.id)",
                        type: paramSymbol.type
                    ))
                }
            case .local:
                auxiliaries.append(paramSymbol)
            }
        }

        return Symbol(
            parameters.codeValues(.commaSeparatedNoTrailingComma),
            children: parameters
        )
    }
}

extension Symbol {
    fileprivate var localVariable: String {
        if code.contains("=") {
            return "var \(code)"
        } else {
            return "var \(code) = \(type.emptyValue)"
        }
    }
}
