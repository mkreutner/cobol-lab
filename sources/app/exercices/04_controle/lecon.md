# Leçon 04 — Conditions, boucles et structure d'un programme

La `PROCEDURE DIVISION` est faite de **paragraphes** que l'on appelle avec
`PERFORM`. Il n'y a ni fonctions, ni paramètres, ni variables locales : tout est
global, et le découpage en paragraphes est la seule structure. Les pièges de
cette leçon (le point, la chute d'un paragraphe dans le suivant, les conditions
abrégées) sont à l'origine d'une grande part des anomalies en maintenance.

## 1. IF

```cobol
           IF WS-QTE >= 100
               MOVE 10 TO WS-REMISE-PCT
           ELSE
               MOVE ZERO TO WS-REMISE-PCT
           END-IF
```

### Deux styles à savoir lire

Avant COBOL 85, `END-IF` n'existait pas : un `IF` se termine **au premier
point**. Le code ancien écrit donc une phrase par instruction :

```cobol
           IF WS-STATUT = "S"
               MOVE "B" TO WS-NOTE
               MOVE ZERO TO WS-REMISE-PCT.
           MULTIPLY WS-QTE BY WS-PU GIVING WS-BRUT.
```

Dans ce style, **l'indentation ne veut rien dire** : seul le point délimite le
`IF`. Un point ajouté ou déplacé change la logique sans erreur de compilation :

```cobol
           IF WS-STATUT = "S"
               MOVE "B" TO WS-NOTE.
               MOVE ZERO TO WS-REMISE-PCT.        toujours execute
```

Quand tu lis un `IF` sans `END-IF`, cherche le point avant de regarder
l'indentation. Quand tu écris, utilise `END-IF` et un seul point en fin de
paragraphe.

### Écrire les conditions

| Forme                         | Exemples                                             |
| ----------------------------- | ---------------------------------------------------- |
| relation                      | `=`  `<`  `>`  `>=`  `<=`  `NOT =`  `NOT <`           |
| en toutes lettres (ancien)    | `IS EQUAL TO`, `IS GREATER THAN`, `IS NOT LESS THAN` |
| classe                        | `IF WS-ZONE IS NUMERIC`, `IS ALPHABETIC`             |
| signe                         | `IF WS-SOLDE IS NEGATIVE`, `IS ZERO`, `IS POSITIVE`  |
| combinaison                   | `AND`, `OR`, `NOT`, parenthèses                      |

`>=` et `<=` datent de 1985 : le code plus ancien écrit `NOT <` et `NOT >`.

`IS NUMERIC` est le garde-fou contre les données invalides (leçon 02) : on teste
une zone lue dans un fichier avant de calculer dessus.

### Comparaisons : numérique ou texte

- Deux zones numériques : comparaison des **valeurs** (10 > 9).
- Dès qu'une zone est alphanumérique ou un groupe : comparaison **caractère par
  caractère**, la plus courte étant complétée par des espaces. `"AB"` est égal à
  `"AB   "`, et `"10"` est inférieur à `"9"` (car `"1"` < `"9"`).

### Conditions abrégées

On peut omettre le sujet, et même l'opérateur, quand ils se répètent :

```cobol
           IF WS-CODE = 1 OR 2            WS-CODE = 1 OR WS-CODE = 2
           IF WS-AGE > 18 AND < 65        WS-AGE > 18 AND WS-AGE < 65
```

Le piège est avec `NOT`, car il fait partie de l'opérateur répété :

```cobol
           IF WS-CODE NOT = 1 OR 2        WS-CODE NOT = 1 OR WS-CODE NOT = 2
```

Cette condition est **toujours vraie** (aucune valeur n'est égale à la fois à 1
et à 2). Pour « ni 1 ni 2 », il faut `AND` : `IF WS-CODE NOT = 1 AND 2`.

### CONTINUE et NEXT SENTENCE

`CONTINUE` ne fait rien (branche vide). `NEXT SENTENCE`, dans le code ancien,
saute **après le prochain point** : avec un seul point par paragraphe, il sort
du paragraphe. À ne jamais écrire, à savoir reconnaître.

## 2. Niveaux 88 : nommer les conditions

Un niveau 88 n'est pas une zone : c'est un **nom donné à des valeurs** de la
zone située juste au-dessus.

```cobol
       01  WS-STATUT               PIC X(01).
           88  CLIENT-ACTIF                  VALUE "A".
           88  CLIENT-SUSPENDU               VALUE "S".
           88  CLIENT-CLOS                   VALUE "C".
           88  STATUT-COMMANDABLE            VALUE "A" "S".
       01  WS-AGE                  PIC 9(03).
           88  MINEUR                        VALUE 0 THRU 17.
```

```cobol
           IF STATUT-COMMANDABLE ...          equivaut a = "A" OR = "S"
           IF NOT CLIENT-CLOS ...
           SET CLIENT-SUSPENDU TO TRUE        equivaut a MOVE "S" TO WS-STATUT
```

Avantages : la valeur magique n'est écrite qu'à un endroit, la condition se lit
comme une phrase, et les listes de valeurs évitent les `OR` à rallonge. C'est
aussi l'idiome pour les indicateurs (`88 FIN-FICHIER VALUE "O".`), que tu
verras dans tous les programmes qui lisent des fichiers.

Pour retrouver ce que teste un `IF CLIENT-ACTIF`, il faut aller lire la
`DATA DIVISION` : réflexe à prendre.

## 3. EVALUATE

L'équivalent du `switch`, sans `break` : **une seule branche est exécutée**, la
première qui convient.

```cobol
           EVALUATE WS-STATUT
               WHEN "A"
                   PERFORM 2000-ACTIF
               WHEN "S"
               WHEN "C"
                   PERFORM 3000-BLOQUE
               WHEN OTHER
                   PERFORM 9000-ERREUR
           END-EVALUATE
```

Plusieurs `WHEN` à la suite sans instruction partagent la même branche. On peut
écrire des intervalles : `WHEN 1 THRU 9`.

La forme `EVALUATE TRUE` remplace une cascade de `IF ... ELSE IF` :

```cobol
           EVALUATE TRUE
               WHEN CLIENT-SUSPENDU
                   MOVE ZERO TO WS-REMISE-PCT
               WHEN WS-QTE >= 100
                   MOVE 10 TO WS-REMISE-PCT
               WHEN WS-QTE >= 50
                   MOVE 5 TO WS-REMISE-PCT
               WHEN OTHER
                   MOVE ZERO TO WS-REMISE-PCT
           END-EVALUATE
```

**L'ordre des `WHEN` fait partie de la logique** : du cas le plus restrictif au
plus général. `EVALUATE A ALSO B` teste deux sujets à la fois (tables de
décision), avec `ANY` comme joker.

## 4. PERFORM

| Forme                                                   | Effet |
| ------------------------------------------------------- | ----- |
| `PERFORM 1000-INIT`                                     | exécute le paragraphe, puis revient |
| `PERFORM 1000-A THRU 1999-FIN`                          | exécute tous les paragraphes de A à FIN, dans l'ordre du source |
| `PERFORM 2000-LIGNE 3 TIMES`                            | répète |
| `PERFORM 2000-LIGNE UNTIL FIN-FICHIER`                  | tant que la condition est **fausse** |
| `PERFORM 2000-LIGNE VARYING I FROM 1 BY 1 UNTIL I > 10` | boucle avec compteur |
| `PERFORM ... END-PERFORM`                               | les mêmes, avec le corps écrit sur place (« en ligne ») |

Trois points à retenir :

- `UNTIL` est une condition d'**arrêt**, l'inverse d'un `while`.
- Le test est fait **avant** chaque tour : si la condition est déjà vraie, le
  corps n'est jamais exécuté. `WITH TEST AFTER` le place après (au moins un tour).
- Avec `VARYING`, le compteur est incrémenté puis testé : en sortie de
  `UNTIL I > 10`, `I` vaut 11. La zone doit pouvoir contenir cette valeur, et
  être signée si le pas est négatif.

## 5. La structure, et la chute dans le paragraphe suivant

Un `PERFORM` revient à l'appelant en fin de paragraphe. Mais quand l'exécution
arrive à la fin d'un paragraphe **sans avoir été appelée par `PERFORM`**, elle
continue simplement dans le paragraphe suivant du source.

```cobol
       0000-MAIN.
           PERFORM 1000-TRAITEMENT
           DISPLAY "Fin".
       1000-TRAITEMENT.
           ...
```

Ici, après `DISPLAY "Fin"`, le programme **retombe dans `1000-TRAITEMENT`** et
l'exécute une seconde fois. Le paragraphe principal doit se terminer par
`STOP RUN` (ou `GOBACK` dans un sous-programme).

Structure classique, que tu retrouveras partout :

```cobol
       0000-MAIN.
           PERFORM 1000-INIT
           PERFORM 2000-TRAITEMENT UNTIL FIN-FICHIER
           PERFORM 9000-FIN
           STOP RUN.
       1000-INIT.
           ...
       2000-TRAITEMENT.
           ...
       9000-FIN.
           ...
```

Les numéros donnent l'ordre et la hiérarchie (2100, 2200 sont appelés par
2000). Le code ancien utilise aussi `PERFORM 2000-X THRU 2000-X-EXIT`, où le
dernier paragraphe ne contient que `EXIT.` : il sert de point de sortie pour
des `GO TO` internes (leçon 10).

Comme toutes les zones sont globales, un paragraphe peut modifier n'importe
quoi. Avant de toucher une zone, cherche tous les endroits où elle est
utilisée.
