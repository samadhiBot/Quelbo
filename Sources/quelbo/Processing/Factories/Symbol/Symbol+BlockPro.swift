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

        private var auxiliaries: [Symbol] = []
        private var warnings: [String] = []
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

    //        var children: [Symbol] {
    //            [codeSymbol, paramsSymbol]
    //        }

    var codeBlock: String {
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
        guard let deepParams = codeSymbol.children.deepParamDeclarations else {
            return ""
        }
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
            blockType?.setActivation("defaultAct")
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

    func warningComments(indented: Bool = false) -> String {
        emit(
            warnings,
            shouldIndent: indented
        )
    }
}
