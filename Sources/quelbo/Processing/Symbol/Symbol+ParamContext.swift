////
////  Symbol+ParamContext.swift
////  Quelbo
////
////  Created by Chris Sessions on 7/1/22.
////
//
//import Foundation
//
//extension Symbol {
//    /// Represents a parameter's context.
//    ///
//    /// The context under which a Zil parameter is declared determines the parameter's behavior.
//    enum ParamContext {
//        /// Describes a normal, required parameter.
//        case normal
//
//        /// Describes a local variable to be used within a block.
//        ///
//        /// In Zil the variable must be declared as an auxiliary parameter. In Swift it does not
//        /// appear in the list of parameters, and instead is declared at the start of the block.
//        case local
//
//        /// Describes an optional parameter.
//        case optional
//
//        /// Returns the default value assignment for the specified symbol, based on its type.
//        ///
//        /// - Parameter symbol: <#symbol description#>
//        ///
//        /// - Returns: <#description#>
//        func defaultValue(for symbol: Symbol) -> String {
//            guard self == .optional else { return "" }
//
//            switch symbol.type {
//            case .array: return "? = []"
//            case .bool: return " = false"
//            case .optional: return " = nil"
//            default: return "? = nil"
//            }
//        }
//    }
//}
//
