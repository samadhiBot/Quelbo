//
//  Symbol+BlockPro.swift
//  Quelbo
//
//  Created by Chris Sessions on 6/26/22.
//

import Foundation

extension Symbol {
    struct BlockPro: Equatable {
        var codeSymbol: Symbol
        var paramsSymbol: Symbol
        var blockType: SymbolFactory.ProgramBlockType?
        var auxiliaries: [Symbol] = []
//        var warnings: [String]

        init(_ symbols: [Symbol]) {
            self.codeSymbol = symbols[0]
            self.paramsSymbol = symbols[1]
            if symbols.count > 2 {
                self.auxiliaries = Array(symbols[2...])
            } 
        }
    }
}

extension Symbol.BlockPro {
    /// The block activation, if one has been assigned.
    var activation: String {
        switch blockType {
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

    mutating func codeBlock() -> String {
        if isRepeating {
            return """
                \(deepParameters)\
                \(activation)\
                while true {
                \(auxiliaryDefsWithDefaultValues(indented: true))\
                \(codeSymbol.code.indented)
                }
                """
        } else {
            return """
                \(auxiliaryDefsWithDefaultValues())\
                \(codeSymbol.code)
                """
        }
    }

    var deepParameters: String {
        guard let deepParams = codeSymbol.children.deepParamDeclarations else { return "" }

        return deepParams.appending("\n")
    }

    var discardableResult: String {
        codeSymbol.type.hasReturnValue ? "@discardableResult\n" : ""
    }

    func emit(
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

    var isRepeating: Bool {
        if blockType?.isRepeating == true {
            return true
        }
        if [codeSymbol, paramsSymbol].deepRepeating == true {
            return true
        }
        return false
    }

    var metaData: Set<Symbol.MetaData> {
        guard let type = blockType else { return [] }

        switch type {
        case .repeatingWithoutDefaultActivation:
            let params = paramsSymbol.children
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
        guard blockType != .repeatingWithoutDefaultActivation else { return "" }

        return emit(
            paramsSymbol.children.map { $0.localVariable },
            shouldIndent: indented
        )
    }

    var returnValue: String {
        codeSymbol.type.hasReturnValue ? " -> \(codeSymbol.type)" : ""
    }

    var type: Symbol.DataType {
        codeSymbol.type
    }

//    func warningComments(indented: Bool = false) -> String {
//        emit(
//            warnings,
//            shouldIndent: indented
//        )
//    }
}

// MARK: - Validation

//extension Symbol.BlockPro {
//    var returnType: Symbol.DataType? {
//        let allTypes = codeSymbol.children.deepReturnTypes
//
//        switch allTypes.count {
//        case 0: return nil
//        case 1: return allTypes[0].type
//        default: return allTypes.findByTypeCertainty()?.type
//        }
//    }
//
//    func validateParameters(
//        _ symbols: [Symbol],
//        against validatedCode: Symbol
//    ) throws -> Symbol {
//        var context: BlockProcessor.Context = .normal
//        var parameters: [Symbol] = []
//        var symbols = symbols
//
//        while let param = symbols.shift() {
//            switch param.id {
//            case "<Arguments>":
//                context = .normal
//                continue
//            case "<Locals>":
//                context = .local
//                continue
//            case "<Optionals>":
//                context = .optional
//                continue
//            default:
//                break
//            }
//
//            var paramSymbol: Symbol
//            if case .array(var type) = param.type {
//                guard
//                    param.children.count == 2,
//                    let nameSymbol = param.children.first,
//                    let valueSymbol = param.children.last
//                else {
//                    throw BlockProcessor.Error.invalidNameValueParameterPair(param.children)
//                }
//                if type.isUnknown {
//                    type = findRegistered(nameSymbol.id)?.type ??
//                           findRegistered(valueSymbol.id)?.type ??
//                           .unknown
//                }
//                paramSymbol = param.with(
//                    code: "\(nameSymbol.id): \(type) = \(valueSymbol.code)"
//                )
////                registry.register(nameSymbol.with(type: type))
////                registry.register(valueSymbol.with(type: type))
//
//            } else if let found = validatedCode.children.find(id: param.id) {
//                paramSymbol = found.with(
//                    code: "\(found.id): \(found.type)\(context.defaultValue(for: found))"
//                )
//            } else if let type = findRegistered(param.id)?.type {
//                paramSymbol = param.with(
//                    code: "\(param.id): \(type)"
//                )
//            } else {
//                warnings.append("// Parameter `\(param)` was specified but unused")
//                continue
//            }
//
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
//        }
//
//        return Symbol(
//            code: parameters.codeValues(.commaSeparatedNoTrailingComma),
//            children: parameters
//        )
//    }
//}
