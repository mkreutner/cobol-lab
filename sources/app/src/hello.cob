      *> hello.cob — premier programme du cobol-lab (format libre, GnuCOBOL)
       IDENTIFICATION DIVISION.
       PROGRAM-ID. HELLO.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-NAME        PIC X(30) VALUE "monde".
       01  WS-TODAY.
           05 WS-YEAR     PIC 9(4).
           05 WS-MONTH    PIC 9(2).
           05 WS-DAY      PIC 9(2).

       PROCEDURE DIVISION.
       MAIN-PARA.
           ACCEPT WS-TODAY FROM DATE YYYYMMDD
           DISPLAY "Bonjour, " FUNCTION TRIM(WS-NAME) " !"
           DISPLAY "Nous sommes le " WS-DAY "/" WS-MONTH "/" WS-YEAR
           STOP RUN.
