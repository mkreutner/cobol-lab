      ******************************************************************
      * TABLE05 - QUIZ : PREDIRE LE COMPORTEMENT DES TABLES            *
      * Note tes predictions AVANT de lancer le programme.             *
      ******************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. TABLE05.
      *
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-MOIS-VALEURS         PIC X(36) VALUE
           "JANFEVMARAVRMAIJUNJULAOUSEPOCTNOVDEC".
       01  WS-MOIS-TABLE REDEFINES WS-MOIS-VALEURS.
           05  WS-MOIS             PIC X(03) OCCURS 12 TIMES.
      *
       01  WS-GRILLE.
           05  WS-RANGEE           OCCURS 3 TIMES.
               10  WS-CASE         PIC 9(02) OCCURS 4 TIMES.
      *
       01  WS-ZONE.
           05  WS-NOTE             PIC 9(02) OCCURS 3 TIMES.
           05  WS-VOISIN           PIC 9(02).
      *
       01  WS-LISTE.
           05  WS-ELEM             PIC X(01) OCCURS 5 TIMES
                                   INDEXED BY WS-IDX.
      *
       01  WS-I                    PIC 9(02).
       01  WS-J                    PIC 9(02).
       01  WS-N                    PIC 9(02).
       01  WS-SOMME                PIC 9(04).
      *
       PROCEDURE DIVISION.
       0000-MAIN.
      * Q1 : le premier indice est 1
           DISPLAY "Q1  [" WS-MOIS (3) "]"
      * Q2 : longueur d'une table a deux dimensions
           DISPLAY "Q2  " LENGTH OF WS-GRILLE
      * Q3 : on remplit chaque case avec 10 x rangee + colonne
           PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
               PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 4
                   COMPUTE WS-CASE (WS-I, WS-J) = 10 * WS-I + WS-J
               END-PERFORM
           END-PERFORM
           DISPLAY "Q3  [" WS-CASE (2, 3) "]"
      * Q4 : une rangee entiere, vue comme un groupe
           DISPLAY "Q4  [" WS-RANGEE (3) "]"
      * Q5 : somme de la deuxieme rangee
           MOVE ZERO TO WS-SOMME
           PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 4
               ADD WS-CASE (2, WS-J) TO WS-SOMME
           END-PERFORM
           DISPLAY "Q5  " WS-SOMME
      * Q6 : lecture hors table (la table WS-NOTE a 3 elements)
           MOVE 11 TO WS-NOTE (1)
           MOVE 12 TO WS-NOTE (2)
           MOVE 13 TO WS-NOTE (3)
           MOVE 77 TO WS-VOISIN
           MOVE 4 TO WS-I
           DISPLAY "Q6  [" WS-NOTE (WS-I) "]"
      * Q7 : ecriture hors table
           MOVE 55 TO WS-NOTE (WS-I)
           DISPLAY "Q7  [" WS-VOISIN "]"
      * Q8 : SEARCH demarre a la position courante de l'index
           MOVE "ABCDE" TO WS-LISTE
           SET WS-IDX TO 3
           SEARCH WS-ELEM
               AT END
                   DISPLAY "Q8  B non trouve"
               WHEN WS-ELEM (WS-IDX) = "B"
                   DISPLAY "Q8  B trouve"
           END-SEARCH
      * Q9 : ou est l'index apres une recherche reussie ?
           SET WS-IDX TO 1
           SEARCH WS-ELEM
               AT END
                   CONTINUE
               WHEN WS-ELEM (WS-IDX) = "D"
                   CONTINUE
           END-SEARCH
           SET WS-N TO WS-IDX
           DISPLAY "Q9  " WS-N
      * Q10 : et apres un echec ?
           SET WS-IDX TO 1
           SEARCH WS-ELEM
               AT END
                   CONTINUE
               WHEN WS-ELEM (WS-IDX) = "Z"
                   CONTINUE
           END-SEARCH
           SET WS-N TO WS-IDX
           DISPLAY "Q10 " WS-N
           STOP RUN.
