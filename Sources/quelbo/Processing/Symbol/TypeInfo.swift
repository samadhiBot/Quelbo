//
//  TypeInfo.swift
//  Quelbo
//
//  Created by Chris Sessions on 9/13/22.
//

import CustomDump
import Foundation

class TypeInfo {
    private(set) var dataType: DataType?

    private(set) var confidence: Confidence

    private(set) var isArray: Bool?

    private(set) var isOptional: Bool?

    private(set) var isProperty: Bool?

    private(set) var isTableElement: Bool?

    init(
        dataType: DataType? = nil,
        confidence: Confidence = .none,
        isArray: Bool? = nil,
        isOptional: Bool? = nil,
        isProperty: Bool? = nil,
        isTableElement: Bool? = nil
    ) {
        self.dataType = dataType
        self.confidence = confidence
        self.isArray = isArray
        self.isOptional = isOptional
        self.isProperty = isProperty
        self.isTableElement = isTableElement
    }

    var status: Status {
        switch confidence {
        case .none: return .undetermined
        case .booleanFalse, .integerZero, .limited, .assured, .booleanTrue: return .mutable
        case .void, .certain: return .fixed
        }
    }
}

// MARK: - Helper initializers

extension TypeInfo {
    static var bool: TypeInfo {
        .init(
            dataType: .bool,
            confidence: .certain
        )
    }

    static var booleanFalse: TypeInfo {
        .init(
            dataType: .bool,
            confidence: .booleanFalse
        )
    }

    static var booleanTrue: TypeInfo {
        .init(
            dataType: .bool,
            confidence: .booleanTrue
        )
    }

    static var comment: TypeInfo {
        .init(
            dataType: .comment,
            confidence: .certain
        )
    }

    static var int: TypeInfo {
        .init(
            dataType: .int,
            confidence: .certain
        )
    }

    static var integerZero: TypeInfo {
        .init(
            dataType: .int,
            confidence: .integerZero
        )
    }

    static var object: TypeInfo {
        .init(
            dataType: .object,
            confidence: .certain
        )
    }

    static func oneOf(_ dataTypes: Set<DataType>) -> TypeInfo {
        .init(
            dataType: .oneOf(dataTypes),
            confidence: .limited
        )
    }

    static var routine: TypeInfo {
        .init(
            dataType: .routine,
            confidence: .certain
        )
    }

    static var someTableElement: TypeInfo {
        .init(isTableElement: true)
    }

    static var string: TypeInfo {
        .init(
            dataType: .string,
            confidence: .certain
        )
    }

    static var table: TypeInfo {
        .init(
            dataType: .table,
            confidence: .certain
        )
    }

    static var tableElement: TypeInfo {
        .init(
            dataType: .tableElement,
            confidence: .certain
        )
    }

    static var thing: TypeInfo {
        .init(
            dataType: .thing,
            confidence: .certain
        )
    }

    static var verb: TypeInfo {
        .init(
            dataType: .verb,
            confidence: .certain
        )
    }

    static var void: TypeInfo {
        .init(
            dataType: .void,
            confidence: .void
        )
    }

    static var unknown: TypeInfo {
        .init(
            dataType: nil,
            confidence: .none
        )
    }

    static var word: TypeInfo {
        .init(
            dataType: .word,
            confidence: .certain
        )
    }


    static var zilAtom: TypeInfo {
        .init(
            dataType: .atom,
            confidence: .certain
        )
    }
}


// MARK: - Assertions

extension TypeInfo {
    func assertIsArray() throws {
        guard isArray != false else {
            throw Symbol.AssertionError.isArrayAssertionFailed
        }
        self.isArray = true
    }

    func assertIsOptional() throws {
        guard isOptional != false else {
            throw Symbol.AssertionError.isOptionalAssertionFailed
        }
        self.isOptional = true
    }

    func assertIsProperty() throws {
        guard isProperty != false else {
            throw Symbol.AssertionError.isPropertyAssertionFailed
        }
        self.isProperty = true
    }

    func assertIsTableElement() throws {
        guard isTableElement != false && dataType?.canBeTableElement != false else {
            throw Symbol.AssertionError.isTableElementAssertionFailed
        }
        self.isTableElement = true
    }
}

// MARK: - Modifiers

extension TypeInfo {
    var array: TypeInfo {
        clone(isArray: true)
    }

    var element: TypeInfo {
        if dataType == .table { return .someTableElement }
        return clone(isArray: false)
    }

    var optional: TypeInfo {
        clone(isOptional: true)
    }

    var nonOptional: TypeInfo {
        clone(isOptional: false)
    }

    var property: TypeInfo {
        clone(isProperty: true)
    }

    var tableElement: TypeInfo {
        clone(isTableElement: true)
    }
}

// MARK: - Helper methods

extension TypeInfo {
    func clone(
        dataType newDataType: DataType? = nil,
        confidence newConfidence: Confidence? = nil,
        isArray newIsArray: Bool? = nil,
        isOptional newIsOptional: Bool? = nil,
        isProperty newIsProperty: Bool? = nil,
        isTableElement newIsTableElement: Bool? = nil
    ) -> TypeInfo {
        TypeInfo(
            dataType: newDataType ?? dataType,
            confidence: newConfidence ?? confidence,
            isArray: newIsArray ?? isArray,
            isOptional: newIsOptional ?? isOptional,
            isProperty: newIsProperty ?? isProperty,
            isTableElement: newIsTableElement ?? isTableElement
        )
    }

    /// An empty placeholder value for the data type.
    var emptyValueAssignment: String {
        if isArray == true { return "\(self) = []" }

        switch dataType {
        case .atom, .comment, .oneOf, .void:
            return " = \(self)"
        case .bool:
            return "Bool = false"
        case .int, .int8, .int16, .int32:
            return "\(self) = 0"
        case .none:
            return "\(self)"
        case .object, .routine, .table, .tableElement, .thing, .verb, .word:
            return isOptional == true ? "\(self) = nil" : "\(self)? = nil"
        case .string:
            return "String = \"\""
        }
    }

    /// Whether the data type has a return value.
    var hasReturnValue: Bool {
        if dataType?.hasReturnValue == true {
            return true
        }
        if isTableElement == true {
            return true
        }
        return false
    }

    /// Whether a type crossed with a different type indicate an optional value.
    ///
    /// - Parameter other: The other type.
    ///
    /// - Returns: Whether a type crossed with a different type indicate an optional value.
    func isOptional(versus other: TypeInfo) -> Bool {
        (confidence == .integerZero &&
         other.confidence > .integerZero) ||
        (confidence == .booleanFalse &&
         other.confidence > .booleanFalse &&
         other.confidence != .booleanTrue)
    }

    var objID: String {
        String("\(ObjectIdentifier(self))".dropLast().suffix(4))
    }

    var setFlagsCount: Int {
        [
            isArray != nil ? 1 : 0,
            isOptional != nil ? 1 : 0,
            isProperty != nil ? 1 : 0,
            isTableElement != nil ? 1 : 0,
        ].reduce(0, +)
    }
}

// MARK: - Reconcile

extension TypeInfo {
    func merge(
        with type: TypeInfo,
        dataType newDataType: DataType? = nil,
        confidence newConfidence: Confidence? = nil,
        isArray newIsArray: Bool? = nil,
        isOptional newIsOptional: Bool? = nil,
        isProperty newIsProperty: Bool? = nil,
        isTableElement newIsTableElement: Bool? = nil
    ) -> TypeInfo {
        // print("\t▶️ before", self.objID, self.debugDescription)
        self.dataType = newDataType ?? type.dataType ?? dataType
        self.confidence = newConfidence ?? max(type.confidence, confidence)
        self.isArray = newIsArray ?? type.isArray ?? isArray
        // print("\t❤️‍🔥", newIsOptional, type.isOptional, isOptional, isOptional(versus: type))
        self.isOptional = newIsOptional ?? type.isOptional ?? isOptional ??
                          isOptional(versus: type) ? true : nil
        self.isProperty = newIsProperty ?? type.isProperty ?? isProperty
        // print("\t🍴", newIsTableElement, type.isTableElement, isTableElement)
        self.isTableElement = newIsTableElement ?? type.isTableElement ?? isTableElement
        // print("\t▶️ after", self.objID, self.debugDescription)

        type.dataType = self.dataType
        type.confidence = self.confidence
        type.isArray = self.isArray
        type.isOptional = self.isOptional
        type.isProperty = self.isProperty
        type.isTableElement = self.isTableElement

        return self
    }

    func reconcile(
        _ handle: @autoclosure () -> String,
        with asserted: TypeInfo
    ) throws -> TypeInfo {
        func logged(_ typeInfo: TypeInfo) -> TypeInfo {
            guard NSClassFromString("XCTest") != nil else { return typeInfo }

            let identifier = handle()
                .replacingOccurrences(of: "\n", with: "")
                .replacingOccurrences(of: "    ", with: " ")
            print(
                "\t􀄢\(identifier):",
                dataType?.description ?? "nil",
                "􀚌",
                asserted.dataType?.description ?? "nil",
                "􁉂",
                "\(typeInfo.confidence == .certain ? "􀎠" : "")\(typeInfo)"
            )
            return typeInfo
        }

        switch (dataType, asserted.dataType) {
        case (.comment, _),
            (.int, .verb),
            (.none, _),
            (.verb, .int),
            (_, .comment),
            (_, dataType):
            return logged(asserted.merge(with: self))

        case (.oneOf(let selfTypes), .oneOf(let otherTypes)):
            let common = selfTypes.union(otherTypes)
            switch common.count {
            case 0:
                break
            case 1:
                guard let oneCommon = common.first else { break }
                return logged(asserted.merge(
                    with: self,
                    dataType: oneCommon
                ))
            default:
                return logged(asserted.merge(
                    with: self,
                    dataType: .oneOf(common),
                    confidence: .limited
                ))
            }

        case (.oneOf(let selfTypes), let other):
            guard let other, selfTypes.contains(other) else { break }
            return logged(asserted.merge(
                with: self,
                dataType: other
            ))

        case (_, .oneOf(let otherTypes)):
            if let dataType, otherTypes.contains(dataType) {
                return logged(asserted.merge(
                    with: self,
                    dataType: dataType
                ))
            }
            if isOptional(versus: asserted) {
                return logged(asserted.merge(
                    with: self,
                    isOptional: true
                ))
            }

        case (_, .void):
            return logged(self)

        default:
            if asserted.confidence < confidence {
                return logged(asserted.merge(with: self))
            }
        }

        if asserted.confidence > confidence {
            return logged(asserted.merge(
                with: self,
                dataType: asserted.dataType,
                confidence: asserted.confidence,
                isOptional: isOptional(versus: asserted) ? true : nil
            ))
        }

        if asserted.confidence == confidence && isTableElement == true {
            return logged(asserted.merge(with: self))
        }

        throw Symbol.AssertionError.hasTypeAssertionFailed(
            for: handle(),
            asserted: asserted,
            actual: self
        )
    }
}

// MARK: - Conformances

extension TypeInfo: Comparable {
    static func < (lhs: TypeInfo, rhs: TypeInfo) -> Bool {
        guard lhs.confidence == rhs.confidence else {
            return lhs.confidence < rhs.confidence
        }
        return lhs.setFlagsCount < rhs.setFlagsCount
    }
}

extension TypeInfo: CustomDebugStringConvertible {
    var debugDescription: String {
        var description = ""
        customDump(self, to: &description)
        return description
    }
}

extension TypeInfo: CustomDumpReflectable {
    var customDumpMirror: Mirror {
        .init(
            self,
            children: [
                "dataType": self.dataType as Any,
                "confidence": self.confidence,
                "isArray": self.isArray as Any,
                "isOptional": self.isOptional as Any,
                "isProperty": self.isProperty as Any,
                "isTableElement": self.isTableElement as Any,
            ],
            displayStyle: .struct
        )
    }
}

extension TypeInfo: CustomStringConvertible {
    var description: String {
        var description = dataType?.description ?? (
            isTableElement == true ? "TableElement" : "Any"
        )
        if isArray == true {
            description = "[\(description)]"
        }
        if isOptional == true {
            description = "\(description)?"
        }
        return description
    }
}

extension TypeInfo: Hashable {
    static func == (lhs: TypeInfo, rhs: TypeInfo) -> Bool {
        lhs.dataType == rhs.dataType &&
        lhs.confidence == rhs.confidence &&
        lhs.isArray == rhs.isArray &&
        lhs.isOptional == rhs.isOptional &&
        lhs.isProperty == rhs.isProperty &&
        lhs.isTableElement == rhs.isTableElement
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(isArray)
        hasher.combine(isOptional)
        hasher.combine(isProperty)
        hasher.combine(isTableElement)
        hasher.combine(confidence)
        hasher.combine(dataType)
    }
}
