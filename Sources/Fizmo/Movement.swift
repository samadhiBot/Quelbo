//
//  Movement.swift
//  Fizmo
//
//  Created by Chris Sessions on 3/22/22.
//

import Foundation

/// The set of ways to define movement in some direction.
public enum Movement: Equatable {
    case to(Room)
    case blocked(String)
    case conditional(Room, `if`: Bool )
    case conditionalElse(Room, `if`: Bool, `else`: String)
}
