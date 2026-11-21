# Corrigé 05 — Valoriser une commande avec une table de produits

## Partie 1 — Les trois défauts

Inventaire : le tarif contient **6** littéraux de 21 caractères (126 octets),
tous conformes au dessin 4 + 12 + 5. La commande contient 5 lignes de 7
caractères, et `WS-NB-LIGNES` vaut 5.

Sortie d'origine :

```
P100 ECROU M6     010 x   1.20 =      12.00
P300 *** produit inconnu ***
P999 *** produit inconnu ***
P200 *** produit inconnu ***
Total commande  :      12.00
Lignes rejetees : 03
```

### Défaut 1 — l'index n'est positionné qu'une fois

```cobol
       0000-MAIN.
           SET PRD-IDX TO 1
           PERFORM 1000-LIGNE
               VARYING ...
```

`SEARCH` repart de la valeur courante de l'index. Première ligne : `P100` est
en 2ᵉ position du tarif, trouvé, l'index reste à 2. Deuxième ligne : `P300` est
en **1ʳᵉ** position ; la recherche commence à 2, ne le voit jamais et finit en
`AT END`, index au-delà de la table. Toutes les recherches suivantes échouent
immédiatement. Correction : le `SET` doit précéder chaque recherche.

```cobol
       1000-LIGNE.
           SET PRD-IDX TO 1
           SEARCH PRD-ENTREE
```

(Le `SET` de `0000-MAIN` devient inutile ; on peut le retirer.)

Après correction : `P300` et `P200` sont trouvés, total 55,80. Il manque
toujours la 5ᵉ ligne.

### Défaut 2 — la borne de la boucle

```cobol
               VARYING WS-I FROM 1 BY 1 UNTIL WS-I = WS-NB-LIGNES
```

Le test est fait avant chaque tour : quand `WS-I` atteint 5, la boucle s'arrête
sans traiter la ligne 5. Correction :

```cobol
               VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-NB-LIGNES
```

Après correction, la ligne 5 apparaît… en `P600 *** produit inconnu ***`, avec
2 rejets.

### Défaut 3 — OCCURS 5 pour 6 entrées

```cobol
           05  PRD-ENTREE          OCCURS 5 TIMES
```

Le sixième `FILLER` (`P600`) existe bien en mémoire, mais la table redéfinie ne
couvre que les 5 premières entrées : `SEARCH` s'arrête après la 5ᵉ. Quelqu'un a
ajouté un produit sans mettre à jour le dessin. Correction : `OCCURS 6 TIMES`.

Une redéfinition plus **courte** que la zone d'origine est permise, donc le
compilateur ne dit rien.

### À retenir

Le défaut 1 masquait le 2 (toutes les lignes étaient en erreur, une de plus ou
de moins ne se voyait pas), et le 2 masquait le 3 (la ligne `P600` n'était
jamais traitée). Dans les trois cas le programme produit un résultat plausible :
un total, un nombre de rejets. Rien ne signale que des produits valides ont été
rejetés. Sur un vrai fichier de plusieurs milliers de lignes, seul un contrôle
du nombre de rejets alerterait.

## Partie 2 — SEARCH ALL

Modifications de syntaxe :

```cobol
           05  PRD-ENTREE          OCCURS 6 TIMES
                                   ASCENDING KEY IS PRD-CODE
                                   INDEXED BY PRD-IDX.
```

```cobol
       1000-LIGNE.
           SEARCH ALL PRD-ENTREE
               AT END
                   DISPLAY CMD-CODE (WS-I) " *** produit inconnu ***"
                   ADD 1 TO WS-NB-REJETS
               WHEN PRD-CODE (PRD-IDX) = CMD-CODE (WS-I)
                   PERFORM 2000-VALORISER
           END-SEARCH.
```

Avec les données laissées dans l'ordre d'origine (P300, P100, P500, P200, P400,
P600) :

```
P100 *** produit inconnu ***
P300 VIS 6X40     004 x   4.50 =      18.00
P999 *** produit inconnu ***
P200 *** produit inconnu ***
P600 CHEVILLE 8MM 100 x   0.80 =      80.00
Total commande  :      98.00
Lignes rejetees : 03
```

Aucun message, ni à la compilation ni à l'exécution. `P100` et `P200` existent
mais ne sont pas trouvés : la dichotomie part du milieu et élimine à chaque pas
la moitié où la clé « ne peut pas être » si la table est triée. Les produits
trouvés le sont par chance. (Le détail de ceux qui échouent dépend de
l'algorithme du compilateur ; le principe, non.)

Correction : remettre les `FILLER` dans l'ordre croissant des codes.

```cobol
       01  TAB-PRODUITS-VALEURS.
           05  FILLER          PIC X(21) VALUE "P100ECROU M6    00120".
           05  FILLER          PIC X(21) VALUE "P200BOULON M8   01290".
           05  FILLER          PIC X(21) VALUE "P300VIS 6X40    00450".
           05  FILLER          PIC X(21) VALUE "P400TIGE FILETEE00725".
           05  FILLER          PIC X(21) VALUE "P500RONDELLE M6 00035".
           05  FILLER          PIC X(21) VALUE "P600CHEVILLE 8MM00080".
```

**Ajout d'un produit `P250` en fin de table** : il faut (1) passer l'`OCCURS`
à 7, sinon il est ignoré comme au défaut 3 ; (2) l'insérer **à sa place**,
entre `P200` et `P300`, sinon la table n'est plus triée et `SEARCH ALL` rate
des produits, pas forcément le nouveau. Avec un `SEARCH` séquentiel, seul le
point (1) comptait : c'est le prix de la performance.

## Partie 3 — Quiz

| Q   | Résultat         | Explication |
| --- | ---------------- | ----------- |
| Q1  | `[MAR]`          | les indices commencent à 1 ; chaque élément fait 3 caractères |
| Q2  | `24`             | 3 rangées × 4 cases × 2 octets |
| Q3  | `[23]`           | 10 × 2 + 3 |
| Q4  | `[31323334]`     | une rangée est un groupe de 8 octets : ses 4 cases à la suite |
| Q5  | `0090`           | 21 + 22 + 23 + 24 |
| Q6  | `[77]`           | l'« élément 4 » d'une table de 3 est la zone qui suit en mémoire |
| Q7  | `[55]`           | écrire dans l'élément 4 a écrasé `WS-VOISIN` |
| Q8  | `B non trouve`   | la recherche part de l'index 3 ; `B` est en 2 |
| Q9  | `04`             | après succès, l'index désigne l'entrée trouvée |
| Q10 | `06`             | après échec, l'index est au-delà de la table (valeur à ne pas utiliser) |

Avec `-debug`, le programme s'arrête à Q6 :

```
libcob: tables.cob:59: error: subscript of 'WS-NOTE' out of bounds: 4
note: maximum subscript for 'WS-NOTE': 3
```

Q6 et Q7 ne sont prévisibles que parce que `WS-VOISIN` est dans le **même
groupe**, juste derrière la table. Entre deux niveaux 01 distincts, ce qui se
trouve après une table dépend du compilateur.

Q8 est le défaut 1 de la partie 1, en miniature.

Q10 : la norme ne garantit pas la valeur de l'index après un `AT END`. À
retenir seulement : on ne s'en sert pas.

## Bonus — Barème par tranches

```cobol
      * Tranches de remise : seuil de quantite 9(3), taux 9(2)
       01  TAB-TRANCHES-VALEURS.
           05  FILLER          PIC X(05) VALUE "10010".
           05  FILLER          PIC X(05) VALUE "05005".
           05  FILLER          PIC X(05) VALUE "00000".
       01  TAB-TRANCHES REDEFINES TAB-TRANCHES-VALEURS.
           05  TRA-ENTREE          OCCURS 3 TIMES
                                   INDEXED BY TRA-IDX.
               10  TRA-SEUIL       PIC 9(03).
               10  TRA-TAUX        PIC 9(02).
```

```cobol
       2000-VALORISER.
           SET TRA-IDX TO 1
           SEARCH TRA-ENTREE
               WHEN CMD-QTE (WS-I) >= TRA-SEUIL (TRA-IDX)
                   CONTINUE
           END-SEARCH
           COMPUTE WS-MONTANT ROUNDED =
               CMD-QTE (WS-I) * PRD-PRIX (PRD-IDX)
               * (100 - TRA-TAUX (TRA-IDX)) / 100
           ADD WS-MONTANT TO WS-TOTAL
           MOVE PRD-PRIX (PRD-IDX) TO ED-PRIX
           MOVE WS-MONTANT TO ED-MONTANT
           DISPLAY CMD-CODE (WS-I) " " PRD-LIBELLE (PRD-IDX) " "
               CMD-QTE (WS-I) " x " ED-PRIX " = " ED-MONTANT
               " (-" TRA-TAUX (TRA-IDX) " %)".
```

```
P100 ECROU M6     010 x   1.20 =      12.00 (-00 %)
P300 VIS 6X40     004 x   4.50 =      18.00 (-00 %)
P999 *** produit inconnu ***
P200 BOULON M8    002 x  12.90 =      25.80 (-00 %)
P600 CHEVILLE 8MM 100 x   0.80 =      72.00 (-10 %)
Total commande  :     127.80
Lignes rejetees : 01
```

- **Ordre décroissant** : `SEARCH` s'arrête au premier `WHEN` vrai. Rangé de 0
  à 100, le seuil 0 conviendrait à toutes les quantités et la remise serait
  toujours nulle. C'est le même raisonnement que l'ordre des `WHEN` d'un
  `EVALUATE`.
- **Pas de `SEARCH ALL`** : il n'accepte que l'égalité sur la clé. Une tranche
  se cherche avec `>=`.
- La dernière tranche (seuil 0) garantit qu'une entrée est toujours trouvée ;
  c'est pourquoi il n'y a pas de `AT END`.
- Deux tables, deux index distincts : `PRD-IDX` désigne toujours le produit
  pendant que `TRA-IDX` parcourt le barème.
