      SUBROUTINE QPARAM
C
C     PARAM PERFORMS THE FOLLOWING OPERATIONS ON PARAMETERS--
C      1. OUT = IN1 .AND. IN2
C      2. OUT = IN1 .OR . IN2
C      3. OUT = IN1   +   IN2
C      4. OUT = IN1   -   IN2
C      5. OUT = IN1   *   IN2
C      6. OUT = IN1   /   IN2
C      7. OUT = .NOT. IN1
C      8. OUT = IN1  .IMP. IN2
C      9. STORE VALUE OF OUT IN VPS.
C     10. OUT = VALUE OF PRECISION CELL FROM /SYSTEM/
C     11. OUT = CURRENT TIME
C     12. OUT = TIME TO GO
C     13. OUT = SYSTEM(IN1) = IN2
C     14. OUT = SYSTEM(25) WITH BITS IN1 THRU IN2 TURNED ON OR OFF.
C     15. OUT = SYSTEM CELL IN1.
C     16. SAVE AND RESTORES SENSE SWITCHES
C     17. SETS SENSE SWITCHES
C     18. SAVE AND RESTORES SYSTEM CELLS
C     19. OUT = -1 IF IN1 .EQ. IN2, OUT = +1 OTHERWISE.
C     20. OUT = -1 IF IN1 .GT. IN2, OUT = +1 OTHERWISE.
C     21. OUT = -1 IF IN1 .LT. IN2, OUT = +1 OTHERWISE.
C     22. OUT = -1 IF IN1 .LE. IN2, OUT = +1 OTHERWISE.
C     23. OUT = -1 IF IN1 .GE. IN2, OUT = +1 OTHERWISE.
C     24. OUT = -1 IF IN1 .NE. IN2, OUT = +1 OTHERWISE.
C     25. UNDEFINED.
C     26. UNDEFINED.
C     27. UNDEFINED.
C     28. UNDEFINED.
C     29. UNDEFINED.
C     30. UNDEFINED.
C
      EXTERNAL        LSHIFT,ORF,ANDF
      INTEGER         SWITCH,OFF,ORF,XORF,OP,OPCODE,OUT,OUTTAP,ANDF,VPS,
     1                OSCAR
      DIMENSION       OPCODE(30),SWITCH(2)
      CHARACTER       UFM*23,UWM*25
      COMMON /XMSSG / UFM,UWM
      COMMON /BLANK / OP(2),OUT,IN1,IN2
      COMMON /SYSTEM/ KSYSTM(80)
      COMMON /OSCENT/ OSCAR(16)
      COMMON /XVPS  / VPS(1)
      EQUIVALENCE     (KSYSTM( 2),OUTTAP),(KSYSTM(23),LSYSTM),
     1                (KSYSTM(55),IPREC ),(KSYSTM(79),SWITCH(1))
      DATA    OPCODE/ 4HAND ,4HOR  ,4HADD ,4HSUB ,4HMPY
     1              , 4HDIV ,4HNOT ,4HIMPL,4HNOP ,4HPREC
     2              , 4HKLOC,4HTMTO,4HSYST,4HDIAG,4HSYSR
     3              , 4HSSSR,4HSSST,4HSTSR,4HEQ  ,4HGT
     4              , 4HLT  ,4HLE  ,4HGE  ,4HNE  ,4H****
     5              , 4H****,4H****,4H****,4H****,4H****
     Z              /
      DATA    OFF   / 4HOFF /
C
C     BRANCH ON OPERATION CODE.
C
      DO 5 I = 1,30
      IF (OP(1) .EQ. OPCODE(I)) GO TO (
     1     10, 20, 30, 40, 50, 60, 70, 80, 90,100,
     2    110,120,130,140,150,160,170,180,190,200,
     3    210,220,230,240,250,260,270,280,290,300), I
    5 CONTINUE
      GO TO 990
C
C     .AND.
C
   10 OUT = -1
      IF (IN1.GE.0 .OR. IN2.GE.0) OUT = +1
      GO TO 900
C
C     .OR.
C
   20 OUT = +1
      IF (IN1.LT.0 .OR . IN2.LT.0) OUT = -1
      GO TO 900
C
C     ADD
C
   30 OUT = IN1 + IN2
      GO TO 900
C
C     SUB
C
   40 OUT = IN1 - IN2
      GO TO 900
C
C     MPY
C
   50 OUT = IN1*IN2
      GO TO 900
C
C     DIV
C
   60 OUT = IN1/IN2
      GO TO 900
C
C     NOT
C
   70 OUT = -IN1
      GO TO 900
C
C     IMPLY
C
   80 OUT = +1
      IF (IN1.GE.0 .OR. IN2.LT.0) OUT = -1
      GO TO 900
C
C     NOP
C
   90 GO TO 900
C
C     PROVIDE PRECISION FROM /SYSTEM/.
C
  100 OUT = IPREC
      GO TO 900
C
C     PROVIDE CURRENT TIME
C
  110 CALL KLOCK (OUT)
      GO TO 900
C
C     PROVIDE TIME-TO-GO
C
  120 CALL TMTOGO (OUT)
      GO TO 900
C
C     MODIFY SYSTEM CELL.
C
  130 OUT = IN2
      KSYSTM(IN1) = IN2
      IF (IN1.LE.0 .OR. IN1.GT.LSYSTM) WRITE (OUTTAP,135) UWM,IN1
  135 FORMAT (A25,' 2317, PARAM HAS STORED OUTSIDE DEFINED RANGE OF ',
     1       'COMMON BLOCK /SYSTEM/.', /32X,'INDEX VALUE =',I20)
      GO TO 900
C
C     TURN DIAG SWITCH ON OR OFF.
C
  140 IF (IN2 .LT. IN1) IN2 = IN1
      DO 145 I = IN1,IN2
      IF (I .GT. 31) GO TO 142
      OUT = LSHIFT(1,I-1)
      SWITCH(1) = ORF(SWITCH(1),OUT)
      IF (OP(2) .EQ. OFF) SWITCH(1) = SWITCH(1) - OUT
      GO TO 145
  142 OUT = I - 31
      OUT = LSHIFT(1,OUT-1)
      SWITCH(2) = ORF(SWITCH(2),OUT)
      IF (OP(2) .EQ. OFF) SWITCH(2) = SWITCH(2) - OUT
      OUT = OUT + 31
  145 CONTINUE
      OUT = SWITCH(1)
      IF (I .GT. 31) OUT = SWITCH(2)
      GO TO 900
C
C     RETURN VALUE OF IN1-TH WORD OF /SYSTEM/.
C
  150 OUT = KSYSTM(IN1)
      GO TO 900
C
C     SAVE OR RESTORE SSWITCH WORD
C
  160 IF (IN1 .LT.  0) GO TO 165
      IF (IN1 .GT. 31) GO TO 161
      OUT = SWITCH(1)
      GO TO 900
  161 CONTINUE
      OUT = SWITCH(2)
      GO TO 900
  165 IF (IABS(IN1) .GT. 31) GO TO 166
      SWITCH(1) = OUT
      GO TO 900
  166 SWITCH(2) = OUT
      GO TO 900
C
C     TURN SSWITCH ON OR OFF
C
  170 IF (OUT .EQ. 0) GO TO 900
      IF (OUT .GT. 0) GO TO 175
      IF (IABS(OUT) .GT. 31) GO TO 171
      MASK = LSHIFT(1,IABS(OUT)-1)
      SWITCH(1) = XORF(MASK,ORF(MASK,SWITCH(1)))
      GO TO 900
  171 CONTINUE
      OUT  = OUT + 31
      MASK = LSHIFT(1,IABS(OUT)-1)
      SWITCH(2) = XORF(MASK,ORF(MASK,SWITCH(2)))
      OUT  = OUT - 31
      GO TO 900
  175 CONTINUE
      IF (OUT .GT. 31) GO TO 176
      SWITCH(1) = ORF(LSHIFT(1,OUT-1),SWITCH(1))
      GO TO 900
  176 CONTINUE
      OUT = OUT - 31
      SWITCH(2) = ORF(LSHIFT(1,OUT-1),SWITCH(2))
      OUT = OUT + 31
      GO TO 900
C
C     SAVE OR RESTORE A CELL OF SYSTEM
C
C     SAVE
C
  180 CONTINUE
      IF (IN1 .LT. 0) GO TO 185
      OUT = KSYSTM(IN1)
      GO TO 900
C
C     RESTORE
C
  185 IN1 = IABS(IN1)
      KSYSTM(IN1) = OUT
      GO TO 900
C
C     ARITHMETIC RELATIONAL OPERATORS.
C
  190 IF (IN1-IN2) 191,192,191
  191 OUT = +1
      GO TO 900
  192 OUT = -1
      GO TO 900
  200 IF (IN1-IN2) 191,191,192
  210 IF (IN1-IN2) 192,191,191
  220 IF (IN1-IN2) 192,192,191
  230 IF (IN1-IN2) 191,192,192
  240 IF (IN1-IN2) 192,191,192
C
C     UNDEFINED.
C
  250 GO TO 900
C
C     UNDEFINED.
C
  260 GO TO 900
C
C     UNDEFINED.
C
  270 GO TO 900
C
C     UNDEFINED.
C
  280 GO TO 900
C
C     UNDEFINED.
C
  290 GO TO 900
C
C     UNDEFINED.
C
  300 GO TO 900
C
C     SAVE OUT IN THE VPS.
C
  900 I = ANDF(OSCAR(16),65535)
      VPS(I) = OUT
      RETURN
C
C     OPERATION CODE NOT DEFINED-- WRITE MESSAGE.
C
  990 WRITE  (OUTTAP,998) UFM,OP(1),OP(2)
  998 FORMAT (A23,' 2024, OPERATION CODE ',2A4,' NOT DEFINED FOR ',
     1       'MODULE PARAM.')
      CALL MESAGE (-61,0,0)
      RETURN
      END
