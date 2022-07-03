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
//        var blockType: SymbolFactory.ProgramBlockType?

        init(for symbol: Symbol) {
            self.codeSymbol = symbol.children[0]
            self.paramsSymbol = symbol.children[1]
//            self.blockType = symbol.blockType
        }
    }
}

extension Symbol.BlockPro {
    /// The block activation, if one has been assigned.
    var activation: String {
        if let activation = [codeSymbol].deepActivation {
            return "\(activation): "
        } else {
            return ""
        }
//
//        switch codeSymbol.controlflow {
////        case .blockWithActivation(let activation):
////            return "\(activation): "
////        case .repeatingWithActivation(let activation):
////            return "\(activation): "
////        default:
////            return ""
//        case .again(activation: let activation):
//            return activation
//        case .block(activation: let activation):
//            return activation
//        case .return(activation: let activation):
//            return activation
//        default:
//            return nil
//        }
    }

    /// <#Description#>
    var auxiliaries: [Symbol] {
        paramsSymbol.children.filter { $0.isParamWith(context: .local) }
    }

    /// <#Description#>
    var normalAndOptionalParams: [Symbol] {
        paramsSymbol.children.filter { !$0.isParamWith(context: .local) }
    }

    /// <#Description#>
    /// - Parameter indented: <#indented description#>
    /// - Returns: <#description#>
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

    /// <#Description#>
    /// - Parameter indented: <#indented description#>
    /// - Returns: <#description#>
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

    /// <#Description#>
    /// - Returns: <#description#>
    mutating func codeBlock() -> String {
        if isRepeating {
            print("// 🍊 Symbol.BlockPro: \(codeSymbol.code)")
            return """
                \(deepParameters)\
                \(activation)\
                while true {
                \(auxiliaryDefsWithDefaultValues(indented: true))\
                \(codeSymbol.code.indented)
                }
                """
        } else {
            print("// 🍊 Symbol.BlockPro (no-repeat): \(codeSymbol.code)")
            return """
                \(auxiliaryDefsWithDefaultValues())\
                \(codeSymbol.code)
                """
        }
    }

    /// <#Description#>
    var deepParameters: String {
        guard let deepParams = codeSymbol.children.deepParamDeclarations else { return "" }

        return deepParams.appending("\n")
    }

    /// <#Description#>
    var discardableResult: String {
        codeSymbol.type.hasReturnValue ? "@discardableResult\n" : ""
    }

    /// <#Description#>
    /// - Parameters:
    ///   - values: <#values description#>
    ///   - shouldIndent: <#shouldIndent description#>
    /// - Returns: <#description#>
    func emit(
        _ values: [String],
        shouldIndent: Bool
    ) -> String {
        guard !values.isEmpty else { return "" }
//        print("// 🫐 \(values)")
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

    /// <#Description#>
    var isRepeating: Bool {
        [codeSymbol].deepRepeating == true
//        if case .again = codeSymbol.controlflow { return true }
//
//        if [codeSymbol].deepRepeating == true {
////            blockType?.setActivation("defaultAct")
//            return true
//        }
//        return false
//
//
//
//        switch codeSymbol.controlflow! {
//        case .again(activation: let activation):
//            <#code#>
//        case .block(activation: let activation):
//            <#code#>
//        case .return(activation: let activation):
//            <#code#>
//        case .returnValue(type: let type):
//            <#code#>
//        }
//        if blockType?.isRepeating == true {
//            return true
//        }
//        if [codeSymbol, paramsSymbol].deepRepeating == true {
//            blockType?.setActivation("defaultAct")
//            return true
//        }
//        return false
    }

    /// <#Description#>
    var metaData: Set<Symbol.MetaData> {
        return []
//        guard let type = blockType else { return [] }
//
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

    /// <#Description#>
    /// - Parameter indented: <#indented description#>
    /// - Returns: <#description#>
    func paramDeclarations(indented: Bool = false) -> String {
        if isRepeating && activation == nil {
            return ""
        }
//        guard blockType != .repeatingWithoutActivation else { return "" }

        return emit(
            normalAndOptionalParams.map { $0.localVariable },
            shouldIndent: indented
        )
    }

    /// <#Description#>
    var returnValue: String {
        codeSymbol.type.hasReturnValue ? " -> \(codeSymbol.type)" : ""
    }

    /// <#Description#>
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
