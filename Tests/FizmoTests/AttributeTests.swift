//
//  AttributeTests.swift
//  Fizmo
//
//  Created by Chris Sessions on 3/19/22.
//

import CustomDump
import XCTest
import Fizmo

final class AttributeTests: XCTestCase {
    func testAttributes() {
        XCTAssertEqual(Attribute(rawValue: "ACTORBIT"),   Attribute.actor)
        XCTAssertEqual(Attribute(rawValue: "BURNBIT"),    Attribute.burnable)
        XCTAssertEqual(Attribute(rawValue: "CLIMBBIT"),   Attribute.climbable)
        XCTAssertEqual(Attribute(rawValue: "CONTBIT"),    Attribute.container)
        XCTAssertEqual(Attribute(rawValue: "DOORBIT"),    Attribute.door)
        XCTAssertEqual(Attribute(rawValue: "DRINKBIT"),   Attribute.drinkable)
        XCTAssertEqual(Attribute(rawValue: "FIGHTBIT"),   Attribute.fightable)
        XCTAssertEqual(Attribute(rawValue: "FLAMEBIT"),   Attribute.flame)
        XCTAssertEqual(Attribute(rawValue: "FOODBIT"),    Attribute.food)
        XCTAssertEqual(Attribute(rawValue: "INVISIBLE"),  Attribute.invisible)
        XCTAssertEqual(Attribute(rawValue: "LIGHTBIT"),   Attribute.light)
        XCTAssertEqual(Attribute(rawValue: "MAZEBIT"),    Attribute.maze)
        XCTAssertEqual(Attribute(rawValue: "NDESCBIT"),   Attribute.noDescribe)
        XCTAssertEqual(Attribute(rawValue: "NONLANDBIT"), Attribute.nonLand)
        XCTAssertEqual(Attribute(rawValue: "ONBIT"),      Attribute.on)
        XCTAssertEqual(Attribute(rawValue: "OPENBIT"),    Attribute.openable)
        XCTAssertEqual(Attribute(rawValue: "READBIT"),    Attribute.readable)
        XCTAssertEqual(Attribute(rawValue: "RLANDBIT"),   Attribute.rLand)
        XCTAssertEqual(Attribute(rawValue: "RMUNGBIT"),   Attribute.rMung)
        XCTAssertEqual(Attribute(rawValue: "SACREDBIT"),  Attribute.sacred)
        XCTAssertEqual(Attribute(rawValue: "SEARCHBIT"),  Attribute.searchable)
        XCTAssertEqual(Attribute(rawValue: "STAGGERED"),  Attribute.staggered)
        XCTAssertEqual(Attribute(rawValue: "SURFACEBIT"), Attribute.surface)
        XCTAssertEqual(Attribute(rawValue: "TAKEBIT"),    Attribute.takeable)
        XCTAssertEqual(Attribute(rawValue: "TOOLBIT"),    Attribute.tool)
        XCTAssertEqual(Attribute(rawValue: "TOUCHBIT"),   Attribute.touchable)
        XCTAssertEqual(Attribute(rawValue: "TRANSBIT"),   Attribute.trans)
        XCTAssertEqual(Attribute(rawValue: "TRYTAKEBIT"), Attribute.tryTake)
        XCTAssertEqual(Attribute(rawValue: "TURNBIT"),    Attribute.turnable)
        XCTAssertEqual(Attribute(rawValue: "VEHBIT"),     Attribute.vehicle)
        XCTAssertEqual(Attribute(rawValue: "WEAPONBIT"),  Attribute.weapon)
        XCTAssertEqual(Attribute(rawValue: "WEARBIT"),    Attribute.wearable)
        XCTAssertEqual(Attribute(rawValue: "WORNBIT"),    Attribute.wornbit)
    }

    func testCase() {
        XCTAssertEqual(Attribute.actor.case,      ".actor")
        XCTAssertEqual(Attribute.burnable.case,   ".burnable")
        XCTAssertEqual(Attribute.climbable.case,  ".climbable")
        XCTAssertEqual(Attribute.container.case,  ".container")
        XCTAssertEqual(Attribute.door.case,       ".door")
        XCTAssertEqual(Attribute.drinkable.case,  ".drinkable")
        XCTAssertEqual(Attribute.fightable.case,  ".fightable")
        XCTAssertEqual(Attribute.flame.case,      ".flame")
        XCTAssertEqual(Attribute.food.case,       ".food")
        XCTAssertEqual(Attribute.invisible.case,  ".invisible")
        XCTAssertEqual(Attribute.light.case,      ".light")
        XCTAssertEqual(Attribute.maze.case,       ".maze")
        XCTAssertEqual(Attribute.noDescribe.case, ".noDescribe")
        XCTAssertEqual(Attribute.nonLand.case,    ".nonLand")
        XCTAssertEqual(Attribute.on.case,         ".on")
        XCTAssertEqual(Attribute.openable.case,   ".openable")
        XCTAssertEqual(Attribute.readable.case,   ".readable")
        XCTAssertEqual(Attribute.rLand.case,      ".rLand")
        XCTAssertEqual(Attribute.rMung.case,      ".rMung")
        XCTAssertEqual(Attribute.sacred.case,     ".sacred")
        XCTAssertEqual(Attribute.searchable.case, ".searchable")
        XCTAssertEqual(Attribute.staggered.case,  ".staggered")
        XCTAssertEqual(Attribute.surface.case,    ".surface")
        XCTAssertEqual(Attribute.takeable.case,   ".takeable")
        XCTAssertEqual(Attribute.tool.case,       ".tool")
        XCTAssertEqual(Attribute.touchable.case,  ".touchable")
        XCTAssertEqual(Attribute.trans.case,      ".trans")
        XCTAssertEqual(Attribute.tryTake.case,    ".tryTake")
        XCTAssertEqual(Attribute.turnable.case,   ".turnable")
        XCTAssertEqual(Attribute.vehicle.case,    ".vehicle")
        XCTAssertEqual(Attribute.weapon.case,     ".weapon")
        XCTAssertEqual(Attribute.wearable.case,   ".wearable")
        XCTAssertEqual(Attribute.wornbit.case,    ".wornbit")
    }
}
