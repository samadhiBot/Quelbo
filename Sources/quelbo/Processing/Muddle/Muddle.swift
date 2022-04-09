////
////  Muddle.swift
////  Quelbo
////
////  Created by Chris Sessions on 2/26/22.
////
//
//import Foundation
//
//enum Muddle: String {
//    case constant          = "CONSTANT"
//    case define            = "DEFINE"
//    case defmac            = "DEFMAC"
//    case directions        = "DIRECTIONS"
//    case frequentWords     = "FREQUENT-WORDS?"
//    case global            = "GLOBAL"
//    case globalDeclaration = "GDECL"
//    case insertFile        = "INSERT-FILE"
//    case object            = "OBJECT"
//    case or                = "OR"
//    case princ             = "PRINC"
//    case propdef           = "PROPDEF"
//    case room              = "ROOM"
//    case routine           = "ROUTINE"
//    case set               = "SET"
//    case setg              = "SETG"
//    case version           = "VERSION"
//}
//
//extension Muddle {
//    enum Err: Error {
//        case unimplemented(String)
//    }
//
//    func process(_ tokens: [Token]) throws -> Definition? {
//        switch self {
//        case .constant:
//            var constant = Global(tokens)
//            return try constant.process()
//        case .define:
//            throw Err.unimplemented("define \(tokens)")
//        case .defmac:
//            throw Err.unimplemented("defmac \(tokens)")
//        case .directions:
//            let directions = Directions(tokens)
//            return try directions.process()
//        case .frequentWords:
//            throw Err.unimplemented("frequentWords \(tokens)")
//        case .global:
//            var global = Global(tokens, isMutable: true)
//            return try global.process()
//        case .globalDeclaration:
//            return nil // Ignored
//        case .insertFile:
//            return nil // Ignored
//        case .object:
//            var object = Object(.object, tokens)
//            return try object.process()
//        case .or:
//            throw Err.unimplemented("or \(tokens)")
//        case .princ:
//            throw Err.unimplemented("princ \(tokens)")
//        case .propdef:
//            throw Err.unimplemented("propdef \(tokens)")
//        case .room:
//            var room = Object(.room, tokens)
//            return try room.process()
//        case .routine:
//            var routine = Routine(tokens)
//            return try routine.process()
//        case .set:
//            throw Err.unimplemented("set \(tokens)")
//        case .setg:
//            throw Err.unimplemented("setg \(tokens)")
//        case .version:
//            return nil // Ignored
//        }
//    }
//}
