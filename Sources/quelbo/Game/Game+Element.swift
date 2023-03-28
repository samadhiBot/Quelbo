//
//  Game+Element.swift
//  Quelbo
//
//  Created by Chris Sessions on 2/12/23.
//

import Foundation

extension Game {
    /// A temporary object used while processing tokens into symbols.
    class Element {
        /// A camel-cased identifier based on the original ZIL name.
        let id: String

        /// The original ZIL name for a hierarchy tokens.
        let zilName: String

        /// A hierarchy of tokens.
        let tokens: [Token]

        /// The local variables that provide context when processing tokens into symbols.
        private(set) var localVariables: [Statement]

        /// Optionally specifies the type of factories to use during processing.
        let factoryType: Factories.FactoryType?

        /// Specifies the mode for factories to use during processing.
        let factoryMode: Factory.FactoryMode

        /// Initializes a new instance with the given parameters.
        ///
        /// - Parameters:
        ///   - zil: The ZIL name of the instance.
        ///   - tokens: An array of tokens associated with the instance.
        ///   - localVariables: A reference to an array of local variables (inout parameter).
        ///   - type: The factory type (default is `nil`).
        ///   - mode: The factory mode (default is `.process`).
        init(
            zil: String,
            tokens: [Token],
            with localVariables: inout [Statement],
            type: Factories.FactoryType? = nil,
            mode: Factory.FactoryMode = .process
        ) {
            self.factoryMode = mode
            self.factoryType = type
            self.id = zil.lowerCamelCase
            self.localVariables = localVariables
            self.tokens = tokens
            self.zilName = zil
        }

        /// Processes the instance and returns a symbol based on the factory, routine,
        /// or definition.
        ///
        /// - Throws: Any errors that occur during processing.
        ///
        /// - Returns: A symbol based on the processed instance.
        func process() throws -> Symbol {
            if let factory = Game.findFactory(zilName, type: factoryType) {
                return try processFactory(factory)
            }

            if Game.routines.find(id) != nil {
                return try processRoutineCall()
            }

            if Game.findDefinition(id) != nil {
                try processDefinition()
                return try processRoutineCall()
            }

            return .definition(
                id: "%\(id)-\(UUID().uuidString)",
                tokens: tokens,
                localVariables: localVariables
            )
        }
    }
}

extension Game.Element {
    /// Processes a definition and returns the resulting symbol.
    ///
    /// - Throws: Any errors that occur during processing.
    ///
    /// - Returns: The symbol based on the processed definition.
    @discardableResult
    func processDefinition() throws -> Symbol {
        let routine = try Factories.DefinitionEvaluate(
            tokens,
            with: &localVariables,
            mode: factoryMode
        ).processOrEvaluate()

        try Game.commit(routine)

        return routine
    }

    /// Processes a factory of the given type and returns the resulting symbol.
    ///
    /// - Parameter factory: The factory type to process.
    ///
    /// - Throws: Any errors that occur during processing.
    ///
    /// - Returns: The symbol based on the processed factory.
    func processFactory(_ factory: Factory.Type) throws -> Symbol {
        let factoryTokens: [Token] = {
            switch tokens.first {
            case .atom(zilName), .decimal, .global(.atom(zilName)):
                return tokens.droppingFirst
            default:
                return tokens
            }
        }()

        let symbol = try factory.init(
            factoryTokens,
            with: &localVariables,
            mode: factoryMode
        ).processOrEvaluate()

        try Game.commit(symbol)

        return symbol
    }

    /// Processes a routine and returns the resulting symbol.
    ///
    /// - Throws: Any errors that occur during processing.
    ///
    /// - Returns: The symbol based on the processed routine.
    @discardableResult
    func processRoutine() throws -> Symbol {
        let routineFactory = try Factories.Routine(
            tokens,
            with: &localVariables
        )

        routineFactory.blockProcessor.assert(
            returnHandling: .implicit
        )

        let routine = try routineFactory.process()

        try Game.commit(routine)

        return routine
    }

    /// Processes a routine call and returns the resulting symbol.
    ///
    /// - Throws: Any errors that occur during processing.
    /// - Returns: The symbol based on the processed routine call.
    func processRoutineCall() throws -> Symbol {
        try Factories.RoutineCall(
            tokens,
            with: &localVariables,
            mode: factoryMode
        ).processOrEvaluate()
    }
}
