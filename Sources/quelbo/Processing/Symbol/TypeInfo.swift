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

    static var integerOne: TypeInfo {
        .init(
            dataType: .int,
            confidence: .integerOne
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

    static var partsOfSpeech: TypeInfo {
        .init(
            dataType: .int,
            confidence: .certain
        )
    }

    static var routine: TypeInfo {
        .init(
            dataType: .routine,
            confidence: .certain
        )
    }

    static var someTableElement: TypeInfo {
        .init(
            dataType: .tableElement,
            confidence: .assured,
            isTableElement: true
        )
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
            confidence: .certain,
            isArray: false
        )
    }

    static var tableDeclaration: TypeInfo {
        .init(
            dataType: .table,
            confidence: .certain,
            isArray: false,
            isTableElement: false
        )
    }

    static var tableElement: TypeInfo {
        .init(
            dataType: .tableElement,
            confidence: .certain,
            isArray: false
        )
    }

    static var unknown: TypeInfo {
        .init(
            dataType: nil,
            confidence: .none
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
        if dataType == .table { return }
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

    func assertIsTableElement(
        isTableElement assertedValue: Bool,
        force: Bool
    ) throws {
        guard dataType?.canBeTableElement != false else {
            throw Symbol.AssertionError.isTableElementAssertionFailed(
                "\(self) cannot be a table element."
            )
        }
        guard let currentValue = self.isTableElement else {
            self.isTableElement = assertedValue
            return
        }
        if assertedValue == currentValue {
            return
        }
        if force {
            self.isTableElement = assertedValue
            return
        }
        throw Symbol.AssertionError.isTableElementAssertionFailed(
            "\(self) already assigned with `.isTableElement: \(currentValue)`"
        )

//        if self.isTableElement == assertedValue { return }
//        guard self.isTableElement == nil else {
//            throw Symbol.AssertionError.isTableElementAssertionFailed(
//                "\(self) already assigned with `.isTableElement: \(self.isTableElement)`"
//            )
//        }


        /*
         if self.isTableElement == nil {

             return
         }

         // TODO: replace the following with stricter handling
         if isTableElement, !isInstance, self.isTableElement == false {
             print("▶️ returning without change")
             return
         }
         print("🧂", self.isTableElement, "->", isTableElement)
         self.isTableElement = isTableElement
         */
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

    var nonOptional: TypeInfo {
        clone(isOptional: false)
    }

    var root: TypeInfo {
        clone(isTableElement: false)
    }

    var optional: TypeInfo {
        clone(isOptional: true)
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

    func codeMultiType(
        code: String,
        category: Category?
    ) -> String {
        guard isTableElement == true else { return code }

        switch (dataType, category) {
        case (.bool, _):
            return code
        case (.int16, _):
            return ".int16(\(code))"
        case (.int32, _):
            return ".int32(\(code))"
        case (.int8, _):
            return ".int8(\(code))"
        case (.int, _):
            return code
        case (.object, .rooms):
            return ".room(\"\(code)\")"
        case (.object, _):
            return ".object(\"\(code)\")"
        case (.string, _):
            return code
        case (.table, _):
            return ".table(\(code))"
        default: return code
        }
    }

    /// An empty placeholder value for the data type.
    var emptyValueAssignment: String {
        if isArray == true { return " = [\(self)]()" }

        switch dataType {
        case .atom, .comment, .none, .void:
            return " = \(self)"
        case .bool:
            return " = false"
        case .int:
            return " = 0"
        case .int8, .int16, .int32:
            return ": \(self) = 0"
        case .object, .routine, .table, .tableElement, .verb, .word:
            return isOptional == true ? ": \(self)" : ": \(self)?"
        case .oneOf(let dataTypes):
            let leastSpecific = dataTypes.min(by: { $0.baseConfidence < $1.baseConfidence })
            return TypeInfo(
                dataType: leastSpecific,
                confidence: leastSpecific?.baseConfidence ?? .none
            ).emptyValueAssignment
        case .string:
            return " = \"\""
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

    /// <#Description#>
    var isSomeInteger: Bool {
        [.int, .int8, .int16, .int32].contains(self.dataType)
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
        self.isOptional = type.isOptional ?? newIsOptional ?? isOptional ??
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
        let logValuesToConsole = false

        let initialType = dataType?.description ?? "nil"
        let assertedType = asserted.dataType?.description ?? "nil"

        func logged(_ typeInfo: TypeInfo) -> TypeInfo {
            guard logValuesToConsole && NSClassFromString("XCTest") != nil else { return typeInfo }

            let identifier = handle()
                .replacingOccurrences(of: "\n", with: "")
                .replacingOccurrences(of: "    ", with: " ")

            print(
                "\t􀄢\(identifier): \(initialType) 􁝮 \(assertedType) 􁉂 \(typeInfo.debugDescription)"
            )

            return typeInfo
        }

        switch (dataType, asserted.dataType) {
        case (.comment, _),
            (.none, _),
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
            if dataType == .tableElement {
                let elements = otherTypes.filter { $0.canBeTableElement }
                if !elements.isEmpty {
                    return logged(asserted.merge(
                        with: self,
                        dataType: .oneOf(elements)
                    ))
                }
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

        if asserted.isProperty == true && isProperty == true {
            return logged(asserted.merge(with: self))
        }

        _ = logged(.unknown)
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
        var modifiers: [String] = []
        if confidence == .certain { modifiers.append("􀎠") }
        if isProperty == true { modifiers.append("􀀢") }
        if isTableElement == true { modifiers.append("􀀪") }
        if isTableElement == false { modifiers.append("􀁮")}
        return modifiers.joined(separator: "") + description
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
            isTableElement == true ? "TableElement" : "Unit"
        )
        if case .oneOf(let dataTypes) = dataType {
            description = dataTypes
                .min(by: { $0.baseConfidence < $1.baseConfidence })?
                .description ?? "Unit"
        }
        if isArray == true {
            description = "[\(description)]"
        } else if isOptional == true && dataType != .bool {
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
