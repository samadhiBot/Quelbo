////
////  MapFirst.swift
////  Quelbo
////
////  Created by Chris Sessions on 5/7/22.
////
//
//import Foundation
//
//extension Factories {
//    /// A symbol factory for the Zil
//    /// [MAPF](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.vq8v1tpbcqxn)
//    /// function.
//    class MapFirst: Factory {
//        override class var zilNames: [String] {
//            ["MAPF"]
//        }
//
//        private var appliedFactory: Factory.Type?
//        private var finalFactory: Factory.Type?
//
//        override func processTokens() throws {
//            var tokens = tokens
//            guard
//                let finalToken = tokens.shift(),
//                let appliedToken = tokens.shift()
//            else {
//                throw Error.missingMapFirstParameters(self.tokens)
//            }
//
//            switch finalToken {
//            case .bool(false):
//                break
//            case .global(let finalFunc):
//                finalFactory = Game.findFactory(finalFunc)
//            default:
//                throw Error.unimplementedFinalFunction(finalToken)
//            }
//
//            switch appliedToken {
//            case .form(var formTokens):
//                let name = try findName(in: &formTokens)
////                appliedFactory = Game.findFactory(try findName(in: &formTokens))
////            case .global(let appliedFunc):
////                appliedFactory = Game.findFactory(appliedFunc)
//            default:
//                throw Error.unimplementedAppliedFactory(appliedToken)
//            }
//
////            let symbol = try type(of: appliedFactory!).init([], with: &localVariables).process()
//
////            appliedFactory.init([], with: &localVariables)?.process()
//
////            let args = tokens.map { token in
////                switch token {
////                case .list(let listTokens):
////                    return listTokens
////                case .vector(let vectorTokens):
////                    return vectorTokens
////                default:
////                    throw
////                }
////            }
////
////            print("▶️", tokens)
////            symbols = try symbolize(tokens)
//        }
//
//        override func processSymbols() throws {
////            print("▶️", symbols)
//
//        }
//
//        override func process() throws -> Symbol {
//            .statement(
//                code: { _ in
//                    """
//                    """
//                },
//                type: .booleanFalse
//            )
//        }
//    }
//}
//
////extension Factories.MapFirst {
////    func processArgs(_ tokens: [Token]) -> [[Token]] {
////        guard !tokens.isEmpty else { return [] }
////
////        var args: [[Token]] = []
////        var index = 0
////
////        while index >= 0 {
////            var argTokens: [Token] = []
////            for token in tokens {
////                switch token {
////                case .list(let listTokens):
////                    guard index < listTokens.count else {
////                        return args
////                    }
////                    argTokens.append(listTokens[index])
////                case .vector(let vectorTokens):
////                    guard index < vectorTokens.count else {
////                        return args
////                    }
////                    argTokens.append(vectorTokens[index])
////                default:
////                    argTokens.append(token)
////                    index = .min
////                }
////            }
////            args.append(argTokens)
////            index += 1
////        }
////        return args
////    }
////}
//
//// MARK: - Errors
//
//extension Factories.MapFirst {
//    enum Error: Swift.Error {
//        case missingMapFirstParameters([Token])
//        case unimplementedAppliedFactory(Token)
//        case unimplementedFinalFunction(Token)
//        case unknownAppliedFactory(Token)
//    }
//}
