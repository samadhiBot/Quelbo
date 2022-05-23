//
//  Syntax.swift
//  Fizmo
//
//  Created by Chris Sessions on 5/5/22.
//

import Foundation

public struct Syntax: Equatable {
    public let verb: String
    public let directObject: Object?
    public let indirectObject: Object?
    public let actionRoutineName: String
    public let preActionRoutineName: String?

    public init(
        verb: String,
        directObject: Object? = nil,
        indirectObject: Object? = nil,
        actionRoutineName: String,
        preActionRoutineName: String? = nil
    ) {
        self.verb = verb
        self.directObject = directObject
        self.indirectObject = indirectObject
        self.actionRoutineName = actionRoutineName
        self.preActionRoutineName = preActionRoutineName
    }
}

extension Syntax {
    public struct Object: Equatable {
        public let preposition: String?
        public let findAttribute: Attribute?
        public let searchFlags: [SearchFlag]

        public init(
            preposition: String? = nil,
            where findAttribute: Attribute? = nil,
            search searchFlags: [SearchFlag] = []
        ) {
            self.preposition = preposition
            self.findAttribute = findAttribute
            self.searchFlags = searchFlags
        }
    }

    public enum SearchFlag: String {
        case carried  = "CARRIED"
        case have     = "HAVE"
        case held     = "HELD"
        case inRoom   = "IN-ROOM"
        case many     = "MANY"
        case onGround = "ON-GROUND"
        case take     = "TAKE"

        public var `case`: String {
            switch self {
            case .carried:  return ".carried"
            case .have:     return ".have"
            case .held:     return ".held"
            case .inRoom:   return ".inRoom"
            case .many:     return ".many"
            case .onGround: return ".onGround"
            case .take:     return ".take"
            }
        }
    }
}
