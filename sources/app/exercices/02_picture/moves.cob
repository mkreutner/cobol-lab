      ******************************************************************
      * MOVES02 - QUIZ : PREDIRE LE RESULTAT DE CHAQUE MOVE            *
      * Note tes predictions AVANT de lancer le programme.             *
      ******************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. MOVES02.
      *
       DATA DIVISION.
       WORKING-STORAGE SECTION.
      * Zones emettrices
       01  WS-TEXTE-LONG           PIC X(07)    VALUE "BONJOUR".
       01  WS-TEXTE-COURT          PIC X(02)    VALUE "AB".
       01  WS-GRAND                PIC 9(05)    VALUE 12345.
       01  WS-PETIT                PIC 9(02)    VALUE 42.
       01  WS-DECIMAL              PIC 9(04)V999 VALUE 1234.567.
       01  WS-NEGATIF              PIC S9(03)   VALUE -123.
      * Zones receptrices
       01  WS-A5                   PIC X(05).
       01  WS-N3                   PIC 9(03).
       01  WS-N5                   PIC 9(05).
       01  WS-D                    PIC 9(03)V99.
       01  WS-S                    PIC S9(03).
       01  WS-S-BRUT REDEFINES WS-S PIC X(03).
       01  WS-GRP.
           05  WS-G-NUM            PIC 9(02).
           05  WS-G-TXT            PIC X(03).
      *
       PROCEDURE DIVISION.
       MAIN-PARA.
           MOVE WS-TEXTE-LONG  TO WS-A5
           DISPLAY "Q1 [" WS-A5 "]"
           MOVE WS-TEXTE-COURT TO WS-A5
           DISPLAY "Q2 [" WS-A5 "]"
           MOVE WS-GRAND       TO WS-N3
           DISPLAY "Q3 [" WS-N3 "]"
           MOVE WS-PETIT       TO WS-N5
           DISPLAY "Q4 [" WS-N5 "]"
           MOVE WS-DECIMAL     TO WS-D
           DISPLAY "Q5 [" WS-D "]"
           MOVE WS-NEGATIF     TO WS-N3
           DISPLAY "Q6 [" WS-N3 "]"
           MOVE WS-NEGATIF     TO WS-S
           DISPLAY "Q7 [" WS-S "] brut [" WS-S-BRUT "]"
           MOVE WS-PETIT       TO WS-GRP
           DISPLAY "Q8 [" WS-G-NUM "] [" WS-G-TXT "]"
           MOVE WS-GRAND       TO WS-GRP
           DISPLAY "Q9 [" WS-G-NUM "] [" WS-G-TXT "]"
           STOP RUN.
