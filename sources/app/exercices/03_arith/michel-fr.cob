      ******************************************************************
      * FACTUR03 - CALCUL D'UNE LIGNE DE FACTURE (FORMAT FIXE)         *
      * Les montants affiches sont faux : 3 causes a trouver.          *
      ******************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. FACTUR03.
      *
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SPECIAL-NAMES.
           DECIMAL-POINT IS COMMA.
      *
       DATA DIVISION.
       WORKING-STORAGE SECTION.
      * Donnees de la ligne de facture
       01  WS-QTE                  PIC 9(03)     VALUE 125.
       01  WS-PU                   PIC 9(03)V99  VALUE 89,90.
       01  WS-REMISE-PCT           PIC 9(02)V9   VALUE 5,5.
       01  WS-TVA-PCT              PIC 9(02)V9   VALUE 20,0.
      * Zones de calcul
       01  WS-BRUT                 PIC 9(05)V99.
       01  WS-TAUX-REMISE          PIC 9V999.
       01  WS-REMISE               PIC 9(05)V99.
       01  WS-NET-HT               PIC 9(05)V99.
       01  WS-TVA                  PIC 9(05)V99.
       01  WS-TTC                  PIC 9(05)V99.
      * Zones d'edition
       01  ED-QTE                  PIC ZZ9.
       01  ED-PU                   PIC ZZ9,99.
       01  ED-PCT                  PIC Z9,9.
       01  ED-MONTANT              PIC ZZBZZ9,99.
       01  ED-MONTANT-EURO.
           05  ED-MONTANT-VAL      PIC ZZBZZ9,99.
           05  FILLER              PIC X(04) VALUE " €".
      *
       PROCEDURE DIVISION.
       MAIN-PARA.
           MULTIPLY WS-QTE BY WS-PU GIVING WS-BRUT
               ON SIZE ERROR
                   DISPLAY "ERREUR : montant brut hors capacite"
                   STOP RUN
           END-MULTIPLY
           DIVIDE WS-REMISE-PCT BY 100 GIVING WS-TAUX-REMISE
           MULTIPLY WS-BRUT BY WS-TAUX-REMISE
               GIVING WS-REMISE ROUNDED
           SUBTRACT WS-REMISE FROM WS-BRUT GIVING WS-NET-HT
           COMPUTE WS-TVA ROUNDED = WS-NET-HT * WS-TVA-PCT / 100
           ADD WS-NET-HT WS-TVA GIVING WS-TTC
           MOVE WS-QTE        TO ED-QTE
           DISPLAY "Quantite          : " ED-QTE
           MOVE WS-PU         TO ED-PU
           DISPLAY "Prix unitaire     : " ED-PU
           MOVE WS-BRUT       TO ED-MONTANT
           DISPLAY "Montant brut      : " ED-MONTANT
           MOVE WS-REMISE-PCT TO ED-PCT
           MOVE WS-REMISE     TO ED-MONTANT
           DISPLAY "Remise " ED-PCT " %     : " ED-MONTANT
           MOVE WS-NET-HT     TO ED-MONTANT
           DISPLAY "Net HT            : " ED-MONTANT
           MOVE WS-TVA        TO ED-MONTANT
           DISPLAY "TVA               : " ED-MONTANT
           MOVE WS-TTC        TO ED-MONTANT
           DISPLAY "Total TTC         : " ED-MONTANT
           MOVE WS-TTC        TO ED-MONTANT-VAL
           DISPLAY "Total TTC en euro : " ED-MONTANT-EURO
           STOP RUN.
