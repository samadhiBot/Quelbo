//
//  Object.swift
//  Fizmo
//
//  Created by Chris Sessions on 3/19/22.
//

import Foundation

public typealias Function = () -> Bool

/// Objects are things in the world with which the player can interact.
///
public struct Object {
    public let action: Function?
    public let adjectives: [String]
    public let attributes: [Attribute]
    public let capacity: Int?
    public let description: String?
    public let descriptionFunction: String?
    public let firstDescription: String?
    public let globals: [Object]
    public let longDescription: String?
    public let name: String?
    public var parent: Room?
    public let pseudos: [String: Function]
    public let size: Int?
    public let strength: Int?
    public let synonyms: [String]
    public let takeValue: Int?
    public let text: String?
    public let value: Int?
    public let vType: Attribute?

    public init(
        name: String,
        action: Function? = nil,
        adjectives: [String] = [],
        attributes: [Attribute] = [],
        capacity: Int? = nil,
        description: String? = nil,
        descriptionFunction: String? = nil,
        firstDescription: String? = nil,
        globals: [Object] = [],
        longDescription: String? = nil,
        parent: Room? = nil,
        pseudos: [String: Function] = [:],
        size: Int? = nil,
        strength: Int? = nil,
        synonyms: [String] = [],
        takeValue: Int? = nil,
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
        self.firstDescription = firstDescription
        self.globals = globals
        self.longDescription = longDescription
        self.name = name
        self.parent = parent
        self.pseudos = pseudos
        self.size = size
        self.strength = strength
        self.synonyms = synonyms
        self.takeValue = takeValue
        self.text = text
        self.value = value
        self.vType = vType
    }

    /// Evaluates whether `self` is located directly inside the specified ``Object``.
    ///
    /// - Parameter object: The object in which to look for `self`.
    ///
    /// - Returns: Whether `self` is in the specified object.
    func isIn(_ object: Object) -> Bool {
        return true
    }

    /// Evaluates whether `self` is located directly inside the specified ``Room``.
    ///
    /// - Parameter room: The room in which to look for `self`.
    ///
    /// - Returns: Whether `self` is in the specified room.
    func isIn(_ room: Room) -> Bool {
        return true
    }

    /// Change the location of `self` to the specified ``Object``.
    ///
    /// - Parameter to: The object to which `self` is moved.
    func move(to: Object) {

    }

    /// Change the location of `self` to the specified ``Room``.
    ///
    /// - Parameter to: The room to which `self` is moved.
    func move(to: Room) {

    }
}
