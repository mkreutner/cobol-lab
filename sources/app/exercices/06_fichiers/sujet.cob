      ******************************************************************
      * LISTE06 - LISTE DES CLIENTS ET EXTRACTION DES COMPTES NON CLOS *
      * Entree : clients.dat   Sortie : actifs.txt                     *
      * Le resultat est faux : 3 defauts a trouver.                    *
      ******************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. LISTE06.
      *
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT F-CLIENTS
               ASSIGN TO "exercices/06_fichiers/clients.dat"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-FS-CLIENTS.
           SELECT F-ACTIFS
               ASSIGN TO "exercices/06_fichier/actifs.txt"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-FS-ACTIFS.
      *
       DATA DIVISION.
       FILE SECTION.
       FD  F-CLIENTS.
       01  CLIENT-REC.
           05  CLI-ID              PIC 9(06).
           05  CLI-NOM             PIC X(20).
           05  CLI-PRENOM          PIC X(15).
           05  CLI-CP              PIC 9(05).
           05  CLI-DATE-NAISS      PIC 9(08).
           05  CLI-SOLDE           PIC 9(07)V99.
           05  CLI-STATUT          PIC X(01).
               88  CLIENT-CLOS               VALUE "C".
               88  CLIENT-SUSPENDU           VALUE "S".
      *
       FD  F-ACTIFS.
       01  ACTIF-REC.
           05  ACT-ID              PIC 9(06).
           05  FILLER              PIC X(01).
           05  ACT-NOM             PIC X(20).
           05  FILLER              PIC X(01).
           05  ACT-SOLDE           PIC Z,ZZZ,ZZ9.99.
           05  FILLER              PIC X(01).
           05  ACT-OBSERVATION     PIC X(10).
      *
       WORKING-STORAGE SECTION.
       01  WS-FS-CLIENTS           PIC X(02).
       01  WS-FS-ACTIFS            PIC X(02).
       01  WS-FIN                  PIC X(01)     VALUE "N".
           88  FIN-FICHIER                   VALUE "O".
       01  WS-NB-LUS               PIC 9(04)     VALUE ZERO.
       01  WS-NB-ECRITS            PIC 9(04)     VALUE ZERO.
       01  WS-TOTAL-SOLDES         PIC 9(09)V99  VALUE ZERO.
       01  ED-SOLDE                PIC Z,ZZZ,ZZ9.99.
       01  ED-TOTAL                PIC ZZZ,ZZZ,ZZ9.99.
      *
       PROCEDURE DIVISION.
       0000-MAIN.
           PERFORM 1000-INIT
           PERFORM 2000-TRAITER UNTIL FIN-FICHIER
           PERFORM 9000-FIN
           STOP RUN.
      *
       1000-INIT.
           OPEN INPUT  F-CLIENTS
           OPEN OUTPUT F-ACTIFS
           MOVE SPACES TO ACTIF-REC
           PERFORM 8000-LIRE.
      *
       2000-TRAITER.
           PERFORM 8000-LIRE
           ADD 1 TO WS-NB-LUS
           ADD CLI-SOLDE TO WS-TOTAL-SOLDES
           MOVE CLI-SOLDE TO ED-SOLDE
           DISPLAY CLI-ID " " CLI-NOM " " ED-SOLDE " " CLI-STATUT
           IF NOT CLIENT-CLOS
               PERFORM 3000-ECRIRE
           END-IF.
      *
       3000-ECRIRE.
           MOVE CLI-ID    TO ACT-ID
           MOVE CLI-NOM   TO ACT-NOM
           MOVE CLI-SOLDE TO ACT-SOLDE
           IF CLIENT-SUSPENDU
               MOVE "SUSPENDU" TO ACT-OBSERVATION
           END-IF
           WRITE ACTIF-REC
           ADD 1 TO WS-NB-ECRITS.
      *
       8000-LIRE.
           READ F-CLIENTS
               AT END
                   SET FIN-FICHIER TO TRUE
           END-READ.
      *
       9000-FIN.
           CLOSE F-CLIENTS
           CLOSE F-ACTIFS
           MOVE WS-TOTAL-SOLDES TO ED-TOTAL
           DISPLAY "Clients lus     : " WS-NB-LUS
           DISPLAY "Lignes ecrites  : " WS-NB-ECRITS
           DISPLAY "Total soldes    : " ED-TOTAL
           DISPLAY "Rapport ecrit dans actifs.txt".
