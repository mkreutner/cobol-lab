      ******************************************************************
      * EDIT03 - QUIZ : PREDIRE LE RESULTAT DES PICTURE D'EDITION      *
      * Note tes predictions AVANT de lancer le programme.             *
      ******************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. EDIT03.
      *
       DATA DIVISION.
       WORKING-STORAGE SECTION.
      * Zones emettrices
       01  WS-MONTANT              PIC S9(05)V99 VALUE 1234.5.
       01  WS-ZERO                 PIC S9(05)V99 VALUE 0.
       01  WS-DEBIT                PIC S9(05)V99 VALUE -150.25.
       01  WS-GROS                 PIC 9(06)     VALUE 123456.
       01  WS-DATE                 PIC 9(08)     VALUE 19850314.
      * Zones d'edition
       01  ED-1                    PIC ZZ,ZZ9.99.
       01  ED-2                    PIC ZZ,ZZZ.ZZ.
       01  ED-3                    PIC --,--9.99.
       01  ED-4                    PIC ZZ,ZZ9.99CR.
       01  ED-5                    PIC **,**9.99.
       01  ED-6                    PIC ZZ,ZZ9.
       01  ED-7                    PIC 9999/99/99.
       01  ED-8                    PIC +ZZ,ZZ9.99.
      *
       PROCEDURE DIVISION.
       MAIN-PARA.
           MOVE WS-MONTANT TO ED-1
           DISPLAY "Q1  [" ED-1 "]"
           MOVE WS-ZERO    TO ED-1
           DISPLAY "Q2  [" ED-1 "]"
           MOVE WS-ZERO    TO ED-2
           DISPLAY "Q3  [" ED-2 "]"
           MOVE WS-DEBIT   TO ED-1
           DISPLAY "Q4  [" ED-1 "]"
           MOVE WS-DEBIT   TO ED-3
           DISPLAY "Q5  [" ED-3 "]"
           MOVE WS-MONTANT TO ED-3
           DISPLAY "Q6  [" ED-3 "]"
           MOVE WS-DEBIT   TO ED-4
           DISPLAY "Q7  [" ED-4 "]"
           MOVE WS-MONTANT TO ED-4
           DISPLAY "Q8  [" ED-4 "]"
           MOVE WS-MONTANT TO ED-5
           DISPLAY "Q9  [" ED-5 "]"
           MOVE WS-GROS    TO ED-6
           DISPLAY "Q10 [" ED-6 "]"
           MOVE WS-DATE    TO ED-7
           DISPLAY "Q11 [" ED-7 "]"
           MOVE WS-DEBIT   TO ED-8
           DISPLAY "Q12 [" ED-8 "]"
           DISPLAY "--- Partie 3 ---"
           MOVE 12         TO ED-1
           DISPLAY "ED-1    - Attentu [    12.00]    -> [" ED-1 "]"
           MOVE 12         TO ED-2
           DISPLAY "ED-2    - Attentu [    12.00]    -> [" ED-2 "] "
           MOVE 12         TO ED-3
           DISPLAY "ED-3    - Attentu [    12.00]    -> [" ED-3 "]"
           MOVE 12         TO ED-4
           DISPLAY "ED-4    - Attentu [    12.00  ]  -> [" ED-4 "]"
           MOVE 12         TO ED-5
           DISPLAY "ED-5    - Attentu [****12.00]    -> [" ED-5 "]"
           MOVE 12         TO ED-6
           DISPLAY "ED-6    - Attentu [    12]       -> [" ED-6 "]"
           MOVE 12         TO ED-7
           DISPLAY "ED-7    - Attentu [0000/00/12]   -> [" ED-7 "]"
           MOVE 12         TO ED-8
           DISPLAY "ED-8    - Attentu [+    12.00]   -> [" ED-8 "]"
           STOP RUN.
