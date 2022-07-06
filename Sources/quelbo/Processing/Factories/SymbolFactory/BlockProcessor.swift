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

    var blockActivation: String?
    var codeSymbol = Symbol()
    var isRepeating = false
    var paramsSymbol = Symbol()

    override func processTokens() throws {
        var tokens = tokens

        if case .atom(let activation) = tokens.first {
            self.blockActivation = activation.lowerCamelCase
            tokens.removeFirst()
        }

        let paramSymbols = try findParameterSymbols(in: &tokens)
        let codeSymbols = try symbolize(tokens)

        if !isRepeating, let deepRepeating = codeSymbols.deepRepeating {
            isRepeating = deepRepeating
        }

        if let deepActivation = codeSymbols.deepActivation {
            try setBlockActivation(deepActivation)
        }

        self.codeSymbol = try validateCode(codeSymbols)
        self.paramsSymbol = try validateParameters(paramSymbols)
    }
}

// MARK: - Computed properties

extension BlockProcessor {
    /// <#Description#>
    var argumentTypes: String {
        paramsSymbol.children
            .filter { !$0.isParamWith(context: .local) }
            .map { $0.type.description }
            .joined(separator: ", ")
    }

    /// <#Description#>
//    var activationCode: String {
//        if let activation = blockActivation, !activation.isEmpty {
//            return "\(activation): "
//        } else {
//            return ""
//        }
//    }

    /// <#Description#>
    var children: [Symbol] {
        [codeSymbol, paramsSymbol]
    }

//    var isRepeating: Bool {
//        codeSymbol.children.deepRepeating == true
//    }

    var metaData: Set<Symbol.MetaData> {
//        if let activation = [codeSymbol].deepActivation {
//            return [.controlFlow(.block(activation: activation))]
//        } else {
//            return [.controlFlow(.block(activation: nil, repeating: false))]
//        }

//        [.controlFlow(.block(activation: activation))]
//        if let activation = activation {
//            return [.controlFlow(.b)]
//        }
//        switch (isRepeating, activation) {
//        case (true, let activation):
//            return [.controlFlow(.)]
//        }
//        if isRepeating && activation == nil {
//            return [.controlFlow(.block(activation: nil, repeating: false))]
//        }
//        return []
//        guard let type = blockType else { return [] }
//

//        let isRepeating = codeSymbol.isRepeating

        guard isRepeating else { return codeSymbol.meta }

        var meta: Set<Symbol.MetaData> = codeSymbol.meta

        let params = paramsSymbol.children
            .filter {
                !$0.isParamWith(context: .local) &&
                $0.isMutating(in: codeSymbol.children) == true
            }
            .map {
                $0.localVariable
            }
            .joined(separator: "\n")
        if !params.isEmpty {
            meta.insert(.paramDeclarations(params))
        }
        return meta


//        switch type {
//        case .repeatingWithoutActivation:
//            let params = paramsSymbol.children
//                .map { $0.localVariable }
//                .joined(separator: "\n")
//            return [
//                .blockType(type),
//                .paramDeclarations(params),
//            ]
//        default:
//            return [.blockType(type)]
//        }
    }

    var returnValue: String {
        codeSymbol.type.hasReturnValue ? " -> \(codeSymbol.type)" : ""
    }

    var type: Symbol.DataType {
        codeSymbol.type
    }
}

// MARK: - Validation

extension BlockProcessor {
    func findReturnType(in codeSymbols: [Symbol]) throws -> Symbol.DataType? {
        let allTypes = codeSymbols.deepReturnTypes

        switch allTypes.count {
        case 0: return nil
        case 1: return allTypes[0].type
        default:
            let maxCertainty = allTypes
                .sorted(by: { $0.typeCertainty > $1.typeCertainty })[0]
                .typeCertainty
            return allTypes
                .filter { $0.typeCertainty >= maxCertainty }
                .map(\.type)
                .common
        }
    }

    func setBlockActivation(_ activation: String?) throws {
        guard let activation = activation else { return }

        if let blockActivation = blockActivation,
           !blockActivation.isEmpty,
           activation != blockActivation
        {
            throw Error.conflictingActivations(blockActivation, activation)
        }

        blockActivation = activation
    }

    func validateCode(_ codeSymbols: [Symbol]) throws -> Symbol {
        var codeLines: [String] = []
        var returnType = try findReturnType(in: codeSymbols)
        var symbols = codeSymbols
        
        while let symbol = symbols.shift() {
            if symbols.isEmpty && returnType == nil && symbol.type.hasReturnValue {
                returnType = symbol.type
                codeLines.append("return \(symbol.code)")
            } else if !symbol.code.isEmpty {
                codeLines.append(symbol.code)
            }
        }

        return Symbol(
            code: codeLines.joined(separator: "\n"),
            type: returnType ?? .void,
            children: codeSymbols,
            meta: [.controlFlow(.block(
                activation: blockActivation,
                repeating: isRepeating
            ))]
        )
    }

    func validateParameters(_ symbols: [Symbol]) throws -> Symbol {
        var parameters: [Symbol] = []
        var paramSymbols = symbols

        while let param = paramSymbols.shift() {
            if case .array = param.type {
                guard
                    param.children.count == 2,
                    let nameSymbol = param.children.first,
                    nameSymbol.isIdentifiable,
                    let valueSymbol = param.children.last
                else {
                    throw Error.invalidNameValueParameterPair(param.children)
                }

                parameters.append(param.with(
                    code: { symbol in
                        "\(nameSymbol.id): \(valueSymbol.type) = \(valueSymbol.code)"
                    }
                ))

                continue
            }

            if let registered = findRegistered(param.id) {
                parameters.append(registered.with(
                    code: { symbol in
                        let defaultValue = symbol.paramContext?.defaultValue(for: symbol.type)
                        return "\(symbol): \(symbol.type)\(defaultValue ?? "")"
                    }
                ))

                guard
                    !param.isParamWith(context: .local),
                    param.isMutating(in: codeSymbol.children) == true
                else {
                    continue
                }

                parameters.append(Symbol(
                    code: "\(registered.id) = \(registered.id)",
                    type: registered.type,
                    meta: [.paramContext(.local)]
                ))

                continue
            }

                //            switch context {
                //            case .normal, .optional:
                //                parameters.append(paramSymbol)
                //                if paramSymbol.isMutating(in: validatedCode.children) == true {
                //                    auxiliaries.append(Symbol(
                //                        code: "\(paramSymbol.id) = \(paramSymbol.id)",
                //                        type: paramSymbol.type
                //                    ))
                //                }
                //            case .local:
                //                auxiliaries.append(paramSymbol)
                //            }


            throw Error.unusedParameter(param)
        }

        return Symbol(
            code: parameters.codeValues(.commaSeparatedNoTrailingComma),
            children: parameters
        )
    }
}

// MARK: - Errors

extension BlockProcessor {
    enum Error: Swift.Error {
        case conflictingActivations(String, String)
        case invalidNameValueParameterPair([Symbol])
        case unusedParameter(Symbol)
    }
}
