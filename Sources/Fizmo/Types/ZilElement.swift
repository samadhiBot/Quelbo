//
//  ZilElement.swift
//  Fizmo
//
//  Created by Chris Sessions on 3/19/22.
//

import Foundation

/// Elements contained in arrays corresponding to ZIL Tables.
public enum ZilElement {
    case bool(Bool)
    case int(Int)
    case object(String)
    case room(String)
    case string(String)
    case table([ZilElement])
}
