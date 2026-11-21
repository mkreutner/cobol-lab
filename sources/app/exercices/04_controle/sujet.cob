      ******************************************************************
      * REMISE04 - BAREME DE REMISE PAR CLIENT ET QUANTITE             *
      * Style d'origine : une phrase par instruction, pas de END-IF.   *
      * Le resultat est faux : 3 defauts de logique a trouver.         *
      ******************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. REMISE04.
      *
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-STATUT               PIC X(01).
       01  WS-QTE                  PIC 9(03).
       01  WS-PU                   PIC 9(03)V99  VALUE 12.00.
       01  WS-REMISE-PCT           PIC 9(02).
       01  WS-NOTE                 PIC X(01).
       01  WS-BRUT                 PIC 9(05)V99.
       01  WS-NET                  PIC 9(05)V99.
       01  ED-NET                  PIC ZZ,ZZ9.99.
      *
       PROCEDURE DIVISION.
       0000-MAIN.
           DISPLAY "Debut du traitement".
           MOVE "A" TO WS-STATUT.
           PERFORM 1000-CLIENT.
           MOVE "S" TO WS-STATUT.
           PERFORM 1000-CLIENT.
           MOVE "C" TO WS-STATUT.
           PERFORM 1000-CLIENT.
           DISPLAY "Fin du traitement".
      *
       1000-CLIENT.
           IF WS-STATUT NOT = "A" OR "S"
               DISPLAY "Client " WS-STATUT " : commandes refusees"
           ELSE
               DISPLAY "Client " WS-STATUT " :"
               PERFORM 2000-COMMANDE
                   VARYING WS-QTE FROM 25 BY 25 UNTIL WS-QTE > 125.
      *
       2000-COMMANDE.
           MOVE ZERO  TO WS-REMISE-PCT.
           MOVE SPACE TO WS-NOTE.
           IF WS-QTE NOT < 50
               MOVE 5 TO WS-REMISE-PCT.
           IF WS-QTE NOT < 100
               MOVE 10 TO WS-REMISE-PCT.
           IF WS-STATUT = "S"
               MOVE "B" TO WS-NOTE.
               MOVE ZERO TO WS-REMISE-PCT.
           MULTIPLY WS-QTE BY WS-PU GIVING WS-BRUT.
           COMPUTE WS-NET ROUNDED =
               WS-BRUT * (100 - WS-REMISE-PCT) / 100.
           MOVE WS-NET TO ED-NET.
           DISPLAY "  Qte " WS-QTE " remise " WS-REMISE-PCT " % net "
               ED-NET " " WS-NOTE.
