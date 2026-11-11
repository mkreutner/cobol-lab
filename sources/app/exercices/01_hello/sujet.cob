000100******************************************************************
000200* HELLO01 - PREMIER PROGRAMME DU COBOL-LAB (FORMAT FIXE)         *
000300* Ce programme contient 3 erreurs a corriger. Ne pas le reecrire *
000400******************************************************************
000500 IDENTIFICATION DIVISION.
000600 PROGRAM-ID. HELLO01
000700*
000800 DATA DIVISION.
000900 WORKING-STORAGE SECTION.
001000 01  WS-VERSION          PIC X(05) VALUE "1.0.0".
001100 * Numero de version affiche au demarrage
001200*
001300 PROCEDURE DIVISION.
001400 MAIN-PARA.
001500     DISPLAY "COBOL-LAB - exercice 01 - version " WS-VERSION
001600     DISPLAY "Format fixe : attention aux colonnes !"
001700     DISPLAY "Ce programme a ete ecrit avec la contrainte des 72 colonnes".
001800     STOP RUN.