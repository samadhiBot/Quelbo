# TODO

􀃳 Variable definitions should use type inference
  - e.g. `var beachDig: Int = -1` -> `var beachDig = -1`

􀃳 Fix tables declaration
  - e.g. `let def1: Table = .table(...)` -> `let def1 = Table(...)`

􀂒 Constants should ignore optionality and always declare a value

􀂒 Globals with references to constants should use `Constants.` prefix
    ```
    static var Constant: Constants {
        Zork1.shared.constants
    }

    ❌ var def1Res = Table(def1, .int(0), .int(0))
    ✅ var def1Res = Table(Constants.def1, .int(0), .int(0))
    ```

􀂒 Correctly handle `<SETG WBREAKS <STRING !\" !,WBREAKS>>>`

􀂒 Non-optional globals should have a default value if none is assigned

  - e.g. `var againDir: Bool`

􀂒 Globals that are immutable should be constants
  - e.g. `let candleTable: Table = Table(..., flags: .pure)`
  - Tables with 'flags: .pure' should omit `.pure` and become constants

􀂒 Update directions declaration in game package
  - e.g. `directions = Direction.defaults + [.land]`
