//
//  Symbol+MetaData.swift
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
//        case activation(String)

        ///
//        case blockType(SymbolFactory.ProgramBlockType)

        ///
//        case isAgainStatement

        ///
        case controlFlow(ControlFlow)

        /// Specifies that the symbol represents an immutable value.
        ///
        /// Unless this is present, symbols are assumed to represent mutable instances.
        case isImmutable

        /// Specifies that the symbol represents a literal value.
        case isLiteral

        /// Specifies that the symbol represents a mutating variable.
        case isMutating

        /// For symbols representing parameters, this specifies the context (`normal`, `local` or
        /// `optional`) in which the Zil parameter has been declared.
        case paramContext(Symbol.ParamContext)

        /// Specifies special parameter declarations in certain block processing cases.
        case paramDeclarations(String)

        /// Specifies a custom return value definition for the symbol.
        case type(String)

        /// Specifies the symbol's confidence in its stated data type, from zero to one.
        ///
        /// A symbol with ``Symbol/DataType-swift.enum/unknown`` has zero type confidence. One with
        /// a literal `false` or `0` typically has low confidence, because that may be an empty
        /// value placeholder.
        case typeCertainty(TypeCertainty)

        /// Specifies an unevaluated Zil ``Token`` array.
        case zil([Token])

        /// Specifies an original Zil name.
        case zilName(String)
    }
}

// MARK: - Symbol.MetaData.ControlFlow

extension Symbol.MetaData {
    /// <#Description#>
    enum ControlFlow: Hashable {
        /// Specifies that the symbol represents an ``Factories/Again`` statement.
        case again(activation: String?)

        /// Specifies that the symbol represents a ``Factories/ProgramBlock`` or
        /// ``Factories/Repeat`` statement.
        case block(activation: String?, repeating: Bool)

        /// Specifies that the symbol represents a ``Factories/Return`` statement, with the
        /// specified activation referring to the appropriate statement label.
        case `return`(activation: String?)

        /// Specifies that the symbol represents a ``Factories/Return`` statement, with the
        /// specified return type if it returns a value.
        case returnValue(type: Symbol.DataType?)
    }
}

// MARK: - Symbol.MetaData.TypeCertainty

extension Symbol.MetaData {
    /// The level of confidence in a symbol's stated ``Symbol/type``.
    enum TypeCertainty: Int {
        /// The stated `type` is unknown, which provides no certainty.
        case unknown

        /// The symbol is declared as an array, optional, property or variable, but its  element
        /// type is not yet known.
        case partiallyKnown

        /// The symbol is declared as a boolean with a `false` value, which often represents a
        /// `nil` placeholder for an object.
        case booleanFalse

        /// The symbol is declared as an integer with a `0` value, which can represent a `nil`
        /// placeholder for an object.
        case integerZero

        /// The symbol represents a local value, whose type must be discovered through its actual
        /// use.
        case localValue

        /// The symbol's type is known.
        case certain
    }
}

// MARK: - Conformances

extension Symbol.MetaData.TypeCertainty: Comparable {
    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

// MARK: - Set where Element == Symbol.MetaData

extension Set where Element == Symbol.MetaData {
    /// <#Description#>
    /// - Parameter other: <#other description#>
    /// - Returns: <#description#>
    func withTypeCertainty(of other: Symbol) -> Self {
        let otherTypeCertainty = other.typeCertainty
        if otherTypeCertainty == .certain {
            return withoutTypeCertainty
        } else {
            return withoutTypeCertainty.union([.typeCertainty(otherTypeCertainty)])
        }
    }

    /// <#Description#>
    var withoutTypeCertainty: Self {
        filter {
            if case .typeCertainty = $0 { return false } else { return true }
        }
    }

    /// <#Description#>
    var erasingLocalParamContext: Self {
        guard contains(.paramContext(.local)) else { return self }

        return filter {
            if case .paramContext(.local) = $0 { return false } else { return true }
        }.union([
            .paramContext(.normal)
        ])
    }
}
