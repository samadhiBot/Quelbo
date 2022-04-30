//
//  Attribute.swift
//  Fizmo
//
//  Created by Chris Sessions on 3/19/22.
//

import Foundation

/// An `Attribute` specifies additional ways the player can interact with a Room or Object.
/// 
public enum Attribute: String {
    case actor      = "ACTORBIT"
    case burnable   = "BURNBIT"
    case climbable  = "CLIMBBIT"
    case container  = "CONTBIT"
    case door       = "DOORBIT"
    case drinkable  = "DRINKBIT"
    case fightable  = "FIGHTBIT"
    case flame      = "FLAMEBIT"
    case food       = "FOODBIT"
    case invisible  = "INVISIBLE"
    case light      = "LIGHTBIT"
    case maze       = "MAZEBIT"
    case noDescribe = "NDESCBIT"
    case nonLand    = "NONLANDBIT"
    case on         = "ONBIT"
    case openable   = "OPENBIT"
    case readable   = "READBIT"
    case rLand      = "RLANDBIT"
    case rMung      = "RMUNGBIT"
    case sacred     = "SACREDBIT"
    case searchable = "SEARCHBIT"
    case staggered  = "STAGGERED"
    case surface    = "SURFACEBIT"
    case takeable   = "TAKEBIT"
    case tool       = "TOOLBIT"
    case touchable  = "TOUCHBIT"
    case trans      = "TRANSBIT"
    case tryTake    = "TRYTAKEBIT"
    case turnable   = "TURNBIT"
    case vehicle    = "VEHBIT"
    case weapon     = "WEAPONBIT"
    case wearable   = "WEARBIT"
    case wornbit    = "WORNBIT"
}

extension Attribute {
    public init(_ rawValue: String) throws {
        enum Err: Error {
            case unknownAttribute(String)
        }

        guard let attribute = Attribute(rawValue: rawValue) else {
            throw Err.unknownAttribute(rawValue)
        }
        self = attribute
    }

    public var `case`: String {
        switch self {
        case .actor:      return ".actor"
        case .burnable:   return ".burnable"
        case .climbable:  return ".climbable"
        case .container:  return ".container"
        case .door:       return ".door"
        case .drinkable:  return ".drinkable"
        case .fightable:  return ".fightable"
        case .flame:      return ".flame"
        case .food:       return ".food"
        case .invisible:  return ".invisible"
        case .light:      return ".light"
        case .maze:       return ".maze"
        case .noDescribe: return ".noDescribe"
        case .nonLand:    return ".nonLand"
        case .on:         return ".on"
        case .openable:   return ".openable"
        case .readable:   return ".readable"
        case .rLand:      return ".rLand"
        case .rMung:      return ".rMung"
        case .sacred:     return ".sacred"
        case .searchable: return ".searchable"
        case .staggered:  return ".staggered"
        case .surface:    return ".surface"
        case .takeable:   return ".takeable"
        case .tool:       return ".tool"
        case .touchable:  return ".touchable"
        case .trans:      return ".trans"
        case .tryTake:    return ".tryTake"
        case .turnable:   return ".turnable"
        case .vehicle:    return ".vehicle"
        case .weapon:     return ".weapon"
        case .wearable:   return ".wearable"
        case .wornbit:    return ".wornbit"
        }
    }
}
