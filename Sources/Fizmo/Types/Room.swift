//
//  Room.swift
//  Fizmo
//
//  Created by Chris Sessions on 3/19/22.
//

import Foundation

/// Rooms are distinct locations in the world.
/// 
public struct Room {
    public let action: Function?
    public let adjectives: [String]
    public let attributes: [Attribute]
    public let capacity: Int?
    public let description: String?
    public let descriptionFunction: String?
    public let directions: [Direction: Movement]
    public let firstDescription: String?
    public let globals: [Object]
    public let longDescription: String?
    public let name: String
    public let pseudos: [String: Function]
    public let size: Int?
    public let strength: Int?
    public let synonyms: [String]
    public let text: String?
    public let value: Int?
    public let vType: Attribute?

    private var _parent: [Room]

    public init(
        name: String,
        action: Function? = nil,
        adjectives: [String] = [],
        attributes: [Attribute] = [],
        capacity: Int? = nil,
        description: String? = nil,
        descriptionFunction: String? = nil,
        directions: [Direction: Movement] = [:],
        firstDescription: String? = nil,
        globals: [Object] = [],
        longDescription: String? = nil,
        parent: Room? = nil,
        pseudos: [String: Function] = [:],
        size: Int? = nil,
        strength: Int? = nil,
        synonyms: [String] = [],
        text: String? = nil,
        value: Int? = nil,
        vType: Attribute? = nil
    ) {
        self.action = action
        self.adjectives = adjectives
        self.attributes = attributes
        self.capacity = capacity
        self.description = description
        self.descriptionFunction = descriptionFunction
        self.directions = directions
        self.firstDescription = firstDescription
        self.globals = globals
        self.longDescription = longDescription
        self.name = name
        if let parent = parent {
            self._parent = [parent]
        } else {
            self._parent = []
        }
        self.pseudos = pseudos
        self.size = size
        self.strength = strength
        self.synonyms = synonyms
        self.text = text
        self.value = value
        self.vType = vType
    }

    public var parent: Room {
        get {
            return _parent[0]
        }
        set {
            _parent = [newValue]
        }
    }
}

extension Room: Equatable {
    public static func == (lhs: Room, rhs: Room) -> Bool {
        lhs.name == rhs.name
    }
}
