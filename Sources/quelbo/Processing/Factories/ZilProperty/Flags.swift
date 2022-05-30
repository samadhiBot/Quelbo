//
//  Flags.swift
//  Quelbo
//
//  Created by Chris Sessions on 4/15/22.
//

import Foundation

extension Factories {
    /// A symbol factory for the `FLAGS` property of a Zil
    /// [OBJECT](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.38czs75)
    /// type.
    class Flags: ZilPropertyFactory {
        override class var zilNames: [String] {
            ["FLAGS"]
        }

        override class var parameters: Parameters {
            .oneOrMore(.bool)
        }

        override class var returnType: Symbol.DataType {
            .array(.bool)
        }

        override func processTokens() throws {
            try super.processTokens()

            symbols = try symbols.map { symbol in
                if let flag = try? Game.find(symbol.id, category: .flags) {
                    return flag
                } else {
                    let flagCode: String
                    if let known = FlagLookup(rawValue: symbol.id.rawValue) {
                        flagCode = known.rawValue
                    } else {
                        flagCode = symbol.id.rawValue
                    }
                    let flag = symbol.with(code: flagCode, category: .flags)
                    try Game.commit(flag)
                    return flag
                }
            }
        }

        override func process() throws -> Symbol {
            Symbol(
                id: "flags",
                code: "flags: [\(symbols.sorted.codeValues(.commaSeparated))]",
                type: Self.returnType,
                children: symbols
            )
        }
    }
}

// MARK: - FlagLookup

enum FlagLookup: String {
    case beginsWithVowel
    case catchesDroppedItems
    case hasBeenTouched
    case inNotOn
    case isActor
    case isAttackable
    case isBeingWorn
    case isBodyPart
    case isBurnable
    case isClimbable
    case isContainer
    case isDestroyed
    case isDevice
    case isDoor
    case isDrinkable
    case isDryLand
    case isEdible
    case isFemale
    case isFightable
    case isFlammable
    case isFood
    case isIntegral
    case isInvisible
    case isLight
    case isLocked
    case isMaze
    case isMidAirLocation
    case isNotLand
    case isOn
    case isOpen
    case isOpenable
    case isOutside
    case isPerson
    case isPlural
    case isReadable
    case isSacred
    case isSearchable
    case isStaggered
    case isSurface
    case isTakable
    case isTool
    case isTransparent
    case isTurnable
    case isVehicle
    case isWaterLocation
    case isWeapon
    case isWearable
    case noImplicitTake
    case omitArticle
    case omitDescription
    case omitFromTakeAll
    case shouldKludge

    init?(rawValue: String) {
        switch rawValue {
        case "vowelBit":    self = .beginsWithVowel
        case "dropBit":     self = .catchesDroppedItems
        case "touchBit":    self = .hasBeenTouched
        case "inBit":       self = .inNotOn
        case "actorBit":    self = .isActor
        case "attackBit":   self = .isAttackable
        case "wornBit":     self = .isBeingWorn
        case "partBit":     self = .isBodyPart
        case "burnBit":     self = .isBurnable
        case "climbBit":    self = .isClimbable
        case "contBit":     self = .isContainer
        case "rmungBit":    self = .isDestroyed
        case "deviceBit":   self = .isDevice
        case "doorBit":     self = .isDoor
        case "drinkBit":    self = .isDrinkable
        case "rlandBit":    self = .isDryLand
        case "edibleBit":   self = .isEdible
        case "femaleBit":   self = .isFemale
        case "fightBit":    self = .isFightable
        case "flameBit":    self = .isFlammable
        case "foodBit":     self = .isFood
        case "integralBit": self = .isIntegral
        case "invisible":   self = .isInvisible
        case "lightBit":    self = .isLight
        case "lockedBit":   self = .isLocked
        case "mazeBit":     self = .isMaze
        case "rairBit":     self = .isMidAirLocation
        case "nonlandBit":  self = .isNotLand
        case "onBit":       self = .isOn
        case "openBit":     self = .isOpen
        case "openableBit": self = .isOpenable
        case "outsideBit":  self = .isOutside
        case "personBit":   self = .isPerson
        case "pluralBit":   self = .isPlural
        case "readBit":     self = .isReadable
        case "sacredBit":   self = .isSacred
        case "searchBit":   self = .isSearchable
        case "staggered":   self = .isStaggered
        case "surfaceBit":  self = .isSurface
        case "takeBit":     self = .isTakable
        case "toolBit":     self = .isTool
        case "transBit":    self = .isTransparent
        case "turnBit":     self = .isTurnable
        case "vehBit":      self = .isVehicle
        case "rwaterBit":   self = .isWaterLocation
        case "weaponBit":   self = .isWeapon
        case "wearBit":     self = .isWearable
        case "trytakeBit":  self = .noImplicitTake
        case "narticleBit": self = .omitArticle
        case "ndescBit":    self = .omitDescription
        case "nallBit":     self = .omitFromTakeAll
        case "kludgeBit":   self = .shouldKludge
        default:            return nil
        }
    }
}
