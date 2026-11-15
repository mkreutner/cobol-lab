      ******************************************************************
      * FACTUR03 - CALCUL D'UNE LIGNE DE FACTURE (FORMAT FIXE)         *
      * Les montants affiches sont faux : 3 causes a trouver.          *
      ******************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. FACTUR03.
      *
       DATA DIVISION.
       WORKING-STORAGE SECTION.
      * Donnees de la ligne de facture
       01  WS-QTE                  PIC 9(03)     VALUE 125.
       01  WS-PU                   PIC 9(03)V99  VALUE 89.90.
       01  WS-REMISE-PCT           PIC 9(02)V9   VALUE 5.5.
       01  WS-TVA-PCT              PIC 9(02)V9   VALUE 20.0.
      * Zones de calcul
       01  WS-BRUT                 PIC 9(04)V99.
       01  WS-TAUX-REMISE          PIC 9V99.
       01  WS-REMISE               PIC 9(05)V99.
       01  WS-NET-HT               PIC 9(05)V99.
       01  WS-TVA                  PIC 9(05)V99.
       01  WS-TTC                  PIC 9(05)V99.
      *
       PROCEDURE DIVISION.
       MAIN-PARA.
           MULTIPLY WS-QTE BY WS-PU GIVING WS-BRUT
           DIVIDE WS-REMISE-PCT BY 100 GIVING WS-TAUX-REMISE
           MULTIPLY WS-BRUT BY WS-TAUX-REMISE
               GIVING WS-REMISE ROUNDED
           SUBTRACT WS-REMISE FROM WS-BRUT GIVING WS-NET-HT
           COMPUTE WS-TVA = WS-NET-HT * WS-TVA-PCT / 100
           ADD WS-NET-HT WS-TVA GIVING WS-TTC
           DISPLAY "Quantite       : " WS-QTE
           DISPLAY "Prix unitaire  : " WS-PU
           DISPLAY "Montant brut   : " WS-BRUT
           DISPLAY "Taux de remise : " WS-TAUX-REMISE
           DISPLAY "Remise         : " WS-REMISE
           DISPLAY "Net HT         : " WS-NET-HT
           DISPLAY "TVA            : " WS-TVA
           DISPLAY "Total TTC      : " WS-TTC
           STOP RUN.
