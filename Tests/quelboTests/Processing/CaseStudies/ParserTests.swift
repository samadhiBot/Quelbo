//
//  ParserTests.swift
//  Quelbo
//
//  Created by Chris Sessions on 3/26/23.
//

import CustomDump
import XCTest
@testable import quelbo

final class ParserTests: QuelboTests {
    override func setUp() {
        super.setUp()
        GlobalObjectsTests().sharedSetUp()
        ZmemqTests().sharedSetUp()
        SearchListTests().sharedSetUp()
        DoSlTests().sharedSetUp()
        IsLitTests().sharedSetUp()
        IntTests().sharedSetUp()
        DescribeObjectTests().sharedSetUp()
        DescribeRoomTests().sharedSetUp()
        DescribeObjectsTests().sharedSetUp()
        IsYesTests().sharedSetup()
        FinishTests().sharedSetUp()
        JigsUpTests().sharedSetUp()
        GlobalCheckTests().sharedSetUp()
        OrphanTests().sharedSetUp()
        IsAccessibleTests().sharedSetUp()
        BufferPrintTests().sharedSetUp()
        NotHereTests().sharedSetUp()
        WhichPrintTests().sharedSetUp()
        GetObjectTests().sharedSetUp()
        ClauseTests().sharedSetUp()
        SnarfemTests().sharedSetUp()

        sharedSetUp()
    }

    func sharedSetUp() {
        process(#"""
            <CONSTANT O-END 3>    "byte pointer to first free byte in OOPS-INBUF"
            <CONSTANT O-LENGTH 2> "byte length of unparsed tokens in P-LEXV"
            <CONSTANT O-PTR 0>    "word pointer to unknown token in P-LEXV"
            <CONSTANT O-START 1>  "word pointer to sentence start in P-LEXV"
            <CONSTANT P-ITBLLEN 9>
            <CONSTANT P-LEXELEN 2>
            <CONSTANT P-LEXSTART 1> ;"Number of words per LEXV entry"
            <CONSTANT P-LEXWORDS 1> ;"Word offset to start of LEXV entries"
            <CONSTANT P-NC1 6>
            <CONSTANT P-NC1L 7>
            <CONSTANT P-NC2 8>
            <CONSTANT P-NC2L 9>
            <CONSTANT P-PREP1 2>
            <CONSTANT P-PREP1N 3>
            <CONSTANT P-PREP2 4>
            <CONSTANT P-PREP2N 5>
            <CONSTANT P-SACTION 7>
            <CONSTANT P-SBITS 0>
            <CONSTANT P-SFWIM1 3>
            <CONSTANT P-SFWIM2 4>
            <CONSTANT P-SLOC1 5>
            <CONSTANT P-SLOC2 6>
            <CONSTANT P-SONUMS 3>
            <CONSTANT P-SPREP1 1>
            <CONSTANT P-SPREP2 2>
            <CONSTANT P-SYNLEN 8>
            <CONSTANT P-VERB 0>
            <CONSTANT P-VERBN 1>
            <CONSTANT SMANY 4>

            <GLOBAL P-ACLAUSE <>>
            <GLOBAL AGAIN-DIR <>>
            <GLOBAL AGAIN-LEXV <ITABLE 59 (LEXV) 0 #BYTE 0 #BYTE 0> ;<ITABLE BYTE 120>>
            <GLOBAL OOPS-INBUF <ITABLE 120 (BYTE LENGTH) 0> ;<ITABLE BYTE 60>>
            <GLOBAL OOPS-TABLE <TABLE <> <> <> <>>>
            <GLOBAL P-BUTS <ITABLE NONE 50>>
            <GLOBAL P-CONT <>>
            <GLOBAL P-INBUF <ITABLE 120 (BYTE LENGTH) 0> ;<ITABLE BYTE 60>>
            <GLOBAL P-ITBL <TABLE 0 0 0 0 0 0 0 0 0 0>>
            <GLOBAL P-LEN 0>
            <GLOBAL P-LEXV <ITABLE 59 (LEXV) 0 #BYTE 0 #BYTE 0> ;<ITABLE BYTE 120>>
            <GLOBAL P-MERGED <>>
            <GLOBAL P-NCN 0>
            <GLOBAL P-OFLAG <>>
            <GLOBAL P-OTBL <TABLE 0 0 0 0 0 0 0 0 0 0>>
            <GLOBAL P-OVTBL <TABLE 0 #BYTE 0 #BYTE 0>>
            <GLOBAL P-PRSI <ITABLE NONE 50>>
            <GLOBAL P-PRSO <ITABLE NONE 50>>
            <GLOBAL P-VTBL <TABLE 0 0 0 0>>
            <GLOBAL P-WON <>>
            <GLOBAL QUOTE-FLAG <>>
            <GLOBAL RESERVE-LEXV <ITABLE 59 (LEXV) 0 #BYTE 0 #BYTE 0> ;<ITABLE BYTE 120>>
            <GLOBAL RESERVE-PTR <>>

            ;"Put contents of one INBUF into another"
            <ROUTINE INBUF-STUFF (SRC DEST "AUX" CNT)
                 <SET CNT <- <GETB .SRC 0> 1>>
                 <REPEAT ()
                     <PUTB .DEST .CNT <GETB .SRC .CNT>>
                     <COND (<DLESS? CNT 0> <RETURN>)>>>

            ;"Put the word in the positions specified from P-INBUF to the end of
            OOPS-INBUF, leaving the appropriate pointers in AGAIN-LEXV"
            <ROUTINE INBUF-ADD (LEN BEG SLOT "AUX" DBEG (CTR 0) TMP)
                 <COND (<SET TMP <GET ,OOPS-TABLE ,O-END>>
                    <SET DBEG .TMP>)
                       (T
                    <SET DBEG <+ <GETB ,AGAIN-LEXV
                               <SET TMP <GET ,OOPS-TABLE ,O-LENGTH>>>
                             <GETB ,AGAIN-LEXV <+ .TMP 1>>>>)>
                 <PUT ,OOPS-TABLE ,O-END <+ .DBEG .LEN>>
                 <REPEAT ()
                  <PUTB ,OOPS-INBUF <+ .DBEG .CTR> <GETB ,P-INBUF <+ .BEG .CTR>>>
                  <SET CTR <+ .CTR 1>>
                  <COND (<EQUAL? .CTR .LEN> <RETURN>)>>
                 <PUTB ,AGAIN-LEXV .SLOT .DBEG>
                 <PUTB ,AGAIN-LEXV <- .SLOT 1> .LEN>>

            <ROUTINE ORPHAN-MERGE ("AUX" (CNT -1) TEMP VERB BEG END (ADJ <>) WRD)
               <SETG P-OFLAG <>>
               <COND (<OR <EQUAL? <WT? <SET WRD <GET <GET ,P-ITBL ,P-VERBN> 0>>
                           ,PS?VERB ,P1?VERB>
                          <GET ,P-OTBL ,P-VERB>>
                      <NOT <ZERO? <WT? .WRD ,PS?ADJECTIVE>>>>
                  <SET ADJ T>)
                 (<AND <NOT <ZERO? <WT? .WRD ,PS?OBJECT ,P1?OBJECT>>>
                       <EQUAL? ,P-NCN 0>>
                  <PUT ,P-ITBL ,P-VERB 0>
                  <PUT ,P-ITBL ,P-VERBN 0>
                  <PUT ,P-ITBL ,P-NC1 <REST ,P-LEXV 2>>
                  <PUT ,P-ITBL ,P-NC1L <REST ,P-LEXV 6>>
                  <SETG P-NCN 1>)>
               <COND (<AND <NOT <ZERO? <SET VERB <GET ,P-ITBL ,P-VERB>>>>
                       <NOT .ADJ>
                       <NOT <EQUAL? .VERB <GET ,P-OTBL ,P-VERB>>>>
                  <RFALSE>)
                 (<EQUAL? ,P-NCN 2> <RFALSE>)
                 (<EQUAL? <GET ,P-OTBL ,P-NC1> 1>
                  <COND (<OR <EQUAL? <SET TEMP <GET ,P-ITBL ,P-PREP1>>
                          <GET ,P-OTBL ,P-PREP1>>
                         <ZERO? .TEMP>>
                     <COND (.ADJ
                        <PUT ,P-OTBL ,P-NC1 <REST ,P-LEXV 2>>
                        <COND (<ZERO? <GET ,P-ITBL ,P-NC1L>>
                               <PUT ,P-ITBL ,P-NC1L <REST ,P-LEXV 6>>)>
                        <COND (<ZERO? ,P-NCN> <SETG P-NCN 1>)>)
                           (T
                        <PUT ,P-OTBL ,P-NC1 <GET ,P-ITBL ,P-NC1>>)>
                     <PUT ,P-OTBL ,P-NC1L <GET ,P-ITBL ,P-NC1L>>)
                    (T <RFALSE>)>)
                 (<EQUAL? <GET ,P-OTBL ,P-NC2> 1>
                  <COND (<OR <EQUAL? <SET TEMP <GET ,P-ITBL ,P-PREP1>>
                          <GET ,P-OTBL ,P-PREP2>>
                         <ZERO? .TEMP>>
                     <COND (.ADJ
                        <PUT ,P-ITBL ,P-NC1 <REST ,P-LEXV 2>>
                        <COND (<ZERO? <GET ,P-ITBL ,P-NC1L>>
                               <PUT ,P-ITBL ,P-NC1L <REST ,P-LEXV 6>>)>)>
                     <PUT ,P-OTBL ,P-NC2 <GET ,P-ITBL ,P-NC1>>
                     <PUT ,P-OTBL ,P-NC2L <GET ,P-ITBL ,P-NC1L>>
                     <SETG P-NCN 2>)
                    (T <RFALSE>)>)
                 (<NOT <ZERO? ,P-ACLAUSE>>
                  <COND (<AND <NOT <EQUAL? ,P-NCN 1>> <NOT .ADJ>>
                     <SETG P-ACLAUSE <>>
                     <RFALSE>)
                    (T
                     <SET BEG <GET ,P-ITBL ,P-NC1>>
                     <COND (.ADJ <SET BEG <REST ,P-LEXV 2>> <SET ADJ <>>)>
                     <SET END <GET ,P-ITBL ,P-NC1L>>
                     <REPEAT ()
                         <SET WRD <GET .BEG 0>>
                         <COND (<EQUAL? .BEG .END>
                            <COND (.ADJ <ACLAUSE-WIN .ADJ> <RETURN>)
                                  (T <SETG P-ACLAUSE <>> <RFALSE>)>)
                               (<AND <NOT .ADJ>
                                 <OR <BTST <GETB .WRD ,P-PSOFF>
                                       ,PS?ADJECTIVE>
                                 <EQUAL? .WRD ,W?ALL ,W?ONE>>>
                            <SET ADJ .WRD>)
                               (<EQUAL? .WRD ,W?ONE>
                            <ACLAUSE-WIN .ADJ>
                            <RETURN>)
                               (<BTST <GETB .WRD ,P-PSOFF> ,PS?OBJECT>
                            <COND (<EQUAL? .WRD ,P-ANAM>
                                   <ACLAUSE-WIN .ADJ>)
                                  (T
                                   <NCLAUSE-WIN>)>
                            <RETURN>)>
                         <SET BEG <REST .BEG ,P-WORDLEN>>
                         <COND (<EQUAL? .END 0>
                            <SET END .BEG>
                            <SETG P-NCN 1>
                            <PUT ,P-ITBL ,P-NC1 <BACK .BEG 4>>
                            <PUT ,P-ITBL ,P-NC1L .BEG>)>>)>)>
               <PUT ,P-VTBL 0 <GET ,P-OVTBL 0>>
               <PUTB ,P-VTBL 2 <GETB ,P-OVTBL 2>>
               <PUTB ,P-VTBL 3 <GETB ,P-OVTBL 3>>
               <PUT ,P-OTBL ,P-VERBN ,P-VTBL>
               <PUTB ,P-VTBL 2 0>
               <REPEAT ()
                   <COND (<G? <SET CNT <+ .CNT 1>> ,P-ITBLLEN>
                      <SETG P-MERGED T>
                      <RTRUE>)
                     (T <PUT ,P-ITBL .CNT <GET ,P-OTBL .CNT>>)>>
               T>

            <ROUTINE STUFF (SRC DEST "OPTIONAL" (MAX 29) "AUX" (PTR ,P-LEXSTART) (CTR 1) BPTR)
                 <PUTB .DEST 0 <GETB .SRC 0>>
                 <PUTB .DEST 1 <GETB .SRC 1>>
                 <REPEAT ()
                  <PUT .DEST .PTR <GET .SRC .PTR>>
                  <SET BPTR <+ <* .PTR 2> 2>>
                  <PUTB .DEST .BPTR <GETB .SRC .BPTR>>
                  <SET BPTR <+ <* .PTR 2> 3>>
                  <PUTB .DEST .BPTR <GETB .SRC .BPTR>>
                  <SET PTR <+ .PTR ,P-LEXELEN>>
                  <COND (<IGRTR? CTR .MAX>
                     <RETURN>)>>>

            <ROUTINE TAKE-CHECK ()
                <AND <ITAKE-CHECK ,P-PRSO <GETB ,P-SYNTAX ,P-SLOC1>>
                     <ITAKE-CHECK ,P-PRSI <GETB ,P-SYNTAX ,P-SLOC2>>>>

            <ROUTINE MANY-CHECK ("AUX" (LOSS <>) TMP)
                <COND (<AND <G? <GET ,P-PRSO ,P-MATCHLEN> 1>
                        <NOT <BTST <GETB ,P-SYNTAX ,P-SLOC1> ,SMANY>>>
                       <SET LOSS 1>)
                      (<AND <G? <GET ,P-PRSI ,P-MATCHLEN> 1>
                        <NOT <BTST <GETB ,P-SYNTAX ,P-SLOC2> ,SMANY>>>
                       <SET LOSS 2>)>
                <COND (.LOSS
                       <TELL "You can't use multiple ">
                       <COND (<EQUAL? .LOSS 2> <TELL "in">)>
                       <TELL "direct objects with \"">
                       <SET TMP <GET ,P-ITBL ,P-VERBN>>
                       <COND (<ZERO? .TMP> <TELL "tell">)
                         (<OR ,P-OFLAG ,P-MERGED>
                          <PRINTB <GET .TMP 0>>)
                         (T
                          <WORD-PRINT <GETB .TMP 2> <GETB .TMP 3>>)>
                       <TELL "\"." CR>
                       <RFALSE>)
                      (T)>>

            <ROUTINE SYNTAX-CHECK ("AUX" SYN LEN NUM OBJ
                                   (DRIVE1 <>) (DRIVE2 <>) PREP VERB TMP)
                <COND (<ZERO? <SET VERB <GET ,P-ITBL ,P-VERB>>>
                       <TELL "There was no verb in that sentence!" CR>
                       <RFALSE>)>
                <SET SYN <GET ,VERBS <- 255 .VERB>>>
                <SET LEN <GETB .SYN 0>>
                <SET SYN <REST .SYN>>
                <REPEAT ()
                    <SET NUM <BAND <GETB .SYN ,P-SBITS> ,P-SONUMS>>
                    <COND (<G? ,P-NCN .NUM> T)
                          (<AND <NOT <L? .NUM 1>>
                            <ZERO? ,P-NCN>
                            <OR <ZERO? <SET PREP <GET ,P-ITBL ,P-PREP1>>>
                            <EQUAL? .PREP <GETB .SYN ,P-SPREP1>>>>
                           <SET DRIVE1 .SYN>)
                          (<EQUAL? <GETB .SYN ,P-SPREP1> <GET ,P-ITBL ,P-PREP1>>
                           <COND (<AND <EQUAL? .NUM 2> <EQUAL? ,P-NCN 1>>
                              <SET DRIVE2 .SYN>)
                             (<EQUAL? <GETB .SYN ,P-SPREP2>
                               <GET ,P-ITBL ,P-PREP2>>
                              <SYNTAX-FOUND .SYN>
                              <RTRUE>)>)>
                    <COND (<DLESS? LEN 1>
                           <COND (<OR .DRIVE1 .DRIVE2> <RETURN>)
                             (T
                              <TELL
            "That sentence isn't one I recognize." CR>
                              <RFALSE>)>)
                          (T <SET SYN <REST .SYN ,P-SYNLEN>>)>>
                <COND (<AND .DRIVE1
                        <SET OBJ
                         <GWIM <GETB .DRIVE1 ,P-SFWIM1>
                               <GETB .DRIVE1 ,P-SLOC1>
                               <GETB .DRIVE1 ,P-SPREP1>>>>
                       <PUT ,P-PRSO ,P-MATCHLEN 1>
                       <PUT ,P-PRSO 1 .OBJ>
                       <SYNTAX-FOUND .DRIVE1>)
                      (<AND .DRIVE2
                        <SET OBJ
                         <GWIM <GETB .DRIVE2 ,P-SFWIM2>
                               <GETB .DRIVE2 ,P-SLOC2>
                               <GETB .DRIVE2 ,P-SPREP2>>>>
                       <PUT ,P-PRSI ,P-MATCHLEN 1>
                       <PUT ,P-PRSI 1 .OBJ>
                       <SYNTAX-FOUND .DRIVE2>)
                      (<EQUAL? .VERB ,ACT?FIND>
                       <TELL "That question can't be answered." CR>
                       <RFALSE>)
                      (<NOT <EQUAL? ,WINNER ,PLAYER>>
                       <CANT-ORPHAN>)
                      (T
                       <ORPHAN .DRIVE1 .DRIVE2>
                       <TELL "What do you want to ">
                       <SET TMP <GET ,P-OTBL ,P-VERBN>>
                       <COND (<EQUAL? .TMP 0> <TELL "tell">)
                         (<ZERO? <GETB ,P-VTBL 2>>
                          <PRINTB <GET .TMP 0>>)
                         (T
                          <WORD-PRINT <GETB .TMP 2> <GETB .TMP 3>>
                          <PUTB ,P-VTBL 2 0>)>
                       <COND (.DRIVE2
                          <TELL " ">
                          <THING-PRINT T T>)>
                       <SETG P-OFLAG T>
                       <PREP-PRINT <COND (.DRIVE1 <GETB .DRIVE1 ,P-SPREP1>)
                             (T <GETB .DRIVE2 ,P-SPREP2>)>>
                       <TELL "?" CR>
                       <RFALSE>)>>

            <ROUTINE PARSER ("AUX" (PTR ,P-LEXSTART) WRD (VAL 0) (VERB <>) (OF-FLAG <>)
                           OWINNER OMERGED LEN (DIR <>) (NW 0) (LW 0) (CNT -1))
                <REPEAT ()
                    <COND (<G? <SET CNT <+ .CNT 1>> ,P-ITBLLEN> <RETURN>)
                          (T
                           <COND (<NOT ,P-OFLAG>
                              <PUT ,P-OTBL .CNT <GET ,P-ITBL .CNT>>)>
                           <PUT ,P-ITBL .CNT 0>)>>
                <SET OWINNER ,WINNER>
                <SET OMERGED ,P-MERGED>
                <SETG P-ADVERB <>>
                <SETG P-MERGED <>>
                <SETG P-END-ON-PREP <>>
                <PUT ,P-PRSO ,P-MATCHLEN 0>
                <PUT ,P-PRSI ,P-MATCHLEN 0>
                <PUT ,P-BUTS ,P-MATCHLEN 0>
                <COND (<AND <NOT ,QUOTE-FLAG> <N==? ,WINNER ,PLAYER>>
                       <SETG WINNER ,PLAYER>
                       <SETG HERE <META-LOC ,PLAYER>>
                       ;<COND (<NOT <FSET? <LOC ,WINNER> ,VEHBIT>>
                          <SETG HERE <LOC ,WINNER>>)>
                       <SETG LIT <LIT? ,HERE>>)>
                <COND (,RESERVE-PTR
                       <SET PTR ,RESERVE-PTR>
                       <STUFF ,RESERVE-LEXV ,P-LEXV>
                       <COND (<AND <NOT ,SUPER-BRIEF> <EQUAL? ,PLAYER ,WINNER>>
                          <CRLF>)>
                       <SETG RESERVE-PTR <>>
                       <SETG P-CONT <>>)
                      (,P-CONT
                       <SET PTR ,P-CONT>
                       <COND (<AND <NOT ,SUPER-BRIEF>
                           <EQUAL? ,PLAYER ,WINNER>
                           <NOT <VERB? SAY>>>
                          <CRLF>)>
                       <SETG P-CONT <>>)
                      (T
                       <SETG WINNER ,PLAYER>
                       <SETG QUOTE-FLAG <>>
                       <COND (<NOT <FSET? <LOC ,WINNER> ,VEHBIT>>
                          <SETG HERE <LOC ,WINNER>>)>
                       <SETG LIT <LIT? ,HERE>>
                       <COND (<NOT ,SUPER-BRIEF> <CRLF>)>
                       <TELL ">">
                       <READ ,P-INBUF ,P-LEXV>)>
                <SETG P-LEN <GETB ,P-LEXV ,P-LEXWORDS>>
                <COND (<ZERO? ,P-LEN> <TELL "I beg your pardon?" CR> <RFALSE>)>
                <COND (<EQUAL? <SET WRD <GET ,P-LEXV .PTR>> ,W?OOPS>
                       <COND (<EQUAL? <GET ,P-LEXV <+ .PTR ,P-LEXELEN>>
                              ,W?PERIOD ,W?COMMA>
                          <SET PTR <+ .PTR ,P-LEXELEN>>
                          <SETG P-LEN <- ,P-LEN 1>>)>
                       <COND (<NOT <G? ,P-LEN 1>>
                          <TELL "I can't help your clumsiness." CR>
                          <RFALSE>)
                         (<GET ,OOPS-TABLE ,O-PTR>
                          <COND (<AND <G? ,P-LEN 2>
                              <EQUAL? <GET ,P-LEXV <+ .PTR ,P-LEXELEN>>
                                  ,W?QUOTE>>
                             <TELL
            "Sorry, you can't correct mistakes in quoted text." CR>
                             <RFALSE>)
                            (<G? ,P-LEN 2>
                             <TELL
            "Warning: only the first word after OOPS is used." CR>)>
                          <PUT ,AGAIN-LEXV <GET ,OOPS-TABLE ,O-PTR>
                           <GET ,P-LEXV <+ .PTR ,P-LEXELEN>>>
                          <SETG WINNER .OWINNER> ;"maybe fix oops vs. chars.?"
                          <INBUF-ADD <GETB ,P-LEXV <+ <* .PTR ,P-LEXELEN> 6>>
                             <GETB ,P-LEXV <+ <* .PTR ,P-LEXELEN> 7>>
                             <+ <* <GET ,OOPS-TABLE ,O-PTR> ,P-LEXELEN> 3>>
                          <STUFF ,AGAIN-LEXV ,P-LEXV>
                          <SETG P-LEN <GETB ,P-LEXV ,P-LEXWORDS>>
                          <SET PTR <GET ,OOPS-TABLE ,O-START>>
                          <INBUF-STUFF ,OOPS-INBUF ,P-INBUF>)
                         (T
                          <PUT ,OOPS-TABLE ,O-END <>>
                          <TELL "There was no word to replace!" CR>
                          <RFALSE>)>)
                      (T
                       <COND (<NOT <EQUAL? .WRD ,W?AGAIN ,W?G>>
                          <SETG P-NUMBER 0>)>
                       <PUT ,OOPS-TABLE ,O-END <>>)>
                <COND (<EQUAL? <GET ,P-LEXV .PTR> ,W?AGAIN ,W?G>
                       <COND (<ZERO? <GETB ,OOPS-INBUF 1>>
                          <TELL "Beg pardon?" CR>
                          <RFALSE>)
                         (,P-OFLAG
                          <TELL "It's difficult to repeat fragments." CR>
                          <RFALSE>)
                         (<NOT ,P-WON>
                          <TELL "That would just repeat a mistake." CR>
                          <RFALSE>)
                         (<G? ,P-LEN 1>
                          <COND (<OR <EQUAL? <GET ,P-LEXV <+ .PTR ,P-LEXELEN>>
                                ,W?PERIOD ,W?COMMA ,W?THEN>
                             <EQUAL? <GET ,P-LEXV <+ .PTR ,P-LEXELEN>>
                                ,W?AND>>
                             <SET PTR <+ .PTR <* 2 ,P-LEXELEN>>>
                             <PUTB ,P-LEXV ,P-LEXWORDS
                               <- <GETB ,P-LEXV ,P-LEXWORDS> 2>>)
                            (T
                             <TELL "I couldn't understand that sentence." CR>
                             <RFALSE>)>)
                         (T
                          <SET PTR <+ .PTR ,P-LEXELEN>>
                          <PUTB ,P-LEXV ,P-LEXWORDS
                            <- <GETB ,P-LEXV ,P-LEXWORDS> 1>>)>
                       <COND (<G? <GETB ,P-LEXV ,P-LEXWORDS> 0>
                          <STUFF ,P-LEXV ,RESERVE-LEXV>
                          <SETG RESERVE-PTR .PTR>)
                         (T
                          <SETG RESERVE-PTR <>>)>
                       ;<SETG P-LEN <GETB ,AGAIN-LEXV ,P-LEXWORDS>>
                       <SETG WINNER .OWINNER>
                       <SETG P-MERGED .OMERGED>
                       <INBUF-STUFF ,OOPS-INBUF ,P-INBUF>
                       <STUFF ,AGAIN-LEXV ,P-LEXV>
                       <SET CNT -1>
                       <SET DIR ,AGAIN-DIR>
                       <REPEAT ()
                    <COND (<IGRTR? CNT ,P-ITBLLEN> <RETURN>)
                          (T <PUT ,P-ITBL .CNT <GET ,P-OTBL .CNT>>)>>)
                      (T
                       <STUFF ,P-LEXV ,AGAIN-LEXV>
                       <INBUF-STUFF ,P-INBUF ,OOPS-INBUF>
                       <PUT ,OOPS-TABLE ,O-START .PTR>
                       <PUT ,OOPS-TABLE ,O-LENGTH <* 4 ,P-LEN>>
                       <SET LEN
                        <* 2 <+ .PTR <* ,P-LEXELEN <GETB ,P-LEXV ,P-LEXWORDS>>>>>
                       <PUT ,OOPS-TABLE ,O-END <+ <GETB ,P-LEXV <- .LEN 1>>
                                  <GETB ,P-LEXV <- .LEN 2>>>>
                       <SETG RESERVE-PTR <>>
                       <SET LEN ,P-LEN>
                       <SETG P-DIR <>>
                       <SETG P-NCN 0>
                       <SETG P-GETFLAGS 0>
                       <REPEAT ()
                    <COND (<L? <SETG P-LEN <- ,P-LEN 1>> 0>
                           <SETG QUOTE-FLAG <>>
                           <RETURN>)
                          (<OR <SET WRD <GET ,P-LEXV .PTR>>
                           <SET WRD <NUMBER? .PTR>>>
                           <COND (<ZERO? ,P-LEN> <SET NW 0>)
                             (T <SET NW <GET ,P-LEXV <+ .PTR ,P-LEXELEN>>>)>
                           <COND (<AND <EQUAL? .WRD ,W?TO>
                               <EQUAL? .VERB ,ACT?TELL ;,ACT?ASK>>
                              <SET WRD ,W?QUOTE>)
                             (<AND <EQUAL? .WRD ,W?THEN>
                               <G? ,P-LEN 0>
                               <NOT .VERB>
                               <NOT ,QUOTE-FLAG> ;"Last NOT added 7/3">
                              <COND (<EQUAL? .LW 0 ,W?PERIOD>
                                 <SET WRD ,W?THE>)
                                (ELSE
                                 <PUT ,P-ITBL ,P-VERB ,ACT?TELL>
                                 <PUT ,P-ITBL ,P-VERBN 0>
                                 <SET WRD ,W?QUOTE>)>)>
                           <COND (<EQUAL? .WRD ,W?THEN ,W?PERIOD ,W?QUOTE>
                              <COND (<EQUAL? .WRD ,W?QUOTE>
                                 <COND (,QUOTE-FLAG
                                    <SETG QUOTE-FLAG <>>)
                                   (T <SETG QUOTE-FLAG T>)>)>
                              <OR <ZERO? ,P-LEN>
                              <SETG P-CONT <+ .PTR ,P-LEXELEN>>>
                              <PUTB ,P-LEXV ,P-LEXWORDS ,P-LEN>
                              <RETURN>)
                             (<AND <SET VAL
                                <WT? .WRD
                                     ,PS?DIRECTION
                                     ,P1?DIRECTION>>
                               <EQUAL? .VERB <> ,ACT?WALK>
                               <OR <EQUAL? .LEN 1>
                                   <AND <EQUAL? .LEN 2>
                                    <EQUAL? .VERB ,ACT?WALK>>
                                   <AND <EQUAL? .NW
                                            ,W?THEN
                                            ,W?PERIOD
                                            ,W?QUOTE>
                                    <NOT <L? .LEN 2>>>
                                   <AND ,QUOTE-FLAG
                                    <EQUAL? .LEN 2>
                                    <EQUAL? .NW ,W?QUOTE>>
                                   <AND <G? .LEN 2>
                                    <EQUAL? .NW ,W?COMMA ,W?AND>>>>
                              <SET DIR .VAL>
                              <COND (<EQUAL? .NW ,W?COMMA ,W?AND>
                                 <PUT ,P-LEXV
                                  <+ .PTR ,P-LEXELEN>
                                  ,W?THEN>)>
                              <COND (<NOT <G? .LEN 2>>
                                 <SETG QUOTE-FLAG <>>
                                 <RETURN>)>)
                             (<AND <SET VAL <WT? .WRD ,PS?VERB ,P1?VERB>>
                               <NOT .VERB>>
                              <SET VERB .VAL>
                              <PUT ,P-ITBL ,P-VERB .VAL>
                              <PUT ,P-ITBL ,P-VERBN ,P-VTBL>
                              <PUT ,P-VTBL 0 .WRD>
                              <PUTB ,P-VTBL 2 <GETB ,P-LEXV
                                        <SET CNT
                                         <+ <* .PTR 2> 2>>>>
                              <PUTB ,P-VTBL 3 <GETB ,P-LEXV <+ .CNT 1>>>)
                             (<OR <SET VAL <WT? .WRD ,PS?PREPOSITION 0>>
                              <EQUAL? .WRD ,W?ALL ,W?ONE ;,W?BOTH>
                              <WT? .WRD ,PS?ADJECTIVE>
                              <WT? .WRD ,PS?OBJECT>>
                              <COND (<AND <G? ,P-LEN 1>
                                  <EQUAL? .NW ,W?OF>
                                  <ZERO? .VAL>
                                  <NOT <EQUAL? .WRD
                                           ,W?ALL ,W?ONE ,W?A>>
                                  ;<NOT <EQUAL? .WRD ,W?BOTH>>>
                                 <SET OF-FLAG T>)
                                (<AND <NOT <ZERO? .VAL>>
                                      <OR <ZERO? ,P-LEN>
                                      <EQUAL? .NW ,W?THEN ,W?PERIOD>>>
                                 <SETG P-END-ON-PREP T>
                                 <COND (<L? ,P-NCN 2>
                                    <PUT ,P-ITBL ,P-PREP1 .VAL>
                                    <PUT ,P-ITBL ,P-PREP1N .WRD>)>)
                                (<EQUAL? ,P-NCN 2>
                                 <TELL
            "There were too many nouns in that sentence." CR>
                                 <RFALSE>)
                                (T
                                 <SETG P-NCN <+ ,P-NCN 1>>
                                 <SETG P-ACT .VERB>
                                 <OR <SET PTR <CLAUSE .PTR .VAL .WRD>>
                                 <RFALSE>>
                                 <COND (<L? .PTR 0>
                                    <SETG QUOTE-FLAG <>>
                                    <RETURN>)>)>)
                             (<EQUAL? .WRD ,W?OF>
                              <COND (<OR <NOT .OF-FLAG>
                                 <EQUAL? .NW ,W?PERIOD ,W?THEN>>
                                 <CANT-USE .PTR>
                                 <RFALSE>)
                                (T
                                 <SET OF-FLAG <>>)>)
                             (<WT? .WRD ,PS?BUZZ-WORD>)
                             (<AND <EQUAL? .VERB ,ACT?TELL>
                               <WT? .WRD ,PS?VERB ,P1?VERB>
                               <EQUAL? ,WINNER ,PLAYER>>
                              <TELL
            "Please consult your manual for the correct way to talk to other people
            or creatures." CR>
                              <RFALSE>)
                             (T
                              <CANT-USE .PTR>
                              <RFALSE>)>)
                          (T
                           <UNKNOWN-WORD .PTR>
                           <RFALSE>)>
                    <SET LW .WRD>
                    <SET PTR <+ .PTR ,P-LEXELEN>>>)>
                <PUT ,OOPS-TABLE ,O-PTR <>>
                <COND (.DIR
                       <SETG PRSA ,V?WALK>
                       <SETG PRSO .DIR>
                       <SETG P-OFLAG <>>
                       <SETG P-WALK-DIR .DIR>
                       <SETG AGAIN-DIR .DIR>)
                      (ELSE
                       <COND (,P-OFLAG <ORPHAN-MERGE>)>
                       <SETG P-WALK-DIR <>>
                       <SETG AGAIN-DIR <>>
                       <COND (<AND <SYNTAX-CHECK>
                           <SNARF-OBJECTS>
                           <MANY-CHECK>
                           <TAKE-CHECK>>
                          T)>)>>
        """#)
    }

    func testParser() throws {
        XCTAssertNoDifference(
            Game.routines.find("parser"),
            Statement(
                id: "parser",
                code: #"""
                    @discardableResult
                    /// The `parser` (PARSER) routine.
                    func parser() throws -> Bool {
                        var ptr: Int? = Constants.pLexstart
                        var wrd: Word?
                        var val = false
                        var verb: Verb?
                        var ofFlag = false
                        var owinner: Object?
                        var omerged = false
                        var len = 0
                        var dir = false
                        var nw: TableElement?
                        var lw: Word?
                        var cnt = -1
                        while true {
                            if cnt.set(to: cnt.add(1)).isGreaterThan(Constants.pItbllen) {
                                break
                            } else {
                                if .isNot(Globals.pOflag) {
                                    try Globals.pOtbl.put(
                                        element: try Globals.pItbl.get(at: cnt),
                                        at: cnt
                                    )
                                }
                                try Globals.pItbl.put(
                                    element: 0,
                                    at: cnt
                                )
                            }
                        }
                        owinner.set(to: Globals.winner)
                        omerged.set(to: Globals.pMerged)
                        pAdverb.set(to: false)
                        Globals.pMerged.set(to: false)
                        pEndOnPrep.set(to: false)
                        try Globals.pPrso.put(
                            element: 0,
                            at: Globals.pMatchlen
                        )
                        try Globals.pPrsi.put(
                            element: 0,
                            at: Globals.pMatchlen
                        )
                        try Globals.pButs.put(
                            element: 0,
                            at: Globals.pMatchlen
                        )
                        if .and(
                            .isNot(Globals.quoteFlag),
                            Globals.winner.isNotEqualTo(Globals.player)
                        ) {
                            Globals.winner.set(to: Globals.player)
                            Globals.here?.set(to: metaLoc(obj: Globals.player))
                            // <COND (<NOT <FSET? <LOC ,WINNER> ,VEHBIT>> <SETG HERE <LOC ,WINNER>>)>
                            Globals.lit.set(to: try isLit(rm: Globals.here))
                        }
                        if let Globals.reservePtr {
                            ptr.set(to: Globals.reservePtr)
                            try stuff(
                                src: Globals.reserveLexv,
                                dest: Globals.pLexv
                            )
                            if .and(
                                .isNot(Globals.superBrief),
                                Globals.player.equals(Globals.winner)
                            ) {
                                output("\n")
                            }
                            Globals.reservePtr.set(to: 0)
                            Globals.pCont.set(to: 0)
                        } else if let Globals.pCont {
                            ptr.set(to: Globals.pCont)
                            if .and(
                                .isNot(Globals.superBrief),
                                Globals.player.equals(Globals.winner),
                                .isNot(isParsedVerb("say"))
                            ) {
                                output("\n")
                            }
                            Globals.pCont.set(to: 0)
                        } else {
                            Globals.winner.set(to: Globals.player)
                            Globals.quoteFlag.set(to: false)
                            if .isNot(Globals.winner.parent.hasFlag(.isVehicle)) {
                                Globals.here?.set(to: Globals.winner.parent)
                            }
                            Globals.lit.set(to: try isLit(rm: Globals.here))
                            if .isNot(Globals.superBrief) {
                                output("\n")
                            }
                            output(">")
                            read(&pInbuf, &pLexv)
                        }
                        Globals.pLen.set(to: try Globals.pLexv.get(at: Constants.pLexwords))
                        if Globals.pLen.isZero {
                            output("I beg your pardon?")
                            return false
                        }
                        if wrd.set(to: try Globals.pLexv.get(at: ptr)).equals(Word.oops) {
                            if try Globals.pLexv.get(at: ptr.add(Constants.pLexelen)).equals(Word.period, Word.comma) {
                                ptr.set(to: ptr.add(Constants.pLexelen))
                                Globals.pLen.set(to: Globals.pLen.subtract(1))
                            }
                            if .isNot(Globals.pLen.isGreaterThan(1)) {
                                output("I can't help your clumsiness.")
                                return false
                            } else if _ = try Globals.oopsTable.get(at: Constants.oPtr) {
                                if .and(
                                    Globals.pLen.isGreaterThan(2),
                                    try Globals.pLexv.get(at: ptr.add(Constants.pLexelen)).equals(Word.quote)
                                ) {
                                    output("Sorry, you can't correct mistakes in quoted text.")
                                    return false
                                } else if Globals.pLen.isGreaterThan(2) {
                                    output("Warning: only the first word after OOPS is used.")
                                }
                                try Globals.againLexv.put(
                                    element: try Globals.pLexv.get(at: ptr.add(Constants.pLexelen)),
                                    at: try Globals.oopsTable.get(at: Constants.oPtr)
                                )
                                Globals.winner.set(to: owinner)
                                // "maybe fix oops vs. chars.?"
                                try inbufAdd(
                                    len: try Globals.pLexv.get(at: ptr.multiply(Constants.pLexelen).add(6)),
                                    beg: try Globals.pLexv.get(at: ptr.multiply(Constants.pLexelen).add(7)),
                                    slot: try Globals.oopsTable.get(at: Constants.oPtr).multiply(Constants.pLexelen).add(3)
                                )
                                try stuff(
                                    src: Globals.againLexv,
                                    dest: Globals.pLexv
                                )
                                Globals.pLen.set(to: try Globals.pLexv.get(at: Constants.pLexwords))
                                ptr.set(to: try Globals.oopsTable.get(at: Constants.oStart))
                                try inbufStuff(
                                    src: Globals.oopsInbuf,
                                    dest: Globals.pInbuf
                                )
                            } else {
                                try Globals.oopsTable.put(
                                    element: false,
                                    at: Constants.oEnd
                                )
                                output("There was no word to replace!")
                                return false
                            }
                        } else {
                            if .isNot(wrd.equals(Word.again, Word.g)) {
                                Globals.pNumber.set(to: 0)
                            }
                            try Globals.oopsTable.put(
                                element: false,
                                at: Constants.oEnd
                            )
                        }
                        if try Globals.pLexv.get(at: ptr).equals(Word.again, Word.g) {
                            if try Globals.oopsInbuf.get(at: 1).isZero {
                                output("Beg pardon?")
                                return false
                            } else if Globals.pOflag {
                                output("It's difficult to repeat fragments.")
                                return false
                            } else if .isNot(Globals.pWon) {
                                output("That would just repeat a mistake.")
                                return false
                            } else if Globals.pLen.isGreaterThan(1) {
                                if .or(
                                    try Globals.pLexv.get(at: ptr.add(Constants.pLexelen)).equals(Word.period, Word.comma, Word.then),
                                    try Globals.pLexv.get(at: ptr.add(Constants.pLexelen)).equals(Word.and)
                                ) {
                                    ptr.set(to: ptr.add(2.multiply(Constants.pLexelen)))
                                    try Globals.pLexv.put(
                                        element: try Globals.pLexv.get(at: Constants.pLexwords).subtract(2),
                                        at: Constants.pLexwords
                                    )
                                } else {
                                    output("I couldn't understand that sentence.")
                                    return false
                                }
                            } else {
                                ptr.set(to: ptr.add(Constants.pLexelen))
                                try Globals.pLexv.put(
                                    element: try Globals.pLexv.get(at: Constants.pLexwords).subtract(1),
                                    at: Constants.pLexwords
                                )
                            }
                            if try Globals.pLexv.get(at: Constants.pLexwords).isGreaterThan(0) {
                                try stuff(
                                    src: Globals.pLexv,
                                    dest: Globals.reserveLexv
                                )
                                Globals.reservePtr.set(to: ptr)
                            } else {
                                Globals.reservePtr.set(to: 0)
                            }
                            // <SETG P-LEN <GETB ,AGAIN-LEXV ,P-LEXWORDS>>
                            Globals.winner.set(to: owinner)
                            Globals.pMerged.set(to: omerged)
                            try inbufStuff(
                                src: Globals.oopsInbuf,
                                dest: Globals.pInbuf
                            )
                            try stuff(
                                src: Globals.againLexv,
                                dest: Globals.pLexv
                            )
                            cnt.set(to: -1)
                            dir.set(to: Globals.againDir)
                            while true {
                                if cnt.increment().isGreaterThan(pItbllen) {
                                    break
                                } else {
                                    try Globals.pItbl.put(
                                        element: try Globals.pOtbl.get(at: cnt),
                                        at: cnt
                                    )
                                }
                            }
                        } else {
                            try stuff(
                                src: Globals.pLexv,
                                dest: Globals.againLexv
                            )
                            try inbufStuff(
                                src: Globals.pInbuf,
                                dest: Globals.oopsInbuf
                            )
                            try Globals.oopsTable.put(
                                element: ptr,
                                at: Constants.oStart
                            )
                            try Globals.oopsTable.put(
                                element: 4.multiply(Globals.pLen),
                                at: Constants.oLength
                            )
                            len.set(to: 2.multiply(
                                ptr.add(
                                    Constants.pLexelen.multiply(
                                        try Globals.pLexv.get(at: Constants.pLexwords)
                                    )
                                )
                            ))
                            try Globals.oopsTable.put(
                                element: try Globals.pLexv.get(at: len.subtract(1)).add(
                                try Globals.pLexv.get(at: len.subtract(2))
                            ),
                                at: Constants.oEnd
                            )
                            Globals.reservePtr.set(to: 0)
                            len.set(to: Globals.pLen)
                            pDir.set(to: false)
                            Globals.pNcn.set(to: 0)
                            Globals.pGetflags.set(to: 0)
                            while true {
                                if Globals.pLen.set(to: Globals.pLen.subtract(1)).isLessThan(0) {
                                    Globals.quoteFlag.set(to: false)
                                    break
                                } else if _ = .or(
                                    wrd.set(to: try Globals.pLexv.get(at: ptr)),
                                    wrd.set(to: try isNumber(ptr: ptr))
                                ) {
                                    if Globals.pLen.isZero {
                                        nw.set(to: nil)
                                    } else {
                                        nw.set(to: try Globals.pLexv.get(at: ptr.add(Constants.pLexelen)))
                                    }
                                    if .and(
                                        wrd.equals(Word.to),
                                        verb.equals(Verb.tell.action)
                                    ) {
                                        wrd.set(to: Word.quote)
                                    } else if .and(
                                        wrd.equals(Word.then),
                                        Globals.pLen.isGreaterThan(0),
                                        .isNot(verb),
                                        .isNot(Globals.quoteFlag)
                                    ) {
                                        if lw.equals(nil, Word.period) {
                                            wrd.set(to: Word.the)
                                        } else {
                                            try Globals.pItbl.put(
                                                element: Verb.tell.action,
                                                at: Constants.pVerb
                                            )
                                            try Globals.pItbl.put(
                                                element: 0,
                                                at: Constants.pVerbn
                                            )
                                            wrd.set(to: Word.quote)
                                        }
                                    }
                                    if wrd.equals(Word.then, Word.period, Word.quote) {
                                        if wrd.equals(Word.quote) {
                                            if Globals.quoteFlag {
                                                Globals.quoteFlag.set(to: false)
                                            } else {
                                                Globals.quoteFlag.set(to: true)
                                            }
                                        }
                                        .or(
                                            Globals.pLen.isZero,
                                            Globals.pCont.set(to: ptr.add(Constants.pLexelen))
                                        )
                                        try Globals.pLexv.put(
                                            element: Globals.pLen,
                                            at: Constants.pLexwords
                                        )
                                        break
                                    } else if _ = .and(
                                        val.set(to: try isWt(
                                            ptr: wrd,
                                            bit: PartsOfSpeech.direction,
                                            b1: PartsOfSpeech.directionFirst
                                        )),
                                        verb.equals(nil, Verb.walk.action),
                                        .or(
                                            len.equals(1),
                                            .and(
                                                len.equals(2),
                                                verb.equals(Verb.walk.action)
                                            ),
                                            .and(
                                                nw.equals(Word.then, Word.period, Word.quote),
                                                .isNot(len.isLessThan(2))
                                            ),
                                            .and(
                                                Globals.quoteFlag,
                                                len.equals(2),
                                                nw.equals(Word.quote)
                                            ),
                                            .and(
                                                len.isGreaterThan(2),
                                                nw.equals(Word.comma, Word.and)
                                            )
                                        )
                                    ) {
                                        dir.set(to: val)
                                        if nw.equals(Word.comma, Word.and) {
                                            try Globals.pLexv.put(
                                                element: Word.then,
                                                at: ptr.add(Constants.pLexelen)
                                            )
                                        }
                                        if .isNot(len.isGreaterThan(2)) {
                                            Globals.quoteFlag.set(to: false)
                                            break
                                        }
                                    } else if _ = .and(
                                        val.set(to: try isWt(
                                            ptr: wrd,
                                            bit: PartsOfSpeech.verb,
                                            b1: PartsOfSpeech.verbFirst
                                        )),
                                        .isNot(verb)
                                    ) {
                                        verb.set(to: val)
                                        try Globals.pItbl.put(
                                            element: val,
                                            at: Constants.pVerb
                                        )
                                        try Globals.pItbl.put(
                                            element: Globals.pVtbl,
                                            at: Constants.pVerbn
                                        )
                                        try Globals.pVtbl.put(
                                            element: wrd,
                                            at: 0
                                        )
                                        try Globals.pVtbl.put(
                                            element: try Globals.pLexv.get(at: cnt.set(to: ptr.multiply(2).add(2))),
                                            at: 2
                                        )
                                        try Globals.pVtbl.put(
                                            element: try Globals.pLexv.get(at: cnt.add(1)),
                                            at: 3
                                        )
                                    } else if _ = .or(
                                        val.set(to: try isWt(
                                            ptr: wrd,
                                            bit: PartsOfSpeech.preposition,
                                            b1: 0
                                        )),
                                        wrd.equals(Word.all, Word.one),
                                        try isWt(ptr: wrd, bit: PartsOfSpeech.adjective),
                                        try isWt(ptr: wrd, bit: PartsOfSpeech.object)
                                    ) {
                                        if .and(
                                            Globals.pLen.isGreaterThan(1),
                                            nw.equals(Word.of),
                                            val.isFalse,
                                            .isNot(wrd.equals(Word.all, Word.one, Word.a))
                                        ) {
                                            ofFlag.set(to: true)
                                        } else if .and(
                                            .isNot(val.isFalse),
                                            .or(
                                                Globals.pLen.isZero,
                                                nw.equals(Word.then, Word.period)
                                            )
                                        ) {
                                            pEndOnPrep.set(to: true)
                                            if Globals.pNcn.isLessThan(2) {
                                                try Globals.pItbl.put(
                                                    element: val,
                                                    at: Constants.pPrep1
                                                )
                                                try Globals.pItbl.put(
                                                    element: wrd,
                                                    at: Constants.pPrep1N
                                                )
                                            }
                                        } else if Globals.pNcn.equals(2) {
                                            output("There were too many nouns in that sentence.")
                                            return false
                                        } else {
                                            Globals.pNcn.set(to: Globals.pNcn.add(1))
                                            pAct.set(to: verb)
                                            .or(
                                                ptr.set(to: try clause(ptr: ptr, val: val, wrd: wrd)),
                                                return false
                                            )
                                            if ptr.isLessThan(0) {
                                                Globals.quoteFlag.set(to: false)
                                                break
                                            }
                                        }
                                    } else if wrd.equals(Word.of) {
                                        if .or(
                                            .isNot(ofFlag),
                                            nw.equals(Word.period, Word.then)
                                        ) {
                                            try cantUse(ptr: ptr)
                                            return false
                                        } else {
                                            ofFlag.set(to: false)
                                        }
                                    } else if _ = try isWt(ptr: wrd, bit: PartsOfSpeech.buzzWord) {
                                        // do nothing
                                    } else if _ = .and(
                                        verb.equals(Verb.tell.action),
                                        try isWt(
                                            ptr: wrd,
                                            bit: PartsOfSpeech.verb,
                                            b1: PartsOfSpeech.verbFirst
                                        ),
                                        Globals.winner.equals(Globals.player)
                                    ) {
                                        output("""
                                            Please consult your manual for the correct way to talk to \
                                            other people or creatures.
                                            """)
                                        return false
                                    } else {
                                        try cantUse(ptr: ptr)
                                        return false
                                    }
                                } else {
                                    try unknownWord(ptr: ptr)
                                    return false
                                }
                                lw.set(to: wrd)
                                ptr.set(to: ptr.add(Constants.pLexelen))
                            }
                        }
                        try Globals.oopsTable.put(
                            element: false,
                            at: Constants.oPtr
                        )
                        if let dir {
                            Globals.parsedVerb.set(to: Verb.walk)
                            Globals.parsedDirectObject?.set(to: dir)
                            Globals.pOflag.set(to: false)
                            pWalkDir.set(to: dir)
                            Globals.againDir.set(to: dir)
                        } else {
                            if Globals.pOflag {
                                try orphanMerge()
                            }
                            pWalkDir.set(to: false)
                            Globals.againDir.set(to: false)
                            if .and(
                                try syntaxCheck(),
                                try snarfObjects(),
                                try manyCheck(),
                                takeCheck()
                            ) {
                                return true
                            }
                        }
                    }
                    """#,
                type: .booleanTrue,
                category: .routines,
                isCommittable: true,
                isThrowing: true,
                returnHandling: .passthrough
            )
        )
    }

    func testReserveLexvDeclaration() throws {
        XCTAssertNoDifference(
            Game.globals.find("reserveLexv"),
            Statement(
                id: "reserveLexv",
                code: """
                    /// The `reserveLexv` (RESERVE-LEXV) 􀎠􀁮Table global.
                    var reserveLexv = Table(
                        count: 59,
                        defaults: 0, .int8(0), .int8(0),
                        flags: .lexv
                    )
                    """,
                type: .tableDeclaration,
                category: .globals,
                isCommittable: true,
                isMutable: true,
                returnHandling: .implicit
            )
        )
    }
}
