      ******************************************************************
      * STATUT06 - QUIZ : PREDIRE LE FILE STATUS DE CHAQUE OPERATION   *
      * Note tes predictions AVANT de lancer le programme.             *
      * clients.dat contient 8 enregistrements.                        *
      ******************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. STATUT06.
      *
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT F-ABSENT
               ASSIGN TO "exercices/06_fichiers/nexistepas.dat"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-FS.
           SELECT F-CLIENTS
               ASSIGN TO "exercices/06_fichiers/clients.dat"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-FS.
           SELECT F-SORTIE
               ASSIGN TO "exercices/06_fichiers/quiz.out"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-FS.
      *
       DATA DIVISION.
       FILE SECTION.
       FD  F-ABSENT.
       01  ABSENT-REC              PIC X(64).
       FD  F-CLIENTS.
       01  CLIENT-REC              PIC X(64).
       FD  F-SORTIE.
       01  SORTIE-REC              PIC X(64).
      *
       WORKING-STORAGE SECTION.
       01  WS-FS                   PIC X(02).
       01  WS-I                    PIC 9(02).
      *
       PROCEDURE DIVISION.
       0000-MAIN.
      * Q1 : ouvrir en lecture un fichier qui n'existe pas
           OPEN INPUT F-ABSENT
           DISPLAY "Q1  " WS-FS
      * Q2 : lire un fichier qui n'a pas ete ouvert
           READ F-CLIENTS
           DISPLAY "Q2  " WS-FS
      * Q3 : ouvrir un fichier qui existe
           OPEN INPUT F-CLIENTS
           DISPLAY "Q3  " WS-FS
      * Q4 : l'ouvrir une seconde fois
           OPEN INPUT F-CLIENTS
           DISPLAY "Q4  " WS-FS
      * Q5 : lire le 1er enregistrement
           READ F-CLIENTS
           DISPLAY "Q5  " WS-FS
      * Q6 : ecrire dans un fichier ouvert en lecture
           WRITE CLIENT-REC
           DISPLAY "Q6  " WS-FS
      * Q7 : lire les 7 enregistrements suivants (statut du dernier)
           PERFORM 7 TIMES
               READ F-CLIENTS
           END-PERFORM
           DISPLAY "Q7  " WS-FS
      * Q8 : lire encore une fois
           READ F-CLIENTS
           DISPLAY "Q8  " WS-FS
      * Q9 : et encore une fois
           READ F-CLIENTS
           DISPLAY "Q9  " WS-FS
      * Q10 : fermer
           CLOSE F-CLIENTS
           DISPLAY "Q10 " WS-FS
      * Q11 : fermer une seconde fois
           CLOSE F-CLIENTS
           DISPLAY "Q11 " WS-FS
      * Q12 : ouvrir un fichier en sortie (il est cree)
           OPEN OUTPUT F-SORTIE
           DISPLAY "Q12 " WS-FS
      * Q13 : lire un fichier ouvert en sortie
           READ F-SORTIE
           DISPLAY "Q13 " WS-FS
      * Q14 : ecrire un enregistrement
           MOVE "BONJOUR" TO SORTIE-REC
           WRITE SORTIE-REC
           DISPLAY "Q14 " WS-FS
           CLOSE F-SORTIE
           STOP RUN.
