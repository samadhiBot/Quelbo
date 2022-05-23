//
//  SymbolFactory+subclasses.swift
//  Quelbo
//
//  Created by Chris Sessions on 5/16/22.
//

import Foundation

/// Subclasses of `MuddleFactory` are factories for symbols used in defining Zil Functions and
/// Macros.
///
/// For comprehensive documentation, see [FUNCTION](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.m3e5asphu6rd),
/// [DEFINE](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#) and
/// [DEFMAC](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.206ipza)
/// in the _ZILF Reference Guide_; and
/// [Simple Functions](https://mdl-language.readthedocs.io/en/latest/05-simple-functions/),
/// [Functions](https://mdl-language.readthedocs.io/en/latest/09-functions/) and
/// [Macro-operations](https://mdl-language.readthedocs.io/en/latest/17-macro-operations/) in _The
/// MDL Programming Language_.
///
class MuddleFactory: ZMachineFactory {}

/// Subclasses of `ZilFactory` are factories for symbols used outside of Zil Routines.
///
/// See [MDL built-ins and ZIL library](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.2et92p0)
/// in the _ZILF Reference Guide_ for comprehensive documentation.
///
class ZilFactory: SymbolFactory {}

/// Subclasses of `ZilPropertyFactory` are factories for symbols representing Zil object properties.
///
/// For comprehensive documentation, see
/// [OBJECT](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.38czs75) and
/// [ROOM](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.13qzunr)
/// in the _ZILF Reference Guide_.
///
class ZilPropertyFactory: SymbolFactory {}

/// Subclasses of `ZMachineFactory` are factories for symbols used within Zil Routines.
///
/// See [Z-code built-ins](https://docs.google.com/document/d/11Kz3tknK05hb0Cw41HmaHHkgR9eh0qNLAbE9TzZe--c/edit#heading=h.1j4nfs6)
/// in the _ZILF Reference Guide_ for comprehensive documentation.
///
class ZMachineFactory: SymbolFactory {}
