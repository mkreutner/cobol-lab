# Corrigé 03 — Une ligne de facture qui calcule faux

## Partie 1 — Les trois causes

Sortie d'origine :

```
Montant brut   : 1237.50
Taux de remise : 0.05
Remise         : 00061.88
Net HT         : 01175.62
TVA            : 00235.12
Total TTC      : 01410.74
```

| # | Zone / ligne | Cause | Correction |
| - | ------------ | ----- | ---------- |
| 1 | `WS-BRUT PIC 9(04)V99` | **Dépassement** : 11 237,50 a 5 chiffres entiers, la zone 4. Le chiffre de poids fort est perdu → 1237,50. | `PIC 9(05)V99` |
| 2 | `WS-TAUX-REMISE PIC 9V99` | **Précision d'une zone intermédiaire** : 5,5 / 100 = 0,055 tronqué à 0,05. | `PIC 9V999` |
| 3 | `COMPUTE WS-TVA = ...` | **Troncature au lieu d'arrondi** : 2123,888 → 2123,88. | `COMPUTE WS-TVA ROUNDED = ...` |

Ce que l'on voit après chaque correction :

| Après correction | Brut      | Remise | Net HT    | TVA     | TTC       |
| ---------------- | --------- | ------ | --------- | ------- | --------- |
| aucune           | 1237,50   | 61,88  | 1175,62   | 235,12  | 1410,74   |
| 1                | 11237,50  | 561,88 | 10675,62  | 2135,12 | 12810,74  |
| 1 + 2            | 11237,50  | 618,06 | 10619,44  | 2123,88 | 12743,32  |
| 1 + 2 + 3        | 11237,50  | 618,06 | 10619,44  | 2123,89 | 12743,33  |

Vérification du diagnostic n° 2 : 11 237,50 × 0,05 = 561,875 → 561,88 avec le
`ROUNDED` déjà présent. C'est bien la valeur affichée après la correction 1.

Remarques :

- Le défaut 1 masque les deux autres : tant que le brut est faux, tous les
  montants le sont, et on ne peut rien conclure sur la suite. D'où la méthode
  « dans l'ordre des calculs, un défaut à la fois ».
- Le défaut 3 ne fait qu'**un centime** d'écart. C'est le genre d'anomalie
  qu'on découvre en production des mois plus tard, sur un rapprochement
  comptable.
- La remise avait déjà son `ROUNDED` ; ici il ne change rien (618,0625), mais la
  règle de gestion le demande.
- `WS-TAUX-REMISE` aurait pu disparaître :
  `COMPUTE WS-REMISE ROUNDED = WS-BRUT * WS-REMISE-PCT / 100` laisse le
  compilateur gérer la précision intermédiaire. En maintenance on corrige au
  plus près (la PICTURE) ; en écriture, on évite la zone intermédiaire.

## Partie 2 — Édition et ON SIZE ERROR

Zones ajoutées :

```cobol
      * Zones d'edition
       01  ED-QTE                  PIC ZZ9.
       01  ED-PU                   PIC ZZ9.99.
       01  ED-PCT                  PIC Z9.9.
       01  ED-MONTANT              PIC ZZ,ZZ9.99.
```

Procédure :

```cobol
       MAIN-PARA.
           MULTIPLY WS-QTE BY WS-PU GIVING WS-BRUT
               ON SIZE ERROR
                   DISPLAY "ERREUR : montant brut hors capacite"
                   STOP RUN
           END-MULTIPLY
           DIVIDE WS-REMISE-PCT BY 100 GIVING WS-TAUX-REMISE
           MULTIPLY WS-BRUT BY WS-TAUX-REMISE
               GIVING WS-REMISE ROUNDED
           SUBTRACT WS-REMISE FROM WS-BRUT GIVING WS-NET-HT
           COMPUTE WS-TVA ROUNDED = WS-NET-HT * WS-TVA-PCT / 100
           ADD WS-NET-HT WS-TVA GIVING WS-TTC
           MOVE WS-QTE        TO ED-QTE
           DISPLAY "Quantite       : " ED-QTE
           MOVE WS-PU         TO ED-PU
           DISPLAY "Prix unitaire  : " ED-PU
           MOVE WS-BRUT       TO ED-MONTANT
           DISPLAY "Montant brut   : " ED-MONTANT
           MOVE WS-REMISE-PCT TO ED-PCT
           MOVE WS-REMISE     TO ED-MONTANT
           DISPLAY "Remise " ED-PCT " %  : " ED-MONTANT
           MOVE WS-NET-HT     TO ED-MONTANT
           DISPLAY "Net HT         : " ED-MONTANT
           MOVE WS-TVA        TO ED-MONTANT
           DISPLAY "TVA            : " ED-MONTANT
           MOVE WS-TTC        TO ED-MONTANT
           DISPLAY "Total TTC      : " ED-MONTANT
           STOP RUN.
```

Avec 999 × 999,99 = 998 990,01 :

- avec la clause : `ERREUR : montant brut hors capacite`, et le programme
  s'arrête ;
- sans la clause : le brut vaut 98 990,01 dans une zone `9(05)V99` (8990,01 dans
  la zone d'origine), et la facture est éditée comme si de rien n'était.

Le `END-MULTIPLY` est indispensable : sans lui, tout ce qui suit jusqu'au point
ferait partie du bloc `ON SIZE ERROR`.

Dans un vrai programme, on ne fait pas `STOP RUN` au milieu : on positionne un
indicateur d'erreur et on sort proprement (leçon 04).

## Partie 3 — Quiz

| Q   | Valeur → PICTURE              | Résultat         | Explication |
| --- | ----------------------------- | ---------------- | ----------- |
| Q1  | 1234,5 → `ZZ,ZZ9.99`          | `[ 1,234.50]`    | un zéro de tête supprimé ; décimales complétées |
| Q2  | 0 → `ZZ,ZZ9.99`               | `[     0.00]`    | les `Z` s'arrêtent au `9` ; la virgule disparaît |
| Q3  | 0 → `ZZ,ZZZ.ZZ`               | `[         ]`    | que des `Z` + valeur nulle = zone blanche |
| Q4  | −150,25 → `ZZ,ZZ9.99`         | `[   150.25]`    | pas de symbole de signe : signe perdu |
| Q5  | −150,25 → `--,--9.99`         | `[  -150.25]`    | signe flottant, collé au premier chiffre |
| Q6  | 1234,5 → `--,--9.99`          | `[ 1,234.50]`    | positif : espace à la place du signe |
| Q7  | −150,25 → `ZZ,ZZ9.99CR`       | `[   150.25CR]`  | `CR` affiché car négatif |
| Q8  | 1234,5 → `ZZ,ZZ9.99CR`        | `[ 1,234.50  ]`  | positif : 2 espaces à la place de `CR` |
| Q9  | 1234,5 → `**,**9.99`          | `[*1,234.50]`    | protection de chèque |
| Q10 | 123456 → `ZZ,ZZ9`             | `[23,456]`       | 5 positions de chiffres : poids fort perdu |
| Q11 | 19850314 → `9999/99/99`       | `[1985/03/14]`   | insertion de `/` |
| Q12 | −150,25 → `+ZZ,ZZ9.99`        | `[-   150.25]`   | signe fixe en première position |

Q4 et Q10 sont les deux dangereuses : un avoir affiché comme une facture, et un
montant amputé de son chiffre de tête, sans aucun message.

Q11 est une alternative au `REDEFINES` de la leçon 02 pour afficher une date,
mais elle ne permet pas de changer l'ordre (JJ/MM/AAAA).

## Bonus — DECIMAL-POINT IS COMMA

```cobol
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SPECIAL-NAMES.
           DECIMAL-POINT IS COMMA.
```

À placer entre l'`IDENTIFICATION DIVISION` et la `DATA DIVISION`. Puis :

| Endroit                      | Avant                 | Après                 |
| ---------------------------- | --------------------- | --------------------- |
| littéraux `VALUE`            | `89.90` `5.5` `20.0`  | `89,90` `5,5` `20,0`  |
| `ED-PU`                      | `ZZ9.99`              | `ZZ9,99`              |
| `ED-PCT`                     | `Z9.9`                | `Z9,9`                |
| `ED-MONTANT`                 | `ZZ,ZZ9.99`           | `ZZ.ZZ9,99`           |

Les deux oublis cassent la compilation :

- un littéral `89.90` : le point est maintenant lu comme une fin de phrase, la
  déclaration s'arrête à `89` et le compilateur ne comprend plus rien à la suite
  (cascade d'erreurs, dont un surprenant `PROCEDURE DIVISION header missing`) ;
- une PICTURE `ZZ,ZZ9.99` : la virgule y est devenue le séparateur décimal, donc
  un `9` après des `Z` « décimaux » est refusé.

Les PICTURE internes (`9(05)V99`) ne changent pas : le `V` ne dépend pas de la
convention.
