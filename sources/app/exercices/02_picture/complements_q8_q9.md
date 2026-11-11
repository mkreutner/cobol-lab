Voici un petit complément sur les questions Q8 et Q9 du sujet, qui sont un peu plus subtiles que les autres. 

Les deux reposent sur une seule règle : quand la cible est un groupe, le MOVE ne regarde pas les sous-zones. Il traite le groupe comme un seul bloc de texte PIC X(5) et y recopie les octets de la source, cadrés à gauche. Le découpage en WS-G-NUM et WS-G-TXT n’intervient qu’après, quand on relit.

## Rappel des déclarations :

```cobol
       01  WS-PETIT     PIC 9(02) VALUE 42.       octets : 4 2
       01  WS-GRAND     PIC 9(05) VALUE 12345.    octets : 1 2 3 4 5
       01  WS-GRP.                                5 octets
           05  WS-G-NUM PIC 9(02).                octets 1-2
           05  WS-G-TXT PIC X(03).                octets 3-5
```

## Q8 : MOVE WS-PETIT TO WS-GRP

La source fait 2 octets (42), la cible 5. Copie de texte : cadrage à gauche, complément par des espaces à droite.

```cobol
WS-GRP :   4  2  ␣  ␣  ␣
         └G-NUM┘└─G-TXT─┘
```

D’où `[42] [ ]`. Le piège : si la cible avait été une zone numérique PIC 9(05), comme en Q4, tu aurais eu 00042, cadré à droite avec des zéros. Ici, pas de conversion numérique, donc pas de zéros.

## Q9 : MOVE WS-GRAND TO WS-GRP

La source fait 5 octets (12345), la cible 5. Tout rentre, octet pour octet.

```cobol
WS-GRP :   1  2  3  4  5
         └G-NUM┘└─G-TXT─┘
```

D’où `[12] [345]`. Le nombre 12345 n’existe plus en tant que nombre : ses chiffres sont simplement répartis sur les deux sous-zones. WS-G-NUM vaut 12 parce qu’il occupe les deux premiers octets, pas parce qu’on a calculé quoi que ce soit.

## Pourquoi j’ai mis ces deux questions

Compare Q9 avec Q3, qui a la même source :

| # | Cible | Type de MOVE | Résultat |
|---|---|---|---|
| Q3 | `WS-N3 PIC 9(03)` | numérique : aligné sur la virgule, poids forts perdus | `345` |
| Q9 | `WS-GRP (groupe)` | texte : aligné à gauche | `12` puis `345` |

En C, Q3 ressemble à une affectation avec conversion (`n3 = grand % 1000`), Q8 et Q9 à un memcpy dans une struct, complété par des espaces. C’est la cible qui décide lequel des deux se produit.

En maintenance, ça explique un bug classique : quelqu’un fait un MOVE d’un montant vers un groupe en croyant alimenter la zone numérique qu’il contient, et se retrouve avec des espaces dans un champ numérique (Q8 : si WS-G-TXT avait été un PIC 9(03), il contiendrait trois espaces, donc une valeur invalide).