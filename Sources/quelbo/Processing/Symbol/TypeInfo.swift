//
//  TypeInfo.swift
//  Quelbo
//
//  Created by Chris Sessions on 9/13/22.
//

import CustomDump

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

    static var direction: TypeInfo {
        .init(
            dataType: .direction,
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
        clone(isArray: false)
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
        case .atom, .comment, .none, .oneOf, .void:
            return " = \(self)"
        case .bool:
            return "Bool = false"
        case .direction, .object, .routine, .table, .thing, .verb:
            return isOptional == true ? "\(self) = nil" : "\(self)? = nil"
        case .int, .int8, .int16, .int32:
            return "\(self) = 0"
        case .string:
            return "String = \"\""
        }
    }

    /// Whether the data type has a return value.
    var hasReturnValue: Bool {
        if dataType?.hasReturnValue == true {
            return true
        }
        if isArray == true && isTableElement == true {
            return true
        }
        return false
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
        with current: TypeInfo,
        dataType newDataType: DataType? = nil,
        confidence newConfidence: Confidence? = nil,
        isArray newIsArray: Bool? = nil,
        isOptional newIsOptional: Bool? = nil,
        isProperty newIsProperty: Bool? = nil,
        isTableElement newIsTableElement: Bool? = nil
    ) -> TypeInfo {
        var seemsOptional: Bool? {
            guard
                current.confidence == .booleanFalse &&
                confidence > .booleanFalse &&
                confidence != .booleanTrue
            else { return nil }
            return true
        }
        // print("▶️ before", self.objID, self.debugDescription)
        self.dataType = newDataType ?? current.dataType ?? dataType
        self.confidence = newConfidence ?? max(current.confidence, confidence)
        // print("❤️‍🔥", newIsArray, current.isArray, isArray)
        self.isArray = newIsArray ?? current.isArray ?? isArray
        self.isOptional = newIsOptional ?? current.isOptional ?? isOptional ?? seemsOptional
        self.isProperty = newIsProperty ?? current.isProperty ?? isProperty
        // print("🤦‍♂️", newIsTableElement, current.isTableElement, isTableElement)
        self.isTableElement = newIsTableElement ?? current.isTableElement ?? isTableElement
        // print("▶️ after", self.objID, self.debugDescription)

        current.dataType = self.dataType
        current.confidence = self.confidence
        current.isArray = self.isArray
        current.isOptional = self.isOptional
        current.isProperty = self.isProperty
        current.isTableElement = self.isTableElement

        return self
    }

    func reconcile(
        _ handle: String,
        with asserted: TypeInfo
    ) throws -> TypeInfo {
        print(
            "❓\(handle):",
            dataType?.description ?? "nil",
            "<->",
            asserted.dataType?.description ?? "nil"
        )

        switch (dataType, asserted.dataType) {
        case (.comment, _),
            (.int, .verb),
            (.none, _),
            (.verb, .int),
            (_, .comment),
            (_, dataType):
            return asserted.merge(with: self)

        case (.oneOf(let selfTypes), .oneOf(let otherTypes)):
            let common = selfTypes.union(otherTypes)
            switch common.count {
            case 0:
                break
            case 1:
                guard let oneCommon = common.first else { break }
                return asserted.merge(
                    with: self,
                    dataType: oneCommon,
                    confidence: .certain
                )
            default:
                return asserted.merge(
                    with: self,
                    dataType: .oneOf(common),
                    confidence: .limited
                )
            }

        case (.oneOf(let selfTypes), let other):
            guard let other, selfTypes.contains(other) else { break }
            return asserted.merge(
                with: self,
                dataType: other,
                confidence: .certain
            )

        case (let dataType, .oneOf(let otherTypes)):
            guard let dataType, otherTypes.contains(dataType) else { break }
            return asserted.merge(
                with: self,
                dataType: dataType,
                confidence: .certain
            )

        default:
            break
        }

        if asserted.confidence > confidence {
//            update(
//                dataType: asserted.dataType,
//                confidence: asserted.confidence,
//                isOptional: confidence == .booleanFalse
//            )
            return asserted.merge(
                with: self,
                dataType: asserted.dataType,
                confidence: asserted.confidence,
                isOptional: confidence == .booleanFalse
            )
        }

        if asserted.confidence == confidence && isTableElement == true {
            return asserted.merge(with: self)
        }

        throw Symbol.AssertionError.hasTypeAssertionFailed(
            for: handle,
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
            isTableElement == true ? "TableElement" : "<Unknown>"
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

//extension Array where Element == TypeInfo {
//    var mostConfident: [TypeInfo] {
//        reduce([]) { types, type in
//            guard let firstType = types.first else {
//                types.append(type)
//                return
//            }
//            if type.confidence > firstType.confidence {
//                types = [type]
//            }
//        }
//    }
//}
