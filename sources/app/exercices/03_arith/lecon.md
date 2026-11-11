# Leçon 03 — Arithmétique décimale et édition

COBOL calcule en **décimal à virgule fixe** : pas de flottant, pas d'erreur de
représentation sur 0,1. En contrepartie, la précision de chaque résultat est
celle de la zone qui le reçoit, et tout ce qui dépasse est perdu sans un mot.
En maintenance, la plupart des « erreurs de calcul » sont des erreurs de
déclaration.

## 1. Les verbes arithmétiques

Le code ancien utilise les verbes « en toutes lettres ». Leur piège : savoir
**quelle zone reçoit le résultat**.

| Instruction                                | Effet                    |
| ------------------------------------------ | ------------------------ |
| `ADD A TO B`                               | B = B + A                |
| `ADD A B GIVING C`                         | C = A + B                |
| `SUBTRACT A FROM B`                        | B = B − A                |
| `SUBTRACT A FROM B GIVING C`               | C = B − A                |
| `MULTIPLY A BY B`                          | **B** = A × B            |
| `MULTIPLY A BY B GIVING C`                 | C = A × B                |
| `DIVIDE A INTO B`                          | B = B / A                |
| `DIVIDE A INTO B GIVING C`                 | C = B / A                |
| `DIVIDE A BY B GIVING C`                   | C = A / B                |
| `DIVIDE A BY B GIVING Q REMAINDER R`       | quotient et reste        |

Sans `GIVING`, le résultat écrase le **dernier** opérande. `DIVIDE A INTO B` et
`DIVIDE A BY B` sont inversés l'un par rapport à l'autre : c'est la confusion la
plus fréquente à la lecture.

`COMPUTE` (depuis COBOL 74) écrit une expression classique, avec `+ - * / **` et
des parenthèses :

```cobol
           COMPUTE WS-TTC = WS-HT * (1 + WS-TAUX / 100)
```

Il faut des **espaces autour des opérateurs** : `A-B` est un nom de zone, pas
une soustraction.

Pour écrire du nouveau code : `COMPUTE` dès qu'il y a plus d'une opération,
`ADD 1 TO WS-CPT` pour les compteurs.

## 2. Troncature et ROUNDED

Le résultat est calculé avec toute la précision nécessaire, puis rangé dans la
cible selon les règles du `MOVE` numérique (leçon 02) :

- décimales en trop : **tronquées**, sauf si l'on écrit `ROUNDED` ;
- chiffres de poids fort en trop : **perdus** (dépassement de capacité, §3).

```cobol
           COMPUTE WS-TVA         = WS-HT * 0.20      2123.888 -> 2123.88
           COMPUTE WS-TVA ROUNDED = WS-HT * 0.20      2123.888 -> 2123.89
           MULTIPLY A BY B GIVING C ROUNDED
```

`ROUNDED` se place après la zone réceptrice. Il arrondit au plus proche, le
demi s'éloignant de zéro (2,345 → 2,35).

**Les zones intermédiaires comptent autant que la zone finale.** Si un taux de
5,5 % est rangé dans une zone `PIC 9V99`, il devient 0,05 et tout ce qui en
découle est faux de 10 %. Règle pratique : un taux ou un coefficient a besoin de
plus de décimales que les montants qu'il sert à calculer.

À l'intérieur d'un seul `COMPUTE`, le compilateur gère lui-même la précision des
résultats intermédiaires ; le risque apparaît quand le calcul est découpé en
plusieurs instructions avec des zones de travail.

## 3. Dépassement de capacité : ON SIZE ERROR

125 × 89,90 = 11 237,50 dans une zone `PIC 9(04)V99` donne **1237,50**, sans
erreur, sans avertissement. Division par zéro : GnuCOBOL laisse la cible
inchangée et continue ; sur mainframe c'est un abend (S0CB).

La clause `ON SIZE ERROR` intercepte les deux cas :

```cobol
           MULTIPLY WS-QTE BY WS-PU GIVING WS-BRUT
               ON SIZE ERROR
                   DISPLAY "ERREUR : montant brut hors capacite"
                   STOP RUN
           END-MULTIPLY
```

- Quand elle se déclenche, la zone réceptrice **n'est pas modifiée**.
- Elle existe pour `ADD`, `SUBTRACT`, `MULTIPLY`, `DIVIDE`, `COMPUTE`, avec le
  terminateur `END-xxx` correspondant (et `NOT ON SIZE ERROR` pour le cas normal).
- Elle ne détecte que la perte de chiffres de poids fort, pas la troncature des
  décimales.

Dimensionner une zone résultat : pour un produit, additionner les nombres de
chiffres entiers des opérandes (`9(03)` × `9(03)V99` → jusqu'à 6 chiffres
entiers) ; pour une somme, un chiffre de plus que le plus grand opérande.

## 4. Zones numériques et USAGE pour le calcul

Les zones `DISPLAY` (un chiffre par octet) conviennent très bien. Sur mainframe,
les zones de calcul sont souvent en `COMP-3` (montants) ou `COMP` (compteurs,
indices) pour la performance ; le résultat est le même. Pense à déclarer `S`
(signé) toute zone qui peut devenir négative : une zone non signée perd le signe
(leçon 02, Q6).

## 5. PICTURE d'édition : présenter un nombre

Une zone numérique « brute » s'affiche avec ses zéros de tête (`00618.06`).
Pour présenter, on déclare une **zone d'édition** et on y fait un `MOVE` : c'est
le `MOVE` qui met en forme.

| Symbole | Effet                                                            |
| ------- | ---------------------------------------------------------------- |
| `9`     | chiffre, toujours affiché                                        |
| `Z`     | chiffre, remplacé par un espace si c'est un zéro de tête         |
| `*`     | comme `Z` mais remplace par `*` (chèques)                        |
| `.`     | point décimal **réel** (occupe un caractère), aligné sur le `V`  |
| `,`     | séparateur de milliers ; disparaît s'il n'y a pas de chiffre à sa gauche |
| `-`     | signe : affiche `-` si négatif, espace sinon                     |
| `+`     | signe : affiche `+` ou `-`                                       |
| `CR` `DB` | 2 caractères en fin de zone, affichés seulement si négatif     |
| `B` `0` `/` | insertion d'un espace, d'un zéro, d'une barre                |

Exemples avec 1234,5 :

```
PIC ZZ,ZZ9.99     ->  [ 1,234.50]
PIC **,**9.99     ->  [*1,234.50]
PIC 9(05).99      ->  [01234.50]
```

Points à connaître :

- `Z` s'arrête au premier `9` : `ZZ,ZZ9.99` garantit au moins `0.00`. Avec que
  des `Z` (`ZZ,ZZZ.ZZ`), une valeur nulle donne une zone **entièrement blanche**.
- Répété, le signe devient « flottant » : `--,--9.99` colle le `-` au premier
  chiffre (`  -150.25`). Un seul signe en tête reste à sa place (`-   150.25`).
- Sans symbole de signe dans la PICTURE, une valeur négative s'affiche sans
  signe.
- La zone d'édition tronque comme les autres : 123456 dans `ZZ,ZZ9` donne
  `23,456`.
- Une zone d'édition est du texte : on ne calcule pas dessus. On garde les
  montants dans des zones numériques et on ne passe en édition qu'à l'affichage.
- La taille d'une zone d'édition est le nombre de symboles (`CR` en vaut 2).

## 6. DECIMAL-POINT IS COMMA

Beaucoup de programmes français contiennent ceci :

```cobol
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SPECIAL-NAMES.
           DECIMAL-POINT IS COMMA.
```

Cela **échange les rôles** du point et de la virgule dans tout le programme :
les PICTURE d'édition s'écrivent `ZZ.ZZ9,99` (affiche `11.237,50`) et les
littéraux numériques du code s'écrivent `89,90`. Avant de lire un calcul ou une
PICTURE dans un programme inconnu, regarde s'il y a un `SPECIAL-NAMES`.
