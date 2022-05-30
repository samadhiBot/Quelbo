////
////  SymbolFactory+evaluate.swift
////  Quelbo
////
////  Created by Chris Sessions on 5/22/22.
////
//
//import Foundation
//
//extension SymbolFactory {
//    func evaluate(_ token: Token) throws -> Token {
//        switch token {
//        case .atom(let string):
//            print("// 🍑 atom: \(string)")
//            throw FactoryError.unimplemented(self)
//        case .bool:
//            return token
//        case .character:
//            return token
//        case .commented:
//            return token
//        case .decimal:
//            return token
//        case .eval(let token):
//            print("// 🍑 eval: \(token)")
//            throw FactoryError.unimplemented(self)
//        case .form(let formTokens):
//            return try evaluateForm(formTokens)
//        case .global(let string):
//            print("// 🍑 global: \(string)")
//            throw FactoryError.unimplemented(self)
//        case .list(let array):
//            print("// 🍑 list: \(array)")
//            throw FactoryError.unimplemented(self)
//        case .local(let string):
//            print("// 🍑 local: \(string)")
//            throw FactoryError.unimplemented(self)
//        case .property(let string):
//            print("// 🍑 property: \(string)")
//            throw FactoryError.unimplemented(self)
//        case .quote(let token):
//            print("// 🍑 quote: \(token)")
//            throw FactoryError.unimplemented(self)
//        case .segment(let token):
//            print("// 🍑 segment: \(token)")
//            throw FactoryError.unimplemented(self)
//        case .string:
//            return token
//        case .type(let string):
//            print("// 🍑 type: \(string)")
//            throw FactoryError.unimplemented(self)
//        case .vector(let array):
//            print("// 🍑 vector: \(array)")
//            throw FactoryError.unimplemented(self)
//        }
//    }
//
//    func evaluateForm(_ formTokens: [Token]) throws -> Token {
//        var tokens = formTokens
//
//        let zil: String
//        switch tokens.shift() {
//        case .atom(let name):
//            zil = name
////        case .decimal(let nth):
////            zil = "NTH"
////            tokens.append(.decimal(nth))
////        case .form:
////            var nested = try symbolize(formTokens)
////            guard
////                let closure = nested.shift(),
////                closure.isFunctionClosure
////            else {
////                throw FactoryError.invalidZilForm(formTokens)
////            }
////            return Symbol(
////                "\(closure)(\(nested.codeValues(.commaSeparated)))",
////                type: closure.type,
////                children: nested
////            )
////        case .global(let name):
////            zil = name
//        default:
//            throw FactoryError.invalidZilForm(formTokens)
//        }
//
//        let factory: SymbolFactory
//        if let zMachine = try Game.zMachineSymbolFactories
//            .find(zil)?
//            .init(tokens, in: blockType)
//        {
//            factory = zMachine
//        } else {
//            factory = try Factories.Evaluate(formTokens)
//        }
//        let token = try factory.eval()
//        return token
//    }
//}
