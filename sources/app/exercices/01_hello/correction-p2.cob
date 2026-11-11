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
000230* Variable pour récupérer le bloc date/heure système (AAAAMMJJ...)
000240 01  WS-DATE-SYSTEME.
000250     05  WS-ANNEE           PIC X(4).
000260     05  WS-MOIS            PIC X(2).
000270     05  WS-JOUR            PIC X(2).
000280     05  FILLER             PIC X(13).
000290* Variable de structure pour l'affichage formaté
000300 01  WS-DATE-FORMATEE.
000310     05  WS-AFF-JOUR        PIC X(2).
000320     05  FILLER             PIC X     VALUE "/".
000330     05  WS-AFF-MOIS        PIC X(2).
000340     05  FILLER             PIC X     VALUE "/".
000350     05  WS-AFF-ANNEE       PIC X(4).
000360*
000370 PROCEDURE DIVISION.
000380 MAIN-PARA.
000390* 1. Récupération de la date système (Format: AAAAMMJJHHMMSS...)
000400     MOVE FUNCTION CURRENT-DATE TO WS-DATE-SYSTEME
000410* 2. Transfert des données dans la structure d'affichage
000420     MOVE WS-JOUR  TO WS-AFF-JOUR
000430     MOVE WS-MOIS  TO WS-AFF-MOIS
000440     MOVE WS-ANNEE TO WS-AFF-ANNEE
000450* 3. Demander le prenom de l'utilisateur 
000460     DISPLAY "Votre prenom ? " WITH NO ADVANCING
000470     ACCEPT  WS-PRENOM.
000480* 4. Affichage des informations
000490     DISPLAY "COBOL-LAB - exercice 01 - version " WS-VERSION
000500     DISPLAY "Format fixe : attention aux colonnes !"
000510     DISPLAY "Ce programme a ete ecrit avec la contrainte des 72 c
000520-    "olonnes".
000530     DISPLAY "Bonjour, " WS-PRENOM " !"
000540     DISPLAY "Date du jour : " WS-DATE-FORMATEE
000550* 5. Fin du programme
000560     STOP RUN.
