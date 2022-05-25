//
//  MetaData.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/16/22.
//

import Foundation

extension Symbol {
    /// A set of options to provide additional information as required for symbol processing.
    enum MetaData: Equatable {
        /// Specifies an [activation](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.2p2csry)
        /// for a program block symbol.
        case activation(String)

        /// Specifies the ``SymbolFactory/ProgramBlockType`` for a program block symbol.
        case blockType(SymbolFactory.ProgramBlockType)

        /// Represents a ``Token`` that has not yet been evaluated.
        ///
        /// Applies when a token was defined or quoted in the Zil source code.
        case eval(Token)

        /// Specifies that the symbol represents a literal value.
        case isLiteral

        /// Specifies whether the symbol represents a mutating value.
        ///
        /// When left unspecified, this is assumed to be `true`.
        case mutating(Bool)

        ///
        case paramDeclarations(String)

        /// Specifies a custom return value definition for the symbol.
        case type(String)
    }
}

extension Array where Element == Symbol.MetaData {
    /// Adds or replaces the specified ``Symbol/MetaData`` elements in the current array.
    ///
    /// - Parameter metaData: An array of `MetaData` elements to replace.
    ///
    /// - Returns: The `MetaData` array with the specified elements replaced.
    func assigning(_ metaData: [Symbol.MetaData]) -> [Symbol.MetaData] {
        var meta = self
        metaData.forEach { newMeta in
            for (index, element) in enumerated() {
                switch (element, newMeta) {
                case (.activation, .activation),
                     (.blockType, .blockType),
                     (.eval, .eval),
                     (.isLiteral, .isLiteral),
                     (.mutating, .mutating),
                     (.paramDeclarations, .paramDeclarations),
                     (.type, .type):
                    meta.remove(at: index)
                default: break
                }
            }
            meta.append(newMeta)
        }
        return meta
    }
}