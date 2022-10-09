//
//  TypeInfo.swift
//  Quelbo
//
//  Created by Chris Sessions on 9/13/22.
//

struct TypeInfo: Hashable{
    /// <#Description#>
    let dataType: DataType

    /// <#Description#>
    let confidence: Confidence

    /// <#Description#>
    let isOptional: Bool

    /// <#Description#>
    let isZilElement: Bool

    init(
        dataType: DataType,
        confidence: Confidence,
        isOptional: Bool = false,
        isZilElement: Bool = false
    ) {
        self.dataType = dataType
        self.confidence = confidence
        self.isOptional = isOptional
        self.isZilElement = isZilElement
    }
}

// MARK: - Helper initializers

extension TypeInfo {
    static func array(_ dataType: DataType) -> TypeInfo {
        .init(dataType: .array(dataType), confidence: .certain)
    }

    static var bool: TypeInfo {
        .init(dataType: .bool, confidence: .certain)
    }

    static var booleanFalse: TypeInfo {
        .init(dataType: .bool, confidence: .booleanFalse)
    }

    static var booleanTrue: TypeInfo {
        .init(dataType: .bool, confidence: .booleanTrue)
    }

    static var comment: TypeInfo {
        .init(dataType: .comment, confidence: .certain)
    }

    static var direction: TypeInfo {
        .init(dataType: .direction, confidence: .certain)
    }

    static var int: TypeInfo {
        .init(dataType: .int, confidence: .certain)
    }

    static var integerZero: TypeInfo {
        .init(dataType: .int, confidence: .integerZero)
    }

    static var object: TypeInfo {
        .init(dataType: .object, confidence: .certain)
    }

    static func oneOf(_ dataTypes: Set<DataType>) -> TypeInfo {
        .init(dataType: .oneOf(dataTypes), confidence: .certain)
    }

    static func optional(_ dataType: DataType) -> TypeInfo {
        .init(dataType: dataType, confidence: .certain, isOptional: true)
    }

    static func property(_ dataType: DataType) -> TypeInfo {
        .init(dataType: .property(dataType), confidence: .certain)
    }

    static var routine: TypeInfo {
        .init(dataType: .routine, confidence: .certain)
    }

    static var string: TypeInfo {
        .init(dataType: .string, confidence: .certain)
    }

    static var table: TypeInfo {
        .init(dataType: .table, confidence: .certain)
    }

    static var thing: TypeInfo {
        .init(dataType: .thing, confidence: .certain)
    }

    static var verb: TypeInfo {
        .init(dataType: .verb, confidence: .certain)
    }

    static var void: TypeInfo {
        .init(dataType: .void, confidence: .void)
    }

    static var unknown: TypeInfo {
        .init(dataType: .unknown, confidence: .unknown)
    }

    static var zilAtom: TypeInfo {
        .init(dataType: .zilAtom, confidence: .certain)
    }

    static var zilElement: TypeInfo {
        .init(dataType: .zilElement, confidence: .certain, isZilElement: true)
    }
}

// MARK: - Helper methods

extension TypeInfo {
    func withOptional(_ value: Bool) -> TypeInfo {
        .init(
            dataType: dataType,
            confidence: confidence,
            isOptional: value,
            isZilElement: isZilElement
        )
    }

    var asZElement: TypeInfo {
        .init(
            dataType: dataType,
            confidence: confidence,
            isZilElement: true
        )
    }

    /// An empty placeholder value for the data type.
    var emptyValueAssignment: String {
        if isOptional { return " = nil" }

        switch dataType {
        case .bool: return " = false"
        case .comment, .oneOf, .unknown, .void, .zilAtom: return " = \(self)"
        case .direction, .object, .routine, .table, .thing, .verb: return "? = nil"
        case .int, .int8, .int16, .int32: return " = 0"
        case .property: return " = nil"
        case .string: return " = \"\""
        case .array: return " = []"
        case .zilElement: return " = .none"
        }
    }

    /// Whether the data type has a return value.
    var hasReturnValue: Bool {
        dataType.hasReturnValue
    }

    /// <#Description#>
    /// - Parameter assertedType: <#assertedType description#>
    /// - Returns: <#description#>
    func reconcile(with assertedType: TypeInfo) -> TypeInfo? {
        guard
            assertedType != self,
            assertedType.confidence >= self.confidence
        else { return self }

        var maxConfidence: Confidence {
            max(confidence, assertedType.confidence)
        }

        var optional: Bool {
            switch (self, assertedType) {
            case (.booleanFalse, .bool), (.integerZero, .int): return isOptional
            case (.booleanFalse, _), (.integerZero, _): return true
            default: return isOptional
            }
        }

        switch (dataType, assertedType.dataType) {
        case (.comment, _): return self
        case (_, .comment): return assertedType
        case (.unknown, _): return assertedType
        case (_, .unknown): return self

        case (.verb, .int), (.array(.verb), .int): return self
        case (.int, .verb), (.int, .array(.verb)): return assertedType

        case (.array(.unknown), .array): return assertedType
        case (.array, .array(.unknown)): return self
        case (.array(.unknown), let other): return .array(other) // TODO: verify this

        case (.array(.zilElement), .array(let other)):
            guard other.canBeZilElement else { return nil }
            return assertedType
        case (.array(let selfType), .array(.zilElement)):
            guard selfType.canBeZilElement else { return nil }
            return self

        case (.oneOf(let selfTypes), .oneOf(let other)):
            let common = selfTypes.union(other)
            switch common.count {
            case 0:
                return nil
            case 1:
                return .init(
                    dataType: common.first!,
                    confidence: maxConfidence,
                    isOptional: optional
                )
            default:
                return .init(
                    dataType: .oneOf(common),
                    confidence: maxConfidence,
                    isOptional: optional
                )
            }
        case (.oneOf(let array), let other):
            guard array.contains(other) else { return nil }
            return .init(
                dataType: other,
                confidence: maxConfidence,
                isOptional: optional
            )
        case (let dataType, .oneOf(let array)):
            guard array.contains(dataType) else { return nil }
            return .init(
                dataType: dataType,
                confidence: maxConfidence,
                isOptional: optional
            )

        case (.property(let selfType), let other):
            guard selfType == other else { return nil }
            return .init(
                dataType: dataType,
                confidence: maxConfidence
            )

        case (.zilElement, let other):
            guard other.canBeZilElement else { return nil }
            return .init(
                dataType: dataType,
                confidence: confidence,
                isOptional: optional,
                isZilElement: true
            )

        case (let selfType, .zilElement):
            guard selfType.canBeZilElement else { return nil }
            return .init(
                dataType: dataType,
                confidence: confidence,
                isOptional: optional,
                isZilElement: true
            )

        default:
            if assertedType.confidence > confidence {
                return .init(
                    dataType: assertedType.dataType,
                    confidence: assertedType.confidence,
                    isOptional: optional,
                    isZilElement: assertedType.isOptional
                )
            } else if dataType == assertedType.dataType {
                return .init(
                    dataType: self.dataType,
                    confidence: self.confidence,
                    isOptional: optional,
                    isZilElement: self.isOptional
                )
            } else {
                return nil
            }
        }
    }
}

extension TypeInfo: CustomStringConvertible {
    var description: String {
        isOptional ? "\(dataType.description)?" : dataType.description
    }
}
