//
//  MetaData.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/16/22.
//

import Foundation

extension Symbol {
    /// A set of options to provide additional information as required for symbol processing.
    enum MetaData: Hashable {
        /// Specifies an [activation](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.2p2csry)
        /// for a program block symbol.
        case activation(String)

        /// Specifies the ``SymbolFactory/ProgramBlockType`` for a program block symbol.
        case blockType(SymbolFactory.ProgramBlockType)

        /// Specifies an unevaluated Zil ``Token`` array.
        case zil([Token])

        /// Specifies an original Zil name.
        case zilName(String)

        /// Specifies that the symbol represents a literal value.
        case isLiteral

        /// Specifies that a literal `false` or `0` may indicate an empty value placeholder.
        case maybeEmptyValue

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
