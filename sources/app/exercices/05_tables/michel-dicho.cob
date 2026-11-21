      ******************************************************************
      * CMDE05 - VALORISATION D'UNE COMMANDE A PARTIR D'UNE TABLE      *
      * Le resultat est faux : 3 defauts a trouver.                    *
      ******************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. CMDE05.
      *
       DATA DIVISION.
       WORKING-STORAGE SECTION.
      * Table des produits : code (4), libelle (12), prix 9(3)V99
      * ordonancée par ordre des codes croissant.
       01  TAB-PRODUITS-VALEURS.
           05  FILLER          PIC X(21) VALUE "P100ECROU M6    00120".
           05  FILLER          PIC X(21) VALUE "P200BOULON M8   01290".
           05  FILLER          PIC X(21) VALUE "P300VIS 6X40    00450".
           05  FILLER          PIC X(21) VALUE "P400TIGE FILETEE00725".
           05  FILLER          PIC X(21) VALUE "P500RONDELLE M6 00035".
           05  FILLER          PIC X(21) VALUE "P600CHEVILLE 8MM00080".
       01  TAB-PRODUITS REDEFINES TAB-PRODUITS-VALEURS.
      *                            le SEARCH s'arrête à 5 et il y a
      *                            6 entrées. Il faut remplacer le 5
      *                            par 6. 
           05  PRD-ENTREE          OCCURS 6 TIMES
                                   ASCENDING KEY IS PRD-CODE
                                   INDEXED BY PRD-IDX.
               10  PRD-CODE        PIC X(04).
               10  PRD-LIBELLE     PIC X(12).
               10  PRD-PRIX        PIC 9(03)V99.
      * Lignes de la commande : code produit (4), quantite 9(3)
       01  TAB-COMMANDE-VALEURS.
           05  FILLER          PIC X(07) VALUE "P100010".
           05  FILLER          PIC X(07) VALUE "P300004".
           05  FILLER          PIC X(07) VALUE "P999001".
           05  FILLER          PIC X(07) VALUE "P200002".
           05  FILLER          PIC X(07) VALUE "P600100".
       01  TAB-COMMANDE REDEFINES TAB-COMMANDE-VALEURS.
           05  CMD-LIGNE           OCCURS 5 TIMES.
               10  CMD-CODE        PIC X(04).
               10  CMD-QTE         PIC 9(03).
      * Tranches de remise : seuil de quantite 9(3), taux 9(2)
       01  TAB-TRANCHES-VALEURS.
           05  FILLER          PIC X(05) VALUE "10010".
           05  FILLER          PIC X(05) VALUE "05005".
           05  FILLER          PIC X(05) VALUE "00000".
       01  TAB-TRANCHES REDEFINES TAB-TRANCHES-VALEURS.
           05  TRA-ENTREE          OCCURS 3 TIMES
                                   INDEXED BY TRA-IDX.
               10  TRA-SEUIL       PIC 9(03).
               10  TRA-TAUX        PIC 9(02).
       01  WS-NB-LIGNES            PIC 9(02)     VALUE 5.
      * Zones de travail
       01  WS-I                    PIC 9(02).
       01  WS-MONTANT              PIC 9(05)V99.
       01  WS-TOTAL                PIC 9(06)V99  VALUE ZERO.
       01  WS-NB-REJETS            PIC 9(02)     VALUE ZERO.
       01  ED-PRIX                 PIC ZZ9.99.
       01  ED-MONTANT              PIC ZZZ,ZZ9.99.
      *
       PROCEDURE DIVISION.
       0000-MAIN.
      *    On peut retirer le SET ici car il est reporté dans 
      *    1000-LIGNE pour repositionner PRD-IDX à chaque recherche.
      *     SET PRD-IDX TO 1
           PERFORM 1000-LIGNE
      *        Il faut continuer la boucle jusqu'à ce que WS-I soit
      *        suppérieur à WS-NB-LIGNES sinon la dernière ligne est
      *        ignorée.
               VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-NB-LIGNES
           MOVE WS-TOTAL TO ED-MONTANT
           DISPLAY "Total commande  : " ED-MONTANT
           DISPLAY "Lignes rejetees : " WS-NB-REJETS
           STOP RUN.
      *
       1000-LIGNE.
           SEARCH ALL PRD-ENTREE
               AT END
                   DISPLAY CMD-CODE (WS-I) " *** produit inconnu ***"
                   ADD 1 TO WS-NB-REJETS
               WHEN PRD-CODE (PRD-IDX) = CMD-CODE (WS-I)
                   PERFORM 2000-VALORISER
           END-SEARCH.
      *
       2000-VALORISER.
           SET TRA-IDX TO 1
           SEARCH TRA-ENTREE
               WHEN CMD-QTE (WS-I) >= TRA-SEUIL (TRA-IDX)
                   CONTINUE
           END-SEARCH
           COMPUTE WS-MONTANT ROUNDED =
               CMD-QTE (WS-I) * PRD-PRIX (PRD-IDX)
               * (100 - TRA-TAUX (TRA-IDX)) / 100
           ADD WS-MONTANT TO WS-TOTAL
           MOVE PRD-PRIX (PRD-IDX) TO ED-PRIX
           MOVE WS-MONTANT TO ED-MONTANT
           DISPLAY CMD-CODE (WS-I) " " PRD-LIBELLE (PRD-IDX) " "
               CMD-QTE (WS-I) " x " ED-PRIX " = " ED-MONTANT
               " (-" TRA-TAUX (TRA-IDX) " %)".
