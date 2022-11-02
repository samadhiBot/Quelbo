//
//  Statement.swift
//  Quelbo
//
//  Created by Chris Sessions on 7/9/22.
//

/*
 import CustomDump
 import Foundation

 final class Statement: SymbolType, Identifiable {
     let id: String
     private(set) var category: Category?
     private(set) var isMutable: Bool?
     private(set) var type: TypeInfo

     init(
         id: String,
         type: TypeInfo,
         category: Category? = nil,
         isMutable: Bool? = nil
     ) {
         self.category = category
         self.id = id
         self.isMutable = isMutable
         self.type = type
     }

     var code: String {
         id
     }
 }

 // MARK: - Symbol Statement initializer

 extension Symbol {
     static func variable(
         id: String,
         type: TypeInfo,
         category: Category? = nil,
         isMutable: Bool? = nil
     ) -> Symbol {
         .statement(Statement(
             id: id,
             type: type,
             category: category,
             isMutable: isMutable
         ))
     }
 }

 //extension Statement {
 //    private var memAddress: String {
 //        String(ObjectIdentifier(self)
 //            .debugDescription
 //            .dropFirst(31)
 //            .dropLast(1))
 //    }
 //}

 // MARK: - Special assertion handlers

 extension Statement {
     func assertHasCategory(_ assertionCategory: Category) throws {
         if let category = category, assertionCategory != category {
             throw Symbol.AssertionError.hasCategoryAssertionFailed(
                 for: "\(self)",
                 asserted: assertionCategory,
                 actual: category
             )
         }
         self.category = assertionCategory
     }

     func assertHasCommonType(with symbols: [Symbol]) throws {
         for symbol in symbols {
             print("🐻", symbol)
             try assertHasType(symbol.type)
 //            if symbol === self { continue }
 //            try symbol.assertHasType(type)
 //            switch symbol {
 //            case .definition, .literal, .statement:
 //                try variable.assertHasCommonType(with: self)
 ////                continue
 ////                typeSiblings.append(symbol)
 //            case .instance(let instance):
 //                guard instance.variable != self else { continue }
 ////                typeSiblings.append(symbol)
 ////                try instance.variable.assertHasCommonType(with: self)
 //                try instance.variable.assertHasType(type)
 //            case .statement(let variable):
 //                guard variable != self else {
 //                    continue
 //                }
 ////                typeSiblings.append(symbol)
 //                try variable.assertHasCommonType(with: self)
 //            }
         }
     }

 //    func assertHasCommonType(with variable: Statement) throws {
 //        try variable.assertHasType(type)
 ////        let symbol: Symbol = .statement(variable)
 ////        if !typeSiblings.contains(symbol) { typeSiblings.append(symbol) }
 //    }

     func assertHasMutability(_ mutability: Bool) throws {
         switch isMutable {
         case mutability: return
         case .none: isMutable = mutability
         default:
             throw Symbol.AssertionError.hasMutabilityAssertionFailed(
                 for: "\(Self.self)",
                 asserted: mutability,
                 actual: isMutable
             )
         }
     }

     func assertHasType(_ assertedType: TypeInfo) throws {
 //        try type.reconcile(".statement(\(id))", with: assertedType)

         if let global = Game.globals.find(id) {
             try global.assertHasType(type)
         }
     }
 }

 // MARK: - Conformances

 extension Statement: CustomDumpReflectable {
     var customDumpMirror: Mirror {
         .init(
             self,
             children: [
                 "id": self.id,
                 "type": self.type as Any,
                 "category": self.category as Any,
                 "isMutable": self.isMutable as Any,
             ],
             displayStyle: .struct
         )
     }
 }

 extension Statement: Equatable {
     static func == (lhs: Statement, rhs: Statement) -> Bool {
         lhs.category == rhs.category &&
         lhs.code == rhs.code &&
         lhs.id == rhs.id &&
         lhs.type == rhs.type
     }
 }

 extension Array where Element == Statement {
     mutating func commit(_ variable: Statement) throws {
         guard let existing = first(where: { $0.id == variable.id }) else {
             append(variable)
             return
         }

         let oldVariable: Symbol = .statement(existing)
         let newVariable: Symbol = .statement(variable)

         try oldVariable.assert(
             .hasSameCategory(as: newVariable)
         )

         try oldVariable.assert(
             .hasType(newVariable.type)
         )
     }
 }
 */
