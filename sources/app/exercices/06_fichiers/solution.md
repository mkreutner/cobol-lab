# Corrigé 06 — Lire un fichier clients, écrire une extraction

## Partie 1 — Les trois défauts

Sortie d'origine :

```
000512 MARTIN                      35.00 A
000633 PETIT                    2,500.00 S
000748 BERNARD                      0.00 C
000801 ROBERT                     899.90 A
000915 RICHARD                  4,120.50 S
001024 MOREAU                      75.25 A
001137 SIMON                    1,560.00 A
001137 SIMON                    1,560.00 A
Clients lus     : 0008
Lignes ecrites  : 0007
Total soldes    :      10,750.65
Rapport ecrit dans actifs.txt
```

et `actifs.txt` n'existe pas.

### Défaut 1 — la relecture au mauvais endroit

```cobol
       1000-INIT.
           ...
           PERFORM 8000-LIRE.
      *
       2000-TRAITER.
           PERFORM 8000-LIRE
           ADD 1 TO WS-NB-LUS
           ...
```

La lecture anticipée de `1000-INIT` charge DURAND. `2000-TRAITER` commence par
relire : DURAND est remplacé par MARTIN **sans avoir été traité**. À l'autre
bout, la lecture qui rencontre la fin de fichier positionne `FIN-FICHIER`, mais
le traitement continue sur le tampon, qui contient toujours SIMON : il est
traité deux fois.

Le compteur vaut 8, comme attendu : un perdu, un en double. Il ne révèle rien.
Le total, lui, est faux de 1 560,00 − 1 250,75 = 309,25.

Correction : la relecture va à la **fin** du traitement.

```cobol
       2000-TRAITER.
           ADD 1 TO WS-NB-LUS
           ADD CLI-SOLDE TO WS-TOTAL-SOLDES
           MOVE CLI-SOLDE TO ED-SOLDE
           DISPLAY CLI-ID " " CLI-NOM " " ED-SOLDE " " CLI-STATUT
           IF NOT CLIENT-CLOS
               PERFORM 3000-ECRIRE
           END-IF
           PERFORM 8000-LIRE.
```

### Défaut 2 — un chemin faux, et un statut jamais testé

```cobol
           SELECT F-ACTIFS
               ASSIGN TO "exercices/06_fichier/actifs.txt"
```

Il manque le `s` de `06_fichiers`. Le répertoire n'existe pas : l'`OPEN OUTPUT`
échoue avec le statut **30**, puis chacun des 7 `WRITE` échoue avec le statut
**48** (fichier non ouvert en écriture). Comme la clause `FILE STATUS` est
déclarée, rien n'arrête le programme, et comme personne ne teste la zone, il
compte 7 « lignes écrites » et annonce le rapport.

Correction minimale : le chemin. La vraie correction est en partie 2 : tester
le statut.

### Défaut 3 — une zone du tampon jamais remise à blanc

Visible dans `actifs.txt` une fois le défaut 2 corrigé :

```
000633 PETIT                    2,500.00 SUSPENDU
000801 ROBERT                     899.90 SUSPENDU
000915 RICHARD                  4,120.50 SUSPENDU
001024 MOREAU                      75.25 SUSPENDU
```

```cobol
           IF CLIENT-SUSPENDU
               MOVE "SUSPENDU" TO ACT-OBSERVATION
           END-IF
           WRITE ACTIF-REC
```

`ACT-OBSERVATION` n'est alimentée que pour un client suspendu. À partir du
premier suspendu, elle garde sa valeur pour toutes les lignes suivantes. Le
`MOVE SPACES TO ACTIF-REC` de `1000-INIT` n'est exécuté qu'une fois.

Correction : remettre le tampon à blanc à chaque écriture.

```cobol
       3000-ECRIRE.
           MOVE SPACES    TO ACTIF-REC
           MOVE CLI-ID    TO ACT-ID
           ...
```

(Un `ELSE MOVE SPACES TO ACT-OBSERVATION` convient aussi ; le `MOVE SPACES`
global protège en plus les `FILLER` et les zones qu'on ajoutera plus tard.)

### À retenir

Les trois défauts laissent le programme se terminer normalement avec des
compteurs plausibles. Les contrôles qui les auraient révélés : comparer un
total avec une valeur connue, vérifier que le fichier de sortie existe et a le
bon nombre de lignes, relire la première et la dernière ligne.

## Partie 2 — Statuts, contrôles et rejets

### Sans contrôle, sur `clients-v2.dat`

```
000599 LEROY                 ,   ,120.50 A
000850 GARCIA                     A C.00 A
001201 ROUX                  ,   ,   .00
Clients lus     : 0011
Lignes ecrites  : 0010
Total soldes    : 737,107,976.90
```

Aucun message, code retour 0. Les octets non numériques sont interprétés comme
des chiffres au petit bonheur : le total passe de dix mille à sept cents
millions. (Le montant exact dépend du compilateur ; sur mainframe le programme
s'arrêterait en S0C7.)

### Programme

Déclarations ajoutées :

```cobol
           SELECT F-REJETS
               ASSIGN TO "exercices/06_fichiers/rejets.txt"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-FS-REJETS.
```

```cobol
               88  STATUT-VALIDE             VALUE "A" "S" "C".
      ...
       FD  F-REJETS.
       01  REJET-REC.
           05  REJ-MOTIF           PIC X(16).
           05  REJ-DONNEES         PIC X(64).
      *
       WORKING-STORAGE SECTION.
       01  WS-FS-REJETS            PIC X(02).
       01  WS-MOTIF                PIC X(16).
       01  WS-NB-CLOS              PIC 9(04)     VALUE ZERO.
       01  WS-NB-REJETS            PIC 9(04)     VALUE ZERO.
```

Procédure :

```cobol
       1000-INIT.
           OPEN INPUT  F-CLIENTS
           IF WS-FS-CLIENTS NOT = "00"
               DISPLAY "ERREUR ouverture clients, statut " WS-FS-CLIENTS
               MOVE 8 TO RETURN-CODE
               STOP RUN
           END-IF
           OPEN OUTPUT F-ACTIFS
           IF WS-FS-ACTIFS NOT = "00"
               DISPLAY "ERREUR ouverture actifs, statut " WS-FS-ACTIFS
               MOVE 8 TO RETURN-CODE
               STOP RUN
           END-IF
           OPEN OUTPUT F-REJETS
           IF WS-FS-REJETS NOT = "00"
               DISPLAY "ERREUR ouverture rejets, statut " WS-FS-REJETS
               MOVE 8 TO RETURN-CODE
               STOP RUN
           END-IF
           PERFORM 8000-LIRE.
      *
       2000-TRAITER.
           ADD 1 TO WS-NB-LUS
           EVALUATE TRUE
               WHEN CLI-ID IS NOT NUMERIC
                   MOVE "ID INVALIDE"     TO WS-MOTIF
                   PERFORM 4000-REJETER
               WHEN CLI-SOLDE IS NOT NUMERIC
                   MOVE "SOLDE INVALIDE"  TO WS-MOTIF
                   PERFORM 4000-REJETER
               WHEN NOT STATUT-VALIDE
                   MOVE "STATUT INCONNU"  TO WS-MOTIF
                   PERFORM 4000-REJETER
               WHEN OTHER
                   PERFORM 2500-ACCEPTER
           END-EVALUATE
           PERFORM 8000-LIRE.
      *
       2500-ACCEPTER.
           ADD CLI-SOLDE TO WS-TOTAL-SOLDES
           MOVE CLI-SOLDE TO ED-SOLDE
           DISPLAY CLI-ID " " CLI-NOM " " ED-SOLDE " " CLI-STATUT
           IF CLIENT-CLOS
               ADD 1 TO WS-NB-CLOS
           ELSE
               PERFORM 3000-ECRIRE
           END-IF.
      *
       4000-REJETER.
           MOVE WS-MOTIF   TO REJ-MOTIF
           MOVE CLIENT-REC TO REJ-DONNEES
           WRITE REJET-REC
           ADD 1 TO WS-NB-REJETS.
```

`9000-FIN` ferme aussi `F-REJETS` et affiche les deux nouveaux compteurs.

Résultat :

```
Clients lus     : 0011
Lignes ecrites  : 0007
Comptes clos    : 0001
Rejets          : 0003
Total soldes    :      10,441.40
```

`rejets.txt` :

```
SOLDE INVALIDE  000599LEROY               EMMA           5700019990230    12050A
SOLDE INVALIDE  000850GARCIA              NOE            54000198707110000ABC00A
SOLDE INVALIDE  001201ROUX                LEA
```

11 = 7 + 1 + 3 : le bilan est équilibré.

Avec un nom de fichier d'entrée faux :

```
ERREUR ouverture clients, statut 35
```

et `echo $?` donne 8 (à travers `just`, la recette échoue avec ce code).

Remarques :

- Le calcul sur `CLI-SOLDE` n'est fait qu'**après** le test `IS NUMERIC` :
  c'est tout l'intérêt de `2500-ACCEPTER`.
- Tous les `MOVE` vers `REJET-REC` couvrent les deux zones du tampon, donc pas
  besoin de `MOVE SPACES` ici ; il ne ferait pas de mal.
- LEROY a un solde `    12050` : cadré à droite avec des espaces au lieu de
  zéros. C'est l'anomalie la plus courante dans un fichier venu d'un tableur.
- Sa date de naissance, 30 février 1999, est numérique et passe les
  contrôles : `IS NUMERIC` vérifie la forme, pas la vraisemblance.

**La ligne courte (ROUX)** : en `LINE SEQUENTIAL`, une ligne plus courte que
le dessin est complétée par des espaces. Le tampon contient l'identifiant, le
nom, le prénom, puis des espaces dans le code postal, la date, le solde et le
statut. Le solde à espaces n'est pas numérique : rejet. S'il l'avait été, le
statut à espace aurait déclenché `STATUT INCONNU`. L'`EVALUATE` s'arrête au
premier motif trouvé.

## Partie 3 — Quiz

| Q   | Opération                                         | Statut | |
| --- | ------------------------------------------------- | ------ | - |
| Q1  | `OPEN INPUT` d'un fichier inexistant              | `35`   | |
| Q2  | `READ` d'un fichier non ouvert                    | `47`   | |
| Q3  | `OPEN INPUT` d'un fichier existant                | `00`   | |
| Q4  | second `OPEN` du même fichier                     | `41`   | déjà ouvert |
| Q5  | `READ` du 1ᵉʳ enregistrement                      | `00`   | |
| Q6  | `WRITE` sur un fichier ouvert en lecture          | `48`   | |
| Q7  | 7 `READ` de plus (le 8ᵉ et dernier enregistrement)| `00`   | lire le dernier n'est pas la fin de fichier |
| Q8  | un `READ` de plus                                 | `10`   | la fin n'est signalée que par la lecture **suivante** |
| Q9  | encore un `READ`                                  | `46`   | lecture après la fin de fichier |
| Q10 | `CLOSE`                                           | `00`   | |
| Q11 | second `CLOSE`                                    | `42`   | pas ouvert |
| Q12 | `OPEN OUTPUT`                                     | `00`   | le fichier est créé |
| Q13 | `READ` d'un fichier ouvert en écriture            | `47`   | |
| Q14 | `WRITE`                                           | `00`   | |

Q7 et Q8 sont la paire à retenir : un fichier de 8 enregistrements demande
**9** lectures. C'est ce décalage qui impose le schéma de lecture anticipée.

Q4 n'a pas fermé le fichier : l'échec du second `OPEN` laisse le premier
intact, et Q5 lit normalement.

Les échecs de Q1 et Q2 n'ont pas arrêté le programme : `FILE STATUS` est
déclaré. Sans cette clause, il se serait terminé dès Q1 avec
`libcob: error: file does not exist (status = 35)`.
