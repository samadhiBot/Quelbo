# # Quelbo TODO

- [ ] The `actions: [Routine.ID: Routine.Function]` dictionary:
    - [ ] Should only contain routines referenced in Objects and Rooms.
    - [ ] Should map to the correct `Routine.Function` type
 
### ## Done

- [x] Update directions declaration in game package
  - e.g. `directions = Direction.defaults + [.land]`

- [x] Variable definitions should use type inference
  - e.g. `var beachDig: Int = -1` -> `var beachDig = -1`

- [x] Constants should ignore optionality and always declare a value

- [x] Globals with references to constants should use `Constants.` prefix
```
❌ var def1Res = Table(def1, .int(0), .int(0))
✅ var def1Res = Table(Constants.def1, .int(0), .int(0))
```

- [x] Wrap table element references
```
Table(
    "The blow lands, making a shallow gash in the ",
    Constants.fDef, // 🛑 Cannot convert value of type 'Int' to expected argument type 'ZilElement'
    "'s arm!",
    flags: .length, .pure
)
```

- [x] Fix tables declaration
```  
var reserveLexv = .table( // 🛑 Reference to member 'table' cannot be resolved without a contextual type
    count: 59,
    defaults: 0, .int8(0), .int8(0),
    flags: .lexv
)
```

- [x] Correctly handle `wbreaks`
```
<SETG WBREAKS <STRING !\" !,WBREAKS>>>

var wbreaks = ["\"", wbreaks].joined() // 🛑 Circular reference
```

`<SETG WBREAKS <STRING !\" !,WBREAKS>>>`

- [x] Non-optional globals should have a default value if none is assigned
```
var againDir: Bool // 🛑 Class 'Zork1Globals' has no initializers
```

