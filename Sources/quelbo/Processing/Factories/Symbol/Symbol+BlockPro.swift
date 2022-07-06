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

        init(for symbol: Symbol) {
            self.codeSymbol = symbol.children[0]
            self.paramsSymbol = symbol.children[1]
        }
    }
}

extension Symbol.BlockPro {
    /// The block activation, if one has been assigned.
    var activation: String? {
        if case .block(activation: let activation) = codeSymbol.controlflow {
            return activation
        }
        return [codeSymbol].deepActivation
    }

    var activationCode: String {
        guard let activation = activation else { return "" }

        return "\(activation): "
    }

    /// <#Description#>
    var auxiliaries: [Symbol] {
        paramsSymbol.children.filter { $0.isParamWith(context: .local) }
    }

    /// <#Description#>
    /// - Parameter indented: <#indented description#>
    /// - Returns: <#description#>
    func auxiliaryDefs(indented: Bool = false) -> String {
        emit(
            auxiliaries.compactMap {
                guard !$0.code.contains("=") else { return nil }

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
                guard $0.code.contains("=") else { return nil }

                return $0.localVariable
            },
            shouldIndent: indented
        )
    }

    /// <#Description#>
    /// - Returns: <#description#>
    func codeBlock() -> String {
        if codeSymbol.children.deepRepeating == true {
            print(
                """
                // 🍊 Symbol.BlockPro (no-repeat):

                \(deepParameters)\
                \(activationCode)\
                while true {
                \(auxiliaryDefsWithDefaultValues(indented: true))\
                \(codeSymbol.code.indented)
                }

                """
            )
            return """
                \(deepParameters)\
                \(activationCode)\
                while true {
                \(auxiliaryDefsWithDefaultValues(indented: true))\
                \(codeSymbol.code.indented)
                }
                """
        } else {
            print(
                """
                // 🍊 Symbol.BlockPro (no-repeat):

                \(auxiliaryDefsWithDefaultValues())\
                \(codeSymbol.code)
                
                """
            )
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
//    var isRepeating: Bool {
//        codeSymbol.children.deepRepeating == true
//    }

    /// <#Description#>
//    var metaData: Set<Symbol.MetaData> {
//
//        return []
////        guard let type = blockType else { return [] }
////
////        switch type {
////        case .repeatingWithoutActivation:
////            let params = paramsSymbol.children
////                .map { $0.localVariable }
////                .joined(separator: "\n")
////            return [
////                .blockType(type),
////                .paramDeclarations(params),
////            ]
////        default:
////            return [.blockType(type)]
////        }
//    }

    /// <#Description#>
    var normalAndOptionalParams: [Symbol] {
        paramsSymbol.children.filter {
            $0.isParamWith(context: .normal) || $0.isParamWith(context: .optional)
        }
    }

    /// <#Description#>
    /// - Parameter indented: <#indented description#>
    /// - Returns: <#description#>
    func paramDeclarations(indented: Bool = false) -> String {
        if codeSymbol.children.deepRepeating == true && activationCode.isEmpty {
            return ""
        }

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
}
