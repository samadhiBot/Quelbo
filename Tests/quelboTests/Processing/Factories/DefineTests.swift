//
//  DefineTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/5/22.
//

import CustomDump
import XCTest
@testable import quelbo

final class DefineTests: QuelboTests {
    let factory = Factories.Define.self

    func testFindFactory() throws {
        AssertSameFactory(factory, Game.findFactory("DEFINE"))
    }

    func testSimpleDefineWithoutParameters() throws {
        process("""
            <CONSTANT READBUF-SIZE 100>

            <DEFINE MAKE-READBUF () <ITABLE NONE ,READBUF-SIZE (BYTE)>>

            <CONSTANT KBD-READBUF <MAKE-READBUF>>
            <CONSTANT EDIT-READBUF <MAKE-READBUF>>
        """)

        XCTAssertNoDifference(
            Game.constants.find("readbufSize"),
            Statement(
                id: "readbufSize",
                code: "let readbufSize: Int = 100",
                type: .int,
                category: .constants,
                isCommittable: true
            )
        )

        XCTAssertNoDifference(
            Game.routines.find("makeReadbuf"),
            Statement(
                id: "makeReadbuf",
                code: """
                    @discardableResult
                    /// The `makeReadbuf` (MAKE-READBUF) routine.
                    func makeReadbuf() -> Table {
                        return Table(
                            count: readbufSize,
                            flags: [.byte, .none]
                        )
                    }
                    """,
                type: .table,
                category: Category.routines,
                isCommittable: true
            )
        )

        XCTAssertNoDifference(
            Game.findDefinition("makeReadbuf"),
            Definition(
                id: "makeReadbuf",
                tokens: [
                    .list([]),
                    .form([
                        .atom("ITABLE"),
                        .atom("NONE"),
                        .global(.atom("READBUF-SIZE")),
                        .list([
                            .atom("BYTE")
                        ])
                    ]),
                ]
            )
        )

        XCTAssertNoDifference(
            Game.constants.find("kbdReadbuf"),
            Statement(
                id: "kbdReadbuf",
                code: "let kbdReadbuf: Table = makeReadbuf()",
                type: .table,
                category: .constants,
                isCommittable: true
            )
        )

        XCTAssertNoDifference(
            Game.constants.find("editReadbuf"),
            Statement(
                id: "editReadbuf",
                code: "let editReadbuf: Table = makeReadbuf()",
                type: .table,
                category: .constants,
                isCommittable: true
            )
        )
    }

    func testSimpleDefineWithOneParameter() throws {
        // https://mdl-language.readthedocs.io/en/latest/07-structured-objects/#755-form-and-iform
        let definition = process("""
            <DEFINE INC-FORM (A)
                    <FORM SET .A <FORM + 1 <FORM LVAL .A>>>>
        """)

        XCTAssertNoDifference(definition, .definition(
            id: "incForm",
            tokens: [
                .list([
                    .atom("A")
                ]),
                .form([
                    .atom("FORM"),
                    .atom("SET"),
                    .local("A"),
                    .form([
                        .atom("FORM"),
                        .atom("+"),
                        .decimal(1),
                        .form([
                            .atom("FORM"),
                            .atom("LVAL"),
                            .local("A")
                        ])
                    ])
                ])
            ]
        ))

        // `incForm` isn't processed until it has been called
        XCTAssertNil(Game.routines.find("incForm"))

        XCTAssertNoDifference(
            process("<INC-FORM FOO>"),
            .statement(
                id: "incForm",
                code: "incForm(foo: foo)",
                type: .int
            )
        )

        XCTAssertNoDifference(
            Game.routines.find("incForm"),
            Statement(
                id: "incForm",
                code: """
                    @discardableResult
                    /// The `incForm` (INC-FORM) routine.
                    func incForm(foo: Int) -> Int {
                        var foo: Int = foo
                        return foo.set(to: .add(1, foo))
                    }
                    """,
                type: .int,
                category: Category.routines,
                isCommittable: true
            )
        )

        XCTAssertNoDifference(
            process("<SET BAZ <INC-FORM BAR>>"),
            .statement(
                code: "baz.set(to: incForm(foo: bar))",
                type: .int
            )
        )
    }

    func testDefineWithDecl() throws {
        // https://mdl-language.readthedocs.io/en/latest/17-macro-operations/#1722-example
        process("<DEFINE DOUBLE (X) #DECL ((X) FIX) <+ .X .X>>")

        XCTAssertNoDifference(
            process("<DOUBLE FOO>"),
            .statement(
                id: "double",
                code: "double(foo: foo)",
                type: .int
            )
        )

        XCTAssertNoDifference(
            Game.routines.find("double"),
            Statement(
                id: "double",
                code: """
                    @discardableResult
                    /// The `double` (DOUBLE) routine.
                    func double(foo: Int) -> Int {
                        return .add(foo, foo)
                    }
                    """,
                type: .int,
                category: Category.routines,
                isCommittable: true
            )
        )

        XCTAssertNoDifference(
            process("<SET BAZ <DOUBLE BAR>>"),
            .statement(
                code: "baz.set(to: double(foo: bar))",
                type: .int
            )
        )
    }

    // https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.440mph5j49mp
    func testPowerTo() throws {
        process("""
            <DEFINE POWER-TO ACT (X "OPT" (Y 2))
                <COND (<=? .Y 0> <RETURN 1 .ACT>)>
                <REPEAT ((Z 1)(I 0))
                    <SET Z <* .Z .X>>
                    <SET I <+ .I 1>>
                    <COND (<=? .I .Y> <RETURN .Z>)>
                >
            >
        """)

        XCTAssertNoDifference(
            process("<SET BAR <POWER-TO FOO>>"),
            .statement(
                code: "bar.set(to: powerTo(foo: foo))",
                type: .int
            )
        )

        XCTAssertNoDifference(
            Game.routines.find("powerTo"),
            Statement(
                id: "powerTo",
                code: """
                    @discardableResult
                    /// The `powerTo` (POWER-TO) routine.
                    func powerTo(foo: Int, y: Int = 2) -> Int {
                        if y.equals(0) {
                            return 1
                        }
                        var z: Int = 1
                        var i: Int = 0
                        while true {
                            z.set(to: .multiply(z, foo))
                            i.set(to: .add(i, 1))
                            if i.equals(y) {
                                return z
                            }
                        }
                    }
                    """,
                type: .int,
                category: Category.routines,
                isCommittable: true
            )
        )
    }
}
