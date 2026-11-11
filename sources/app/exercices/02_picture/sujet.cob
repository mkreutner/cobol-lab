      ******************************************************************
      * CLIENT02 - DECODAGE D'UN ENREGISTREMENT CLIENT (FORMAT FIXE)   *
      * Le dessin d'enregistrement ci-dessous contient UNE erreur.     *
      ******************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. CLIENT02.
      *
       DATA DIVISION.
       WORKING-STORAGE SECTION.
      * Ligne brute, telle qu'elle arriverait d'un fichier (64 car.)
       01  WS-LIGNE                PIC X(64) VALUE
           "000427DURAND              MARIE          5700019850314000125
      -    "075A".
      *
      * Dessin d'enregistrement CLIENT
       01  CLIENT-REC.
           05  CLI-ID              PIC 9(06).
           05  CLI-NOM             PIC X(20).
           05  CLI-PRENOM          PIC X(12).
           05  CLI-CP              PIC 9(05).
           05  CLI-DATE-NAISS      PIC 9(08).
           05  CLI-SOLDE           PIC 9(07)V99.
           05  CLI-STATUT          PIC X(01).
      *
       PROCEDURE DIVISION.
       MAIN-PARA.
           MOVE WS-LIGNE TO CLIENT-REC
           DISPLAY "Identifiant    : [" CLI-ID "]"
           DISPLAY "Nom            : [" CLI-NOM "]"
           DISPLAY "Prenom         : [" CLI-PRENOM "]"
           DISPLAY "Code postal    : [" CLI-CP "]"
           DISPLAY "Date naissance : [" CLI-DATE-NAISS "]"
           DISPLAY "Solde          : [" CLI-SOLDE "]"
           DISPLAY "Statut         : [" CLI-STATUT "]"
           STOP RUN.
