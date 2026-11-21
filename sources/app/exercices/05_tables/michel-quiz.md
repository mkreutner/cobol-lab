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