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
        XCTAssertNoDifference(
            process("<CONSTANT READBUF-SIZE 100>"),
            .statement(
                id: "readbufSize",
                code: "let readbufSize: Int = 100",
                type: .int,
                category: .constants,
                isCommittable: true
            )
        )

        XCTAssertNoDifference(
            process("<DEFINE MAKE-READBUF () <ITABLE NONE ,READBUF-SIZE (BYTE)>>"),
            .definition(
                id: "makeReadbuf",
                tokens: [
                    .list([]),
                    .form([
                        .atom("ITABLE"),
                        .atom("NONE"),
                        .global("READBUF-SIZE"),
                        .list([
                            .atom("BYTE")
                        ])
                    ]),
                ]
            )
        )

        XCTAssertNoDifference(
            process("<CONSTANT KBD-READBUF <MAKE-READBUF>>"),
            .statement(
                id: "kbdReadbuf",
                code: """
                    let kbdReadbuf: Table = {
                        return Table(
                            count: readbufSize,
                            flags: [.byte, .none]
                        )
                    }()
                    """,
                type: .table,
                category: .constants,
                isCommittable: true
            )
        )

        XCTAssertNoDifference(
            process("<CONSTANT EDIT-READBUF <MAKE-READBUF>>"),
            .statement(
                id: "editReadbuf",
                code: """
                let editReadbuf: Table = {
                    return Table(
                        count: readbufSize,
                        flags: [.byte, .none]
                    )
                }()
                """,
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

        XCTAssertNoDifference(
            process("<INC-FORM FOO>"),
            .statement(
                code: """
                    {
                        var foo: Int = foo
                        return foo.set(to: .add(1, foo))
                    }()
                    """,
                type: .int
            )
        )

        XCTAssertNoDifference(
            process("<SET BAZ <INC-FORM BAR>>"),
            .statement(
                code: """
                    baz.set(to: {
                        var bar: Int = bar
                        return bar.set(to: .add(1, bar))
                    }())
                    """,
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
                code: """
                    {
                        return .add(foo, foo)
                    }()
                    """,
                type: .int
            )
        )

        XCTAssertNoDifference(
            process("<SET BAZ <DOUBLE BAR>>"),
            .statement(
                code: """
                    baz.set(to: {
                        return .add(bar, bar)
                    }())
                    """,
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
                code: """
                    bar.set(to: {
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
                    }())
                    """,
                type: .int
            )
        )
    }
}
