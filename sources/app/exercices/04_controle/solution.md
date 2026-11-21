# Corrigé 04 — Un barème de remise à la logique défaillante

## Partie 1 — Les trois défauts

Sortie d'origine :

```
Debut du traitement
Client A : commandes refusees
Client S : commandes refusees
Client C : commandes refusees
Fin du traitement
Client C : commandes refusees
  Qte 000 remise 00 % net      0.00
```

### Défaut 1 — `1000-CLIENT` : condition abrégée toujours vraie

```cobol
           IF WS-STATUT NOT = "A" OR "S"
```

se développe en `WS-STATUT NOT = "A" OR WS-STATUT NOT = "S"`. Pour `A`, la
seconde moitié est vraie ; pour `S`, la première ; pour tout le reste, les deux.
Tout le monde est refusé. Correction (un mot) :

```cobol
           IF WS-STATUT NOT = "A" AND "S"
```

### Défaut 2 — `2000-COMMANDE` : un point qui ferme le IF trop tôt

Visible une fois le défaut 1 corrigé : toutes les remises sont à 00 %, même
pour le client actif.

```cobol
           IF WS-STATUT = "S"
               MOVE "B" TO WS-NOTE.
               MOVE ZERO TO WS-REMISE-PCT.
```

Le point après `WS-NOTE` termine le `IF`. La remise à zéro, malgré son
indentation, est exécutée pour **tous** les clients, juste après que les deux
`IF` précédents l'ont calculée. La note `B`, elle, reste conditionnelle : c'est
ce qui rend le défaut trompeur, la moitié de la règle R3 fonctionne.
Correction (un caractère) : supprimer ce point.

```cobol
           IF WS-STATUT = "S"
               MOVE "B" TO WS-NOTE
               MOVE ZERO TO WS-REMISE-PCT.
```

### Défaut 3 — `0000-MAIN` : chute dans le paragraphe suivant

Les lignes après `Fin du traitement`. `0000-MAIN` n'a pas de `STOP RUN` :
l'exécution continue dans `1000-CLIENT` (avec le dernier statut, `C`), puis
dans `2000-COMMANDE` (avec la valeur de `WS-QTE` laissée par la dernière
boucle), et s'arrête seulement à la fin du source. Correction (une ligne) :

```cobol
           DISPLAY "Fin du traitement".
           STOP RUN.
```

Ce défaut est indépendant des deux autres et visible dès le premier lancement.
Après correction des défauts 1 et 2 mais pas du 3, la ligne en trop devient
`Qte 150 remise 10 % net  1,620.00` : 150 est la valeur de `WS-QTE` en sortie
de boucle (125 + 25, premier dépassement de `> 125`). Une commande fantôme de
150 articles, calculée proprement.

### À retenir

Aucun des trois n'est signalé par le compilateur. Les deux premiers sont
typiques d'une retouche : quelqu'un a ajouté le statut `S` à un test qui ne
portait que sur `A`, et quelqu'un a inséré une ligne dans un `IF` en gardant le
point de la ligne précédente.

Lecture du code ancien : `IF WS-QTE NOT < 50` signifie `>= 50`. Les deux `IF`
successifs (5 %, puis 10 % qui écrase) forment un barème par écrasement, courant
avant `EVALUATE`.

## Partie 2 — Version modernisée

```cobol
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-STATUT               PIC X(01).
           88  CLIENT-ACTIF                  VALUE "A".
           88  CLIENT-SUSPENDU               VALUE "S".
           88  CLIENT-CLOS                   VALUE "C".
           88  STATUT-COMMANDABLE            VALUE "A" "S".
       01  WS-QTE                  PIC 9(03).
       01  WS-PU                   PIC 9(03)V99  VALUE 12.00.
       01  WS-REMISE-PCT           PIC 9(02).
       01  WS-NOTE                 PIC X(01).
           88  REMISE-BLOQUEE                VALUE "B".
           88  REMISE-NORMALE                VALUE SPACE.
       01  WS-BRUT                 PIC 9(05)V99.
       01  WS-NET                  PIC 9(05)V99.
       01  WS-PORT                 PIC 9(02)V99.
       01  ED-NET                  PIC ZZ,ZZ9.99.
       01  ED-PORT                 PIC Z9.99.
      *
       PROCEDURE DIVISION.
       0000-MAIN.
           DISPLAY "Debut du traitement"
           SET CLIENT-ACTIF TO TRUE
           PERFORM 1000-CLIENT
           SET CLIENT-SUSPENDU TO TRUE
           PERFORM 1000-CLIENT
           SET CLIENT-CLOS TO TRUE
           PERFORM 1000-CLIENT
           DISPLAY "Fin du traitement"
           STOP RUN.
      *
       1000-CLIENT.
           IF STATUT-COMMANDABLE
               DISPLAY "Client " WS-STATUT " :"
               PERFORM 2000-COMMANDE
                   VARYING WS-QTE FROM 25 BY 25 UNTIL WS-QTE > 125
           ELSE
               DISPLAY "Client " WS-STATUT " : commandes refusees"
           END-IF.
      *
       2000-COMMANDE.
           SET REMISE-NORMALE TO TRUE
           EVALUATE TRUE
               WHEN CLIENT-SUSPENDU
                   MOVE ZERO TO WS-REMISE-PCT
                   SET REMISE-BLOQUEE TO TRUE
               WHEN WS-QTE >= 100
                   MOVE 10 TO WS-REMISE-PCT
               WHEN WS-QTE >= 50
                   MOVE 5 TO WS-REMISE-PCT
               WHEN OTHER
                   MOVE ZERO TO WS-REMISE-PCT
           END-EVALUATE
           MULTIPLY WS-QTE BY WS-PU GIVING WS-BRUT
           COMPUTE WS-NET ROUNDED =
               WS-BRUT * (100 - WS-REMISE-PCT) / 100
           IF WS-NET >= 1000
               MOVE ZERO TO WS-PORT
           ELSE
               MOVE 15 TO WS-PORT
           END-IF
           MOVE WS-NET  TO ED-NET
           MOVE WS-PORT TO ED-PORT
           DISPLAY "  Qte " WS-QTE " remise " WS-REMISE-PCT " % net "
               ED-NET " port " ED-PORT " " WS-NOTE.
```

Sortie :

```
Client A :
  Qte 025 remise 00 % net    300.00 port 15.00
  Qte 050 remise 05 % net    570.00 port 15.00
  Qte 075 remise 05 % net    855.00 port 15.00
  Qte 100 remise 10 % net  1,080.00 port  0.00
  Qte 125 remise 10 % net  1,350.00 port  0.00
Client S :
  Qte 025 remise 00 % net    300.00 port 15.00 B
  Qte 050 remise 00 % net    600.00 port 15.00 B
  Qte 075 remise 00 % net    900.00 port 15.00 B
  Qte 100 remise 00 % net  1,200.00 port  0.00 B
  Qte 125 remise 00 % net  1,500.00 port  0.00 B
Client C : commandes refusees
```

Remarques :

- `IF STATUT-COMMANDABLE` remplace la condition abrégée : le défaut 1 ne peut
  plus se produire, et la branche positive passe en premier.
- Les règles R2 et R3 tiennent dans un seul `EVALUATE`, la plus prioritaire en
  tête. Les trois défauts de la partie 1 sont devenus impossibles ou visibles.
- **Ordre des `WHEN`** : si `WHEN WS-QTE >= 50` est placé avant
  `WHEN WS-QTE >= 100`, une commande de 100 articles satisfait d'abord `>= 50`
  et reçoit 5 % ; la branche des 10 % n'est jamais atteinte. Aucun message.
- Le franco est testé sur le net, après remise : 1 200 € brut à 10 % donne
  1 080 €, port offert.

## Partie 3 — Quiz

| Q   | Résultat             | Explication |
| --- | -------------------- | ----------- |
| Q1  | `tours=005 WS-I=+006` | le compteur est incrémenté puis testé : il sort à 6 |
| Q2  | `tours=000 WS-I=+005` | test avant : condition déjà vraie, corps jamais exécuté |
| Q3  | `tours=001 WS-I=+006` | `WITH TEST AFTER` : au moins un tour |
| Q4  | `tours=004 WS-I=-002` | 10, 7, 4, 1 puis −2 qui arrête la boucle |
| Q5  | `WS-CPT=111`         | `THRU` exécute A, B et C : tout ce qui est entre les deux dans le source |
| Q6  | `WS-CPT=013`         | B une fois (10), puis A trois fois (3) |
| Q7  | `vrai`               | `= 1 OR = 2` |
| Q8  | `faux`               | `NOT = 1 AND NOT = 2` : 2 est exclu |
| Q9  | `vrai`               | `NOT = 1 OR NOT = 2` : toujours vrai |
| Q10 | `egaux`              | la zone la plus courte est complétée par des espaces |
| Q11 | `vrai`               | texte : `"1"` < `"9"`, la suite n'est pas regardée |
| Q12 | `faux`               | numérique : 10 > 9 |
| Q13 | `WS-CPT=001`         | une seule branche exécutée, la première vraie |

Q4 : avec une zone **non signée**, `WS-I` ne pourrait jamais devenir négatif
(le signe est perdu, leçon 02) et la boucle ne s'arrêterait pas. C'est pour
cela que `WS-I` est déclaré `S9(03)`.

Q5 : `PERFORM ... THRU` dépend de l'ordre des paragraphes dans le fichier. Si
quelqu'un insère un paragraphe entre A et C, il sera exécuté lui aussi.

Q9 est le défaut 1 de la partie 1.
