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
           88  CLIENT-ACTIF                  VALUE "A".
           88  CLIENT-SUSPENDU               VALUE "S".
           88  CLIENT-CLOS                   VALUE "C".
           88  STATUT-COMMANDABLE            VALUE "A" "S".
       01  WS-QTE                  PIC 9(03).
       01  WS-PU                   PIC 9(03)V99  VALUE 12.00.
       01  WS-REMISE-PCT           PIC 9(02).
       01  WS-NOTE                 PIC X(01).
           88  REMISE-BLOQUEE                VALUE "B".
           88  REMISE-NORMALE                VALUE SPACE.
       01  WS-BRUT                 PIC 9(05)V99.
       01  WS-NET                  PIC 9(05)V99.
       01  WS-PORT                 PIC 9(02)V99.
       01  ED-NET                  PIC ZZ,ZZ9.99.
       01  ED-PORT                 PIC Z9.99.
      *
       PROCEDURE DIVISION.
       0000-MAIN.
           DISPLAY "Debut du traitement"
           SET CLIENT-ACTIF TO TRUE
           PERFORM 1000-CLIENT
           SET CLIENT-SUSPENDU TO TRUE
           PERFORM 1000-CLIENT
           SET CLIENT-CLOS TO TRUE
           PERFORM 1000-CLIENT
           DISPLAY "Fin du traitement"
           STOP RUN.
      *
       1000-CLIENT.
           IF STATUT-COMMANDABLE
               DISPLAY "Client " WS-STATUT " :"
               PERFORM 2000-COMMANDE
                   VARYING WS-QTE FROM 25 BY 25 UNTIL WS-QTE > 125
           ELSE
               DISPLAY "Client " WS-STATUT " : commandes refusees"
           END-IF.
      *
       2000-COMMANDE.
           SET REMISE-NORMALE TO TRUE
           EVALUATE TRUE
               WHEN CLIENT-SUSPENDU
                   MOVE ZERO TO WS-REMISE-PCT
                   SET REMISE-BLOQUEE TO TRUE
               WHEN WS-QTE >= 100
                   MOVE 10 TO WS-REMISE-PCT
               WHEN WS-QTE >= 50
                   MOVE 5 TO WS-REMISE-PCT
               WHEN OTHER
                   MOVE ZERO TO WS-REMISE-PCT
           END-EVALUATE
           MULTIPLY WS-QTE BY WS-PU GIVING WS-BRUT
           COMPUTE WS-NET ROUNDED =
               WS-BRUT * (100 - WS-REMISE-PCT) / 100
           IF WS-NET >= 1000
               MOVE ZERO TO WS-PORT
           ELSE
               MOVE 15 TO WS-PORT
           END-IF
           MOVE WS-NET  TO ED-NET
           MOVE WS-PORT TO ED-PORT
           DISPLAY "  Qte " WS-QTE " remise " WS-REMISE-PCT " % net "
               ED-NET " port " ED-PORT " " WS-NOTE.
