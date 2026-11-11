000100******************************************************************
000110* HELLO01 - PREMIER PROGRAMME DU COBOL-LAB (FORMAT FIXE)         *
000120* Ce programme contient 3 erreurs a corriger. Ne pas le reecrire *
000130******************************************************************
000140 IDENTIFICATION DIVISION.
000150 PROGRAM-ID. HELLO01.
000160*
000170 DATA DIVISION.
000180 WORKING-STORAGE SECTION.
000190 01  WS-VERSION          PIC X(05) VALUE "1.0.0".
000200* Numero de version affiche au demarrage
000210 01  WS-PRENOM           PIC X(30) VALUE SPACES.
000220* Prenom de l'utilisateur
000240* Variable pour récupérer le bloc date/heure système (AAAAMMJJ...)
000250 01  WS-DATE-SYSTEME.
000260     05  WS-ANNEE           PIC X(4).
000270     05  WS-MOIS            PIC X(2).
000280     05  WS-JOUR            PIC X(2).
000290     05  FILLER             PIC X(13).
000310* Variable de structure pour l'affichage formaté
000320 01  WS-DATE-FORMATEE.
000330     05  WS-AFF-JOUR        PIC X(2).
000340     05  FILLER             PIC X     VALUE "/".
000350     05  WS-AFF-MOIS        PIC X(2).
000360     05  FILLER             PIC X     VALUE "/".
000370     05  WS-AFF-ANNEE       PIC X(4).
000380*
000390 PROCEDURE DIVISION.
000400 MAIN-PARA.
      * 1. Récupération de la date système (Format: AAAAMMJJHHMMSS...)
           MOVE FUNCTION CURRENT-DATE TO WS-DATE-SYSTEME
      * 2. Transfert des données dans la structure d'affichage
           MOVE WS-JOUR  TO WS-AFF-JOUR
           MOVE WS-MOIS  TO WS-AFF-MOIS
           MOVE WS-ANNEE TO WS-AFF-ANNEE
      * 3. Demander le prenom de l'utilisateur 
000410     DISPLAY "Votre prenom ? " WITH NO ADVANCING
000420     ACCEPT  WS-PRENOM.
      * 4. Affichage des informations
000430     DISPLAY "COBOL-LAB - exercice 01 - version " WS-VERSION
000440     DISPLAY "Format fixe : attention aux colonnes !"
000450     DISPLAY "Ce programme a ete ecrit avec la contrainte des 72 c
000460-    "olonnes".
000470     DISPLAY "Bonjour, " WS-PRENOM " !"
000480     DISPLAY "Date du jour : " WS-DATE-FORMATEE
      * 5. Fin du programme
000490     STOP RUN.
