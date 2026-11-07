# Corrigé 01 — Hello, en format fixe

## Partie 1 — Les trois erreurs

| # | Ligne (séquence) | Erreur | Pourquoi |
| - | ---------------- | ------ | -------- |
| 1 | `000600` | `PROGRAM-ID. HELLO01` sans point final | Chaque en-tête se termine par un point. Le compilateur continue de lire l'en-tête et signale une erreur de syntaxe sur la ligne suivante (`DATA DIVISION`) : c'est celle qui ne pointe pas sur la bonne ligne. |
| 2 | `001100` | `*` en colonne 8 au lieu de 7 | Seule la colonne 7 est l'indicateur de commentaire. En colonne 8, l'étoile est lue comme du code en zone A → erreur de syntaxe sur `*`. |
| 3 | `001700` | ligne de 81 caractères | Tout ce qui est au-delà de la colonne 72 est ignoré : le compilateur ne voit ni le guillemet fermant ni le point. Message typique : littéral non terminé ou `unexpected end of file`, pas « ligne trop longue ». |

Corrections minimales :

```cobol
000600 PROGRAM-ID. HELLO01.
...
001100* Numero de version affiche au demarrage
...
001700     DISPLAY "Ce programme a ete ecrit avec la contrainte des 72"
001710     DISPLAY "colonnes".
```

Pour la ligne 3, deux autres solutions valables : raccourcir le texte, ou utiliser
une ligne de continuation (`-` en colonne 7, guillemet en zone B) :

```cobol
001700     DISPLAY "Ce programme a ete ecrit avec la contrainte des 72 c
001710-    "olonnes".
```

Note que le point final de `STOP RUN.` était déjà là ; une fois les trois lignes
corrigées, le programme a bien un seul point par paragraphe, à la fin.

## Partie 2 — Programme complet

```cobol
000100******************************************************************
000200* HELLO01 - PREMIER PROGRAMME DU COBOL-LAB (FORMAT FIXE)         *
000300******************************************************************
000500 IDENTIFICATION DIVISION.
000600 PROGRAM-ID. HELLO01.
000700*
000800 DATA DIVISION.
000900 WORKING-STORAGE SECTION.
001000 01  WS-VERSION          PIC X(05) VALUE "1.0.0".
001100* Numero de version affiche au demarrage
001200 01  WS-PRENOM           PIC X(30).
001300 01  WS-DATE.
001400     05 WS-AAAA          PIC 9(04).
001500     05 WS-MM            PIC 9(02).
001600     05 WS-JJ            PIC 9(02).
001700*
001800 PROCEDURE DIVISION.
001900 MAIN-PARA.
002000     DISPLAY "COBOL-LAB - exercice 01 - version " WS-VERSION
002100     DISPLAY "Format fixe : attention aux colonnes !"
002200     DISPLAY "Ce programme a ete ecrit avec la contrainte des 72"
002300     DISPLAY "colonnes"
002400     DISPLAY "Votre prenom ? " WITH NO ADVANCING
002500     ACCEPT WS-PRENOM
002600     ACCEPT WS-DATE FROM DATE YYYYMMDD
002700     DISPLAY "Bonjour, " FUNCTION TRIM(WS-PRENOM) " !"
002800     DISPLAY "Nous sommes le " WS-JJ "/" WS-MM "/" WS-AAAA
002900     STOP RUN.
```

Points à retenir :

- `01 WS-DATE` est un **groupe** : il n'a pas de `PIC`, sa taille est la somme de
  ses sous-zones (8). `ACCEPT ... FROM DATE YYYYMMDD` y dépose 8 chiffres d'un
  bloc, et on les relit par morceaux. C'est le cœur de la leçon 02.
- Les niveaux `05` sont en zone B (colonne 12), le niveau `01` en zone A.
- `FUNCTION TRIM` retire les espaces de remplissage de `WS-PRENOM`. Sans elle, on
  aurait `Bonjour, Michel                         !`.
- `WITH NO ADVANCING` supprime le saut de ligne pour avoir le prompt sur la même
  ligne que la saisie.

## Bonus — Format libre

```cobol
       >>SOURCE FORMAT IS FREE
*> HELLO01 - version format libre
IDENTIFICATION DIVISION.
PROGRAM-ID. HELLO01.

DATA DIVISION.
WORKING-STORAGE SECTION.
01  WS-VERSION   PIC X(05) VALUE "1.0.0".   *> numero de version
01  WS-PRENOM    PIC X(30).
01  WS-DATE.
    05 WS-AAAA   PIC 9(04).
    05 WS-MM     PIC 9(02).
    05 WS-JJ     PIC 9(02).

PROCEDURE DIVISION.
MAIN-PARA.
    DISPLAY "COBOL-LAB - exercice 01 - version " WS-VERSION
    DISPLAY "Format libre : plus de contrainte de colonnes."
    DISPLAY "Votre prenom ? " WITH NO ADVANCING
    ACCEPT WS-PRENOM
    ACCEPT WS-DATE FROM DATE YYYYMMDD
    DISPLAY "Bonjour, " FUNCTION TRIM(WS-PRENOM) " !"
    DISPLAY "Nous sommes le " WS-JJ "/" WS-MM "/" WS-AAAA
    STOP RUN.
```

La directive `>>SOURCE FORMAT IS FREE` doit être lue en format fixe (elle est donc
en zone B, colonne 8 ou plus) ; tout ce qui suit est en format libre. C'est pour
cela que `just ex-compile 01_hello libre` fonctionne sans `-free`.

Dans la vraie vie, on ne convertit presque jamais un programme fixe en libre :
on le laisse tel quel et on écrit les **nouveaux** programmes en libre quand la
chaîne de compilation le permet.
