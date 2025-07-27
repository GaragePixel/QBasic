'From Bobby Brightling
'Since: mid-1980
'Last: 2025-06-23
'Source: https://www.facebook.com/groups/2057165187928233/posts/3990423977935668/

DECLARE SUB ShowSound ()
DECLARE SUB GetName (NewName$)
DECLARE SUB CheckTop ()
DECLARE SUB LoadTopTen ()
DECLARE SUB ShowTopTen ()
DECLARE SUB SaveTopTen ()
DECLARE SUB UpScore ()
DECLARE SUB RemoveWall (Row%)
DECLARE SUB RemoveWalls ()
DECLARE SUB FindWalls ()
DECLARE SUB DropShape (Shape%, Orient%, Row%, Col%)
DECLARE FUNCTION Check% (Shape%, Orient%, Row%, Col%)
DECLARE SUB InitPlay ()
DECLARE SUB EraseShape (Shape%, Orient%, Row%, Col%)
DECLARE SUB DrawShape (Shape%, Orient%, Row%, Col%)

COMMON SHARED Pieces%(), PlayField%(), Block$, Blank$, Block2$, Score#, dtime
COMMON SHARED SoundOn%, Points%, HighScore#, ErrorFlag%, Mono%
COMMON SHARED TopTenName$(), TopTenScore#()
DIM PlayField%(11, 25) ' 10 by 20 shown, 1st 4 rows generate.
DIM TopTenName$(1 TO 10), TopTenScore#(1 TO 10)
RANDOMIZE TIMER
'
'  xxx = 1  xxx = 2  xx = 3  xxxx = 4   xx = 5  xx  = 6  xxx  = 7
'  x          x      xx                xx        xx       x
'
DIM Pieces%(1 TO 7, 3, 3, 3)
FOR Piece% = 1 TO 7
  FOR Orient% = 0 TO 3
    FOR Row% = 0 TO 3
      FOR Col% = 0 TO 3
        READ Pieces%(Piece%, Orient%, Row%, Col%)
      NEXT Col%
    NEXT Row%
  NEXT Orient%
NEXT Piece%
'
' Piece data.  Orientation order: 0, 1, 2, 3.
'
' Piece 1
DATA  0, 0, 0, 0,  -1,-1,-1, 0,   0, 0,-1, 0,   0, 0, 0, 0
DATA  0, 0, 0, 0,   0,-1,-1, 0,   0,-1, 0, 0,   0,-1, 0, 0
DATA  0, 0, 0, 0,   0,-1, 0, 0,   0,-1,-1,-1,   0, 0, 0, 0
DATA  0, 0,-1, 0,   0, 0,-1, 0,   0,-1,-1, 0,   0, 0, 0, 0
' Piece 2
DATA  0, 0, 0, 0,   0,-1,-1,-1,   0,-1, 0, 0,   0, 0, 0, 0
DATA  0,-1, 0, 0,   0,-1, 0, 0,   0,-1,-1, 0,   0, 0, 0, 0
DATA  0, 0, 0, 0,   0, 0,-1, 0,  -1,-1,-1, 0,   0, 0, 0, 0
DATA  0, 0, 0, 0,   0,-1,-1, 0,   0, 0,-1, 0,   0, 0,-1, 0
' Piece 3
DATA  0, 0, 0, 0,   0,-1,-1, 0,   0,-1,-1, 0,   0, 0, 0, 0
DATA  0, 0, 0, 0,   0,-1,-1, 0,   0,-1,-1, 0,   0, 0, 0, 0
DATA  0, 0, 0, 0,   0,-1,-1, 0,   0,-1,-1, 0,   0, 0, 0, 0
DATA  0, 0, 0, 0,   0,-1,-1, 0,   0,-1,-1, 0,   0, 0, 0, 0
' Piece 4
DATA  0, 0, 0, 0,  -1,-1,-1,-1,   0, 0, 0, 0,   0, 0, 0, 0
DATA  0,-1, 0, 0,   0,-1, 0, 0,   0,-1, 0, 0,   0,-1, 0, 0
DATA  0, 0, 0, 0,   0, 0, 0, 0,  -1,-1,-1,-1,   0, 0, 0, 0
DATA  0, 0,-1, 0,   0, 0,-1, 0,   0, 0,-1, 0,   0, 0,-1, 0
' Piece 5
DATA  0, 0, 0, 0,   0, 0,-1,-1,   0,-1,-1, 0,   0, 0, 0, 0
DATA  0,-1, 0, 0,   0,-1,-1, 0,   0, 0,-1, 0,   0, 0, 0, 0
DATA  0, 0, 0, 0,   0,-1,-1, 0,  -1,-1, 0, 0,   0, 0, 0, 0
DATA  0, 0, 0, 0,   0,-1, 0, 0,   0,-1,-1, 0,   0, 0,-1, 0
' Piece 6
DATA  0, 0, 0, 0,  -1,-1, 0, 0,   0,-1,-1, 0,   0, 0, 0, 0
DATA  0, 0, 0, 0,   0, 0,-1, 0,   0,-1,-1, 0,   0,-1, 0, 0
DATA  0, 0, 0, 0,   0,-1,-1, 0,   0, 0,-1,-1,   0, 0, 0, 0
DATA  0, 0,-1, 0,   0,-1,-1, 0,   0,-1, 0, 0,   0, 0, 0, 0
'
DATA  0, 0, 0, 0,  -1,-1,-1, 0,   0,-1, 0, 0,   0, 0, 0, 0
DATA  0, 0, 0, 0,   0,-1, 0, 0,   0,-1,-1, 0,   0,-1, 0, 0
DATA  0, 0, 0, 0,   0, 0,-1, 0,   0,-1,-1,-1,   0, 0, 0, 0
DATA  0, 0,-1, 0,   0,-1,-1, 0,   0, 0,-1, 0,   0, 0, 0, 0
'
ON ERROR GOTO ErrorTrap
KEY 15, CHR$(&H0) + CHR$(&H1F)
ON KEY(15) GOSUB SoundTog
KEY(15) ON
SCREEN 0
CLS
WIDTH 40
Mono% = 0
IF ErrorFlag% THEN
  Mono% = -1
  ErrorFlag% = 0
END IF

CALL LoadTopTen

IF Mono% THEN
  Block$ = CHR$(176) + CHR$(176)
  Block2$ = CHR$(219) + CHR$(219)
  Blank$ = CHR$(32) + CHR$(32)
ELSE
  Block$ = CHR$(254)    ' block = ў
  Block2$ = CHR$(219)   ' block2= л
  Blank$ = CHR$(32)     ' blank = space
END IF
'
SoundOn% = -1
HighScore# = 0
InitPlay
LOCATE 25, 1
COLOR 11, 0
PRINT "<Esc>=Exit, <Enter>=Start Game";
DO
LOOP UNTIL INKEY$ = ""
DO
  in.key$ = INKEY$
LOOP UNTIL in.key$ = CHR$(27) OR in.key$ = CHR$(13)
IF in.key$ = CHR$(27) THEN
  CLS
  WIDTH 80
  END
END IF
LOCATE 25, 1
PRINT STRING$(30, " ");
StartGame:
CLS
InitPlay
Gameover% = 0
Score# = 0
Points% = 0
UpScore
Shape% = INT(RND * 7) + 1
Row% = 2
Col% = INT(7 * RND) + 1
Orient% = INT(RND * 4)
dtime = .25
time0 = TIMER + dtime
n% = 0
Points% = 200
DrawShape Shape%, Orient%, Row%, Col%

DO
'  DO
'  LOOP UNTIL INKEY$ = ""
  DO
    in.key$ = INKEY$
    IF TIMER > time0 THEN
      time0 = TIMER + dtime
      in.key$ = CHR$(1)
    END IF
  LOOP UNTIL in.key$ <> ""
  IF in.key$ <> " " AND Points% > 10 THEN
    Points% = Points% - 1
    LOCATE 4, 12
    COLOR 13, 0
    PRINT USING "###"; Points%;
  END IF
  SELECT CASE in.key$
    CASE CHR$(0) + CHR$(&H4F), CHR$(0) + CHR$(&H4B), "1", "4"
      IF Check(Shape%, Orient%, Row%, Col% - 1) THEN
        EraseShape Shape%, Orient%, Row%, Col%
        Col% = Col% - 1
        DrawShape Shape%, Orient%, Row%, Col%
      END IF
      n% = 0
    CASE CHR$(0) + CHR$(&H50), "2"
      Orient1% = (Orient% + 1) MOD 4
      IF Check(Shape%, Orient1%, Row%, Col%) THEN
        EraseShape Shape%, Orient%, Row%, Col%
        Orient% = Orient1%
        DrawShape Shape%, Orient%, Row%, Col%
      END IF
      n% = 0
    CASE CHR$(0) + CHR$(&H48), "8"
      Orient1% = (Orient% + 3) MOD 4
      IF Check(Shape%, Orient1%, Row%, Col%) THEN
        EraseShape Shape%, Orient%, Row%, Col%
        Orient% = Orient1%
        DrawShape Shape%, Orient%, Row%, Col%
      END IF
      n% = 0
    CASE CHR$(0) + CHR$(&H51), CHR$(0) + CHR$(&H4D), "3", "6"
      IF Check(Shape%, Orient%, Row%, Col% + 1) THEN
        EraseShape Shape%, Orient%, Row%, Col%
        Col% = Col% + 1
        DrawShape Shape%, Orient%, Row%, Col%
      END IF
      n% = 0
    CASE "`"
      IF Check(Shape%, Orient%, Row% - 1, Col%) THEN
        EraseShape Shape%, Orient%, Row%, Col%
        Row% = Row% - 1
        DrawShape Shape%, Orient%, Row%, Col%
      END IF
      n% = 0
    CASE CHR$(27)

    CASE "s", "S"
      SoundOn% = NOT SoundOn%
      LOCATE 1, 39
      COLOR 12, 0
      IF SoundOn% THEN
        PRINT CHR$(14);
      ELSE
        PRINT " ";
      END IF
    CASE "P", "p"
      LOCATE 25, 1
      COLOR 13, 0
      PRINT "Paused...";
      WHILE INKEY$ = ""
      WEND
      LOCATE 25, 1
      PRINT "         ";
    CASE " "
      DO
        IF Check(Shape%, Orient%, Row% + 1, Col%) THEN
          EraseShape Shape%, Orient%, Row%, Col%
          Row% = Row% + 1
          DrawShape Shape%, Orient%, Row%, Col%
          n% = 0
        ELSE
          DropShape Shape%, Orient%, Row%, Col%
          Row% = 2
          Col% = INT(7 * RND) + 1
          Shape% = INT(RND * 7) + 1
          Orient% = INT(RND * 4)
          FindWalls
          FOR i% = 1 TO 10
            IF PlayField%(i%, 5) THEN
              Gameover% = -1
            END IF
          NEXT i%
          n% = 0
        END IF
      LOOP UNTIL Row% = 2
    CASE CHR$(1)
      IF Check(Shape%, Orient%, Row% + 1, Col%) THEN
        EraseShape Shape%, Orient%, Row%, Col%
        Row% = Row% + 1
        DrawShape Shape%, Orient%, Row%, Col%
      ELSE
        n% = n% + 1
        IF n% >= 3 THEN
          DropShape Shape%, Orient%, Row%, Col%
          Row% = 2
          Col% = INT(7 * RND) + 1
          Shape% = INT(RND * 7) + 1
          Orient% = INT(RND * 4)
          FindWalls
          FOR i% = 1 TO 10
            IF PlayField%(i%, 5) THEN
              Gameover% = -1
            END IF
          NEXT i%
          n% = 0
        END IF
      END IF
    CASE ELSE
  END SELECT
LOOP UNTIL in.key$ = CHR$(27) OR Gameover%
CALL CheckTop
LOCATE 25, 1
COLOR 11, 0
PRINT "Game Over. <Esc>=Exit, <Enter>=New Game";
DO
LOOP UNTIL INKEY$ = ""
DO
  in.key$ = INKEY$
LOOP UNTIL in.key$ = CHR$(27) OR in.key$ = CHR$(13)
IF in.key$ <> CHR$(27) THEN GOTO StartGame
CALL SaveTopTen
WIDTH 80
END
ErrorTrap:
  ErrorFlag% = -1
  RESUME NEXT
END
SoundTog:
  SoundOn% = NOT SoundOn%
  ShowSound
RETURN


FUNCTION Check% (Shape%, Orient%, Row%, Col%)
  Check% = -1
  y% = Row%
  FOR i% = 0 TO 3
    IF y% >= 0 AND y% <= 25 THEN
      x% = Col%
      FOR j% = 0 TO 3
        IF x% >= 0 AND x% <= 11 THEN
          IF PlayField%(x%, y%) AND Pieces%(Shape%, Orient%, i%, j%) THEN
            Check% = 0
            EXIT FUNCTION
          END IF
        END IF
        x% = x% + 1
      NEXT j%
    END IF
    y% = y% + 1
  NEXT i%
END FUNCTION

SUB CheckTop ()
  FOR i% = 1 TO 10
    IF Score# >= TopTenScore#(i%) AND Score# <> 0 THEN
      CALL GetName(NewName$)
      FOR j% = 10 TO i% + 1 STEP -1
        TopTenScore#(j%) = TopTenScore#(j% - 1)
        TopTenName$(j%) = TopTenName$(j% - 1)
      NEXT j%
      TopTenScore#(i%) = Score#
      TopTenName$(i%) = NewName$
      CALL ShowTopTen
      EXIT FOR
    END IF
  NEXT i%
END SUB

SUB DrawShape (Shape%, Orient%, Row%, Col%)

    COLOR Shape% + 8, Shape%, 0
    Row1% = Row% - 1
    IF Mono% THEN
      Col1% = 2 * Col% + 14
      XMax% = 35
    ELSE
      Col1% = Col% + 15
      XMax% = 25
    END IF
    FOR i% = 0 TO 3
      FOR j% = 0 TO 3
        IF Pieces%(Shape%, Orient%, j%, i%) THEN
          IF Mono% THEN
            x% = Col1% + i% + i%
          ELSE
            x% = Col1% + i%
          END IF
          y% = Row1% + j%
          
          IF x% >= 16 AND x% <= XMax% AND y% >= 4 AND y% <= 23 THEN
            LOCATE y%, x%
            PRINT Block$;
          END IF
        END IF
      NEXT j%
    NEXT i%
  
END SUB

SUB DropShape (Shape%, Orient%, Row%, Col%)

  y% = Row%
  FOR i% = 0 TO 3
    IF y% >= 5 AND y% <= 24 THEN
      x% = Col%
      FOR j% = 0 TO 3
        IF x% >= 1 AND x% <= 10 THEN
          IF Pieces%(Shape%, Orient%, i%, j%) THEN
            PlayField%(x%, y%) = -1
             IF Mono% THEN
               LOCATE y% - 1, x% + x% + 14
               PRINT Block2$;
             END IF
          END IF
        END IF
        x% = x% + 1
      NEXT j%
    END IF
    y% = y% + 1
  NEXT i%

END SUB

SUB EraseShape (Shape%, Orient%, Row%, Col%)

    COLOR 0, 0
    Row1% = Row% - 1
    IF Mono% THEN
      Col1% = 2 * Col% + 14
      XMax% = 35
    ELSE
      Col1% = Col% + 15
      XMax% = 25
    END IF
    FOR i% = 0 TO 3
      FOR j% = 0 TO 3
        IF Pieces%(Shape%, Orient%, j%, i%) THEN
          IF Mono% THEN
            x% = Col1% + i% + i%
          ELSE
            x% = Col1% + i%
          END IF
          y% = Row1% + j%
          IF x% >= 16 AND x% <= XMax% AND y% >= 4 AND y% <= 23 THEN
            LOCATE y%, x%
            PRINT Blank$;
          END IF
        END IF
      NEXT j%
    NEXT i%

END SUB

SUB FindWalls ()

  FOR j% = 24 TO 5 STEP -1
    DO
      Sum% = 0
      FOR i% = 1 TO 10
        Sum% = Sum% + PlayField%(i%, j%)
      NEXT i%
      IF (Sum% = -10) THEN
        RemoveWall j%
        UpScore

      END IF
    LOOP UNTIL Sum% <> -10
  NEXT j%

END SUB

SUB GetName (NewName$)
 
LOCATE 25, 1
COLOR 11, 0
PRINT "You made the Top-10!  Initials:";
COLOR 14, 0
NewName$ = "---"
p% = 1
DO
  LOCATE 25, 33
  COLOR 14, 0
  PRINT NewName$;
  LOCATE 25, 32 + p%, 1, 0, 7
  AllDone% = 0
  DO
    k$ = INKEY$
  LOOP UNTIL k$ <> ""
  SELECT CASE k$
    CASE CHR$(13)
      AllDone% = -1
    CASE CHR$(32) TO CHR$(127)
      MID$(NewName$, p%, 1) = k$
      IF p% < 3 THEN
        p% = p% + 1
      END IF
    CASE CHR$(8)
      IF p% > 1 THEN
        p% = p% - 1
      END IF
    CASE ELSE
  END SELECT
LOOP UNTIL AllDone%
LOCATE 1, 1, 0
END SUB

SUB InitPlay ()
'
' Mark regions filled.
'
  FOR i% = 1 TO 10
    FOR j% = 1 TO 24
      PlayField%(i%, j%) = 0
    NEXT j%
  NEXT i%
  FOR i% = 0 TO 11
    PlayField%(i%, 0) = -1
    PlayField%(i%, 25) = -1
  NEXT i%
  FOR j% = 1 TO 24
    PlayField%(0, j%) = -1
    PlayField%(11, j%) = -1
  NEXT j%
'
COLOR 7, 0
SCREEN 0
COLOR 4, 0
LOCATE 3, 15
IF Mono% THEN
  PRINT CHR$(201); STRING$(20, 205); CHR$(187);
ELSE
  PRINT CHR$(201); STRING$(10, 205); CHR$(187);
END IF
LOCATE 24, 15
IF Mono% THEN
  PRINT CHR$(200); STRING$(20, 205); CHR$(188);
ELSE
  PRINT CHR$(200); STRING$(10, 205); CHR$(188);
END IF
FOR i% = 4 TO 23
  LOCATE i%, 15
  PRINT CHR$(186);
  IF Mono% THEN
    LOCATE i%, 36
  ELSE
    LOCATE i%, 26
  END IF
  PRINT CHR$(186);
NEXT i%

COLOR 14, 1
LOCATE 8, 1
PRINT "ЩЭЭЭЭЭЭЭЭЭЭЭЛ";
LOCATE 9, 1
PRINT "К BLOCK-OUT К";
LOCATE 10, 1
PRINT "ШЭЭЭЭЭЭЭЭЭЭЭМ";

'COLOR 7, 0
'LOCATE 13, 1: PRINT "Shift right  >";
'LOCATE 14, 1: PRINT "Shift left   <";
'LOCATE 15, 1: PRINT "Rotate CW    ^";
'LOCATE 16, 1: PRINT "Rotate CCW   v";
'LOCATE 17, 1: PRINT "Drop   <space>";
'LOCATE 18, 1: PRINT "Sound        s";
'LOCATE 19, 1: PRINT "Quit     <Esc>";

COLOR 14, 0

LOCATE 4, 1
PRINT "Points:";
LOCATE 5, 1
PRINT "Score:";
LOCATE 6, 1
PRINT "High:";
ShowTopTen
ShowSound
LOCATE 1, 1, 0
END SUB

SUB LoadTopTen ()
  ErrorFlag% = 0
  OPEN "topten.sav" FOR INPUT AS #1
  IF NOT ErrorFlag% THEN
    FOR i% = 1 TO 10
      INPUT #1, TopTenName$(i%)
'      PRINT TopTenName$
      INPUT #1, TopTenScore#(i%)
    NEXT i%
    CLOSE #1
  END IF
  IF ErrorFlag% THEN
    FOR i% = 1 TO 10
      TopTenName$(i%) = "---"
      TopTenScore#(i%) = 0
    NEXT i%
  END IF
END SUB

SUB RemoveWall (Row%)
  IF Mono% THEN
    DEF SEG = &HB000
    addr% = Row% * 160 - 290
  ELSE
    DEF SEG = &HB800
    addr% = Row% * 80 - 130
  END IF
  LOCATE Row% - 1, 16
  COLOR 15, 7
  IF Mono% THEN
    PRINT STRING$(20, 15);
  ELSE
    PRINT STRING$(10, 15);
  END IF
  IF SoundOn% THEN
    SOUND 1000, 2
    SOUND 300, 1
  END IF
  t = TIMER
  DO
  LOOP UNTIL t <> TIMER

  FOR j% = Row% TO 6 STEP -1
    
    FOR i% = 1 TO 10
      PlayField%(i%, j%) = PlayField%(i%, j% - 1)
      IF Mono% THEN
        POKE addr%, PEEK(addr% - 160)
        addr% = addr% + 1
        POKE addr%, PEEK(addr% - 160)
        addr% = addr% + 1
        POKE addr%, PEEK(addr% - 160)
        addr% = addr% + 1
        POKE addr%, PEEK(addr% - 160)
        addr% = addr% + 1
      ELSE
        POKE addr%, PEEK(addr% - 80)
        addr% = addr% + 1
        POKE addr%, PEEK(addr% - 80)
        addr% = addr% + 1
      END IF
    NEXT i%
    
    IF Mono% THEN
      addr% = addr% - 200
    ELSE
      addr% = addr% - 100
    END IF

  NEXT j%

 FOR i% = 1 TO 10
   PlayField%(i%, 5) = 0
 NEXT i%
END SUB

SUB SaveTopTen ()
  ErrorFlag% = 0
  OPEN "topten.sav" FOR OUTPUT AS #1
  IF NOT ErrorFlag% THEN
    FOR i% = 1 TO 10
      PRINT #1, CHR$(34); TopTenName$(i%); CHR$(34)
      PRINT #1, TopTenScore#(i%)
    NEXT i%
    CLOSE #1
  END IF
END SUB

SUB ShowSound ()
x0% = POS(1)
y0% = CSRLIN
LOCATE 1, 39
COLOR 12, 0
IF SoundOn% THEN
  PRINT CHR$(14);
ELSE
 PRINT " ";
END IF
LOCATE y0%, x0%
END SUB

SUB ShowTopTen ()

  COLOR 14, 0
  IF Mono% THEN
    LOCATE 4, 38
  ELSE
    LOCATE 4, 28
  END IF
  PRINT "TOP SCORES";
  FOR i% = 1 TO 10
    IF Mono% THEN
      LOCATE 5 + i%, 38
    ELSE
      LOCATE 5 + i%, 28
    END IF
    a$ = RIGHT$(STRING$(8, "0") + MID$(STR$(TopTenScore#(i%)), 2), 8)
    COLOR 11, 0
    PRINT a$; " ";
    COLOR 14, 0
    PRINT TopTenName$(i%);
  NEXT i%

END SUB

SUB UpScore ()
  IF Score# < 99999999# THEN
    Score# = Score# + Points%
    COLOR 11, 0
    LOCATE 5, 7
    PRINT USING "########"; Score#;
    IF Score# > 5000 THEN dtime = .2
    IF Score# > 10000 THEN dtime = .15
    IF Score# > 20000 THEN dtime = .1
    IF Score# > 40000 THEN dtime = .05
    IF Score# > 80000 THEN dtime = 0!
  END IF
  IF Score# > HighScore# OR Score# = 0 THEN
    IF Score# <> 0 THEN HighScore# = Score#
    LOCATE 6, 7
    COLOR 12, 0
    PRINT USING "########"; HighScore#;
  END IF
  Points% = 200
  LOCATE 4, 12
  COLOR 13, 0
  PRINT USING "###"; Points%;
END SUB

