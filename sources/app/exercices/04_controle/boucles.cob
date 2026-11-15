      ******************************************************************
      * BOUCL04 - QUIZ : PREDIRE CONDITIONS ET BOUCLES                 *
      * Note tes predictions AVANT de lancer le programme.             *
      ******************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BOUCL04.
      *
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-I                    PIC S9(03).
       01  WS-CPT                  PIC 9(03).
       01  WS-N                    PIC 9(03).
       01  WS-CODE                 PIC 9(01).
       01  WS-TXT-A                PIC X(02)     VALUE "AB".
       01  WS-TXT-B                PIC X(05)     VALUE "AB".
       01  WS-TXT-10               PIC X(02)     VALUE "10".
       01  WS-TXT-9                PIC X(02)     VALUE "9".
       01  WS-NUM-10               PIC 9(02)     VALUE 10.
       01  WS-NUM-9                PIC 9(02)     VALUE 9.
      *
       PROCEDURE DIVISION.
       0000-MAIN.
      * Q1 : combien de tours, et que vaut WS-I apres la boucle ?
           MOVE ZERO TO WS-CPT
           PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
               ADD 1 TO WS-CPT
           END-PERFORM
           DISPLAY "Q1  tours=" WS-CPT " WS-I=" WS-I
      * Q2 : la condition est deja vraie en entrant
           MOVE ZERO TO WS-CPT
           MOVE 5 TO WS-I
           PERFORM UNTIL WS-I >= 5
               ADD 1 TO WS-CPT
               ADD 1 TO WS-I
           END-PERFORM
           DISPLAY "Q2  tours=" WS-CPT " WS-I=" WS-I
      * Q3 : la meme, avec WITH TEST AFTER
           MOVE ZERO TO WS-CPT
           MOVE 5 TO WS-I
           PERFORM WITH TEST AFTER UNTIL WS-I >= 5
               ADD 1 TO WS-CPT
               ADD 1 TO WS-I
           END-PERFORM
           DISPLAY "Q3  tours=" WS-CPT " WS-I=" WS-I
      * Q4 : pas negatif
           MOVE ZERO TO WS-CPT
           PERFORM VARYING WS-I FROM 10 BY -3 UNTIL WS-I < 0
               ADD 1 TO WS-CPT
           END-PERFORM
           DISPLAY "Q4  tours=" WS-CPT " WS-I=" WS-I
      * Q5 : PERFORM ... THRU
           MOVE ZERO TO WS-CPT
           PERFORM 1000-A THRU 3000-C
           DISPLAY "Q5  WS-CPT=" WS-CPT
      * Q6 : PERFORM simple, puis n TIMES
           MOVE ZERO TO WS-CPT
           PERFORM 2000-B
           PERFORM 1000-A 3 TIMES
           DISPLAY "Q6  WS-CPT=" WS-CPT
      * Q7 a Q9 : conditions abregees, WS-CODE vaut 2
           MOVE 2 TO WS-CODE
           IF WS-CODE = 1 OR 2
               DISPLAY "Q7  vrai"
           ELSE
               DISPLAY "Q7  faux"
           END-IF
           IF WS-CODE NOT = 1 AND 2
               DISPLAY "Q8  vrai"
           ELSE
               DISPLAY "Q8  faux"
           END-IF
           IF WS-CODE NOT = 1 OR 2
               DISPLAY "Q9  vrai"
           ELSE
               DISPLAY "Q9  faux"
           END-IF
      * Q10 : comparaison de textes de longueurs differentes
           IF WS-TXT-A = WS-TXT-B
               DISPLAY "Q10 egaux"
           ELSE
               DISPLAY "Q10 differents"
           END-IF
      * Q11 et Q12 : "10" et "9" en texte, puis 10 et 9 en numerique
           IF WS-TXT-10 < WS-TXT-9
               DISPLAY "Q11 10 < 9 : vrai"
           ELSE
               DISPLAY "Q11 10 < 9 : faux"
           END-IF
           IF WS-NUM-10 < WS-NUM-9
               DISPLAY "Q12 10 < 9 : vrai"
           ELSE
               DISPLAY "Q12 10 < 9 : faux"
           END-IF
      * Q13 : EVALUATE, WS-N vaut 20
           MOVE 20 TO WS-N
           MOVE ZERO TO WS-CPT
           EVALUATE TRUE
               WHEN WS-N > 10
                   ADD 1 TO WS-CPT
               WHEN WS-N > 5
                   ADD 10 TO WS-CPT
               WHEN OTHER
                   ADD 100 TO WS-CPT
           END-EVALUATE
           DISPLAY "Q13 WS-CPT=" WS-CPT
           STOP RUN.
      *
       1000-A.
           ADD 1 TO WS-CPT.
       2000-B.
           ADD 10 TO WS-CPT.
       3000-C.
           ADD 100 TO WS-CPT.
