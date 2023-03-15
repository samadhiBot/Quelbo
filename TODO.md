# TODO

- Variable definitions should use type inference
  - e.g. `var beachDig: Int = -1` -> `var beachDig = -1`

- Fix tables declaration
  - e.g. `let def1: Table = .table(...)` -> `let def1 = Table(...)`

- Constants should ignore optionality and always declare a value

- Globals with references to constants should use @dynamicMemberLookup
  - e.g. Constants["def1"]

- Correctly handle `<SETG WBREAKS <STRING !\" !,WBREAKS>>>`

- Globals should have a default value if none is assigned
  - e.g. `var againDir: Bool`

- Globals that are immutable should be constants
  - e.g. `let candleTable: Table = Table(..., flags: .pure)`
  - Tables with 'flags: .pure' should omit `.pure` and become constants

- Update directions declaration in game package
  - e.g. `directions = Direction.defaults + [.land]`
