//
//  Instance.swift
//  Quelbo
//
//  Created by Chris Sessions on 7/9/22.
//

import CustomDump
import Foundation

final class Instance: SymbolType {
    let _isArray: Bool?
    let _isMutable: Bool?
    let _isOptional: Bool?
    let _isProperty: Bool?
    let _isTableElement: Bool?
    let context: Context
    let defaultValue: Symbol?
    let variable: Statement
    private(set) var returnHandling: Symbol.ReturnHandling

    init(
        _ variable: Statement,
        context: Context = .normal,
        isArray: Bool? = nil,
        isMutable: Bool? = nil,
        isOptional: Bool? = nil,
        isProperty: Bool? = nil,
        isTableElement: Bool? = nil
    ) {
        self._isArray = isArray
        self._isMutable = isMutable
        self._isOptional = isOptional
        self._isProperty = isProperty
        self._isTableElement = isTableElement
        self.context = context
        self.defaultValue = nil
        self.returnHandling = .forced
        self.variable = variable
    }

    init(
        _ variable: Statement,
        context: Context = .normal,
        defaultValue: Symbol? = nil,
        isArray: Bool? = nil,
        isMutable: Bool? = nil,
        isOptional: Bool? = nil,
        isProperty: Bool? = nil,
        isTableElement: Bool? = nil
    ) throws {
        self._isArray = isArray
        self._isMutable = isMutable
        self._isProperty = isProperty
        self._isTableElement = isTableElement
        self.context = context
        self.defaultValue = defaultValue
        self.returnHandling = .forced
        self.variable = variable

        if let defaultValue {
            self._isOptional = false
            try [.instance(self), defaultValue].assert(
                .haveCommonType
            )
            try defaultValue.assertHasReturnValue()
        } else {
            self._isOptional = isOptional
        }
    }

    var category: Category? {
        variable.category
    }

    var code: String {
        id
    }

    var id: String {
        guard let id = variable.id else { return "<missing id>" }
        return id
    }

    var isArray: Bool? {
        _isArray ?? variable.type.isArray
    }

    var isMutable: Bool? {
        _isMutable ?? variable.isMutable
    }

    var isOptional: Bool? {
        _isOptional ?? variable.type.isOptional
    }

    var isProperty: Bool? {
        _isProperty ?? variable.type.isProperty
    }

    var isTableElement: Bool? {
        _isTableElement ?? variable.type.isTableElement
    }

    var type: TypeInfo {
        variable.type
    }

    var typeDescription: String {
        var description = type.dataType?.description ?? (
            isTableElement == true ? "TableElement" : "Any"
        )
        if isArray == true {
            description = "[\(description)]"
        }
        if isOptional == true && type.dataType != .bool {
            description = "\(description)?"
        }
        return description
    }
}

// MARK: - Instance.Context

extension Instance {
    enum Context {
        case auxiliary
        case normal
        case optional
    }
}

// MARK: - Computed properties

extension Instance {
    var declaration: String {
        if let defaultValue {
            return "\(id): \(typeDescription) = \(defaultValue.code)"
        }
        if context == .optional {
            return "\(id): \(type.emptyValueAssignment)"
        }
        return "\(id): \(typeDescription)"
    }

    var emptyValueAssignment: String {
        if let defaultValue {
            let typeDetails = isOptional == true ? typeDescription : ""
            return "var \(id)\(typeDetails) = \(defaultValue.handle)"
        }
        if type.dataType == nil && isTableElement != true || type.dataType == .void {
            return "// var \(id): <Unknown>"
        }
        return "var \(id)\(type.emptyValueAssignment)"
    }

    var initialization: String {
        if let defaultValue {
            let typeInfo = defaultValue.type.description
            switch (typeInfo.hasSuffix("?"), defaultValue.handle) {
            case (true, "nil"):
                return "var \(id): \(typeInfo)"
            case (true, _):
                return "var \(id): \(typeInfo) = \(defaultValue.handle)"
            case (false, _):
                return "var \(id) = \(defaultValue.handle)"
            }
        }
        switch context {
        case .auxiliary:
            return emptyValueAssignment
        case .normal:
            return "var \(id) = \(code)"
        case .optional:
            return "var \(id): \(typeDescription) = \(code)"
        }
    }
}

// MARK: - Symbol Value initializer

extension Symbol {
    static func instance(
        _ variable: Statement,
        context: Instance.Context = .normal,
        isArray: Bool? = nil,
        isMutable: Bool? = nil,
        isOptional: Bool? = nil,
        isProperty: Bool? = nil,
        isTableElement: Bool? = nil
    ) -> Symbol {
        .instance(Instance(
            variable,
            context: context,
            isArray: isArray,
            isMutable: isMutable,
            isOptional: isOptional,
            isProperty: isProperty,
            isTableElement: isTableElement
        ))
    }

    static func instance(
        _ variable: Statement,
        context: Instance.Context = .normal,
        defaultValue: Symbol,
        isOptional: Bool = false,
        isMutable: Bool? = nil
    ) throws -> Symbol {
        .instance(try Instance(
            variable,
            context: context,
            defaultValue: defaultValue,
            isMutable: isMutable,
            isOptional: isOptional
        ))
    }
}

// MARK: - Special assertion handlers

extension Instance {
    func assertHasMutability(_ assertedMutability: Bool) throws {
        switch isMutable {
        case assertedMutability:
            return
        case .none:
            try variable.assertHasMutability(assertedMutability)
        default:
            throw Symbol.AssertionError.hasMutabilityAssertionFailed(
                for: "\(Self.self)",
                asserted: assertedMutability,
                actual: assertedMutability
            )
        }
    }

    func assertHasReturnHandling(_ assertedHandling: Symbol.ReturnHandling) throws {
        switch (assertedHandling, returnHandling) {
        case (.forced, .suppressed), (.suppressed, .forced):
            throw Symbol.AssertionError.hasReturnHandlingAssertionFailed(
                for: "Instance: \(id)",
                asserted: assertedHandling,
                actual: returnHandling
            )
        default:
            self.returnHandling = assertedHandling
        }
    }
}

// MARK: - Conformances

extension Array where Element == Instance {
    var mutable: [Instance] {
        filter { $0.isMutable ?? false }
    }
}

extension Instance: CustomDumpReflectable {
    var customDumpMirror: Mirror {
        .init(
            self,
            children: [
                "_isArray": self._isArray as Any,
                "_isMutable": self._isMutable as Any,
                "_isOptional": self._isOptional as Any,
                "_isProperty": self._isProperty as Any,
                "_isTableElement": self._isTableElement as Any,
                "context": self.context,
                "defaultValue": self.defaultValue as Any,
                "variable": self.variable,
                "returnHandling": self.returnHandling,
            ],
            displayStyle: .struct
        )
    }
}

extension Instance: Equatable {
    static func == (lhs: Instance, rhs: Instance) -> Bool {
        lhs._isArray == rhs._isArray &&
        lhs._isMutable == rhs._isMutable &&
        lhs._isOptional == rhs._isOptional &&
        lhs._isProperty == rhs._isProperty &&
        lhs._isTableElement == rhs._isTableElement &&
        lhs.context == rhs.context &&
        lhs.defaultValue == rhs.defaultValue &&
        lhs.variable == rhs.variable &&
        lhs.returnHandling == rhs.returnHandling
    }
}
