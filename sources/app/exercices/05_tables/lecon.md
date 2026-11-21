# Leçon 05 — Tables : OCCURS, indices et SEARCH

Une table COBOL est une zone (ou un groupe) répétée N fois, de taille fixe,
décidée à la compilation. Pas d'allocation dynamique, pas de liste : un bloc
d'octets contigus, comme un tableau de `struct` en C. Les tables servent
surtout de **référentiels en mémoire** (tarifs, libellés, barèmes) que l'on
consulte pendant un traitement.

## 1. OCCURS

```cobol
       01  WS-MOIS-TABLE.
           05  WS-MOIS             PIC X(03) OCCURS 12 TIMES.

       01  TAB-PRODUITS.
           05  PRD-ENTREE          OCCURS 6 TIMES.
               10  PRD-CODE        PIC X(04).
               10  PRD-LIBELLE     PIC X(12).
               10  PRD-PRIX        PIC 9(03)V99.
```

- `OCCURS` ne se met pas sur un niveau 01 : la table est toujours dans un
  groupe.
- On désigne un élément avec un **indice entre parenthèses** : `WS-MOIS (3)`,
  `PRD-PRIX (WS-I)`. Dans une table de groupes, l'indice se met sur la zone
  que l'on veut : `PRD-CODE (2)` est le code de la 2ᵉ entrée, `PRD-ENTREE (2)`
  l'entrée entière (21 caractères).
- **Le premier élément porte le numéro 1**, pas 0.
- Longueur : taille d'un élément × nombre d'occurrences (ici 21 × 6 = 126).
- Deux dimensions : un `OCCURS` dans un `OCCURS`, et deux indices séparés par
  une virgule ou un espace : `WS-CASE (2, 3)`.

## 2. Initialiser une table : FILLER + REDEFINES

On ne peut pas donner une liste de valeurs à un `OCCURS`. L'idiome que tu
verras dans tous les programmes anciens : décrire les données comme une suite
de `FILLER`, puis **redéfinir** ce bloc comme une table.

```cobol
       01  TAB-PRODUITS-VALEURS.
           05  FILLER          PIC X(21) VALUE "P100ECROU M6    00120".
           05  FILLER          PIC X(21) VALUE "P200BOULON M8   01290".
           05  FILLER          PIC X(21) VALUE "P300VIS 6X40    00450".
       01  TAB-PRODUITS REDEFINES TAB-PRODUITS-VALEURS.
           05  PRD-ENTREE          OCCURS 3 TIMES.
               10  PRD-CODE        PIC X(04).
               10  PRD-LIBELLE     PIC X(12).
               10  PRD-PRIX        PIC 9(03)V99.
```

Chaque littéral doit respecter le dessin de l'entrée au caractère près :
`00120` est le prix 1,20 (`9(03)V99`, sans virgule). Trois choses peuvent se
désynchroniser sans erreur de compilation, et c'est à vérifier dès qu'on ajoute
une ligne :

- la longueur d'un littéral (leçon 02 : tout ce qui suit est décalé) ;
- le **nombre d'occurrences** : si l'on ajoute un `FILLER` sans changer
  l'`OCCURS`, la nouvelle entrée existe en mémoire mais n'est jamais consultée ;
- l'ordre des entrées, si la table est censée être triée (§5).

En production, les tables sont plus souvent chargées depuis un fichier au
démarrage ; le principe de consultation est le même.

## 3. Parcourir une table

```cobol
           PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-NB-LIGNES
               ADD CMD-QTE (WS-I) TO WS-TOTAL-QTE
           END-PERFORM
```

La condition d'arrêt est `> N`. Avec `= N`, la boucle s'arrête **avant** de
traiter le dernier élément (leçon 04 : le test est fait avant chaque tour).

Le nombre d'éléments réellement utilisés est en général dans une zone à part
(`WS-NB-LIGNES`) : la table est dimensionnée au maximum, et on n'en remplit
qu'une partie.

## 4. Hors des bornes : aucun contrôle

Par défaut, **rien ne vérifie l'indice**. `WS-NOTE (4)` sur une table de 3
éléments lit les octets qui suivent la table en mémoire, et un `MOVE` vers cet
élément écrase la zone voisine. Pas d'erreur, pas de message : exactement un
débordement de tableau en C.

GnuCOBOL sait ajouter le contrôle à l'exécution avec l'option `-debug` :

```bash
just cobc_opts="-Wall -debug" ex-run 05 tables
```

```
libcob: tables.cob:59: error: subscript of 'WS-NOTE' out of bounds: 4
```

Sur mainframe, l'option équivalente s'appelle `SSRANGE`. Elle est rarement
active en production, pour des raisons de performance : d'où des corruptions
de données qui se révèlent loin de leur cause.

## 5. Indices, index et SEARCH

On peut indicer une table de deux façons :

| | Indice (« subscript ») | Index |
| - | ---------------------- | ----- |
| déclaration | une zone numérique ordinaire : `01 WS-I PIC 9(02).` | dans l'`OCCURS` : `INDEXED BY PRD-IDX` |
| manipulation | `MOVE`, `ADD`, `COMPUTE` | uniquement `SET` : `SET PRD-IDX TO 1`, `SET PRD-IDX UP BY 1` |
| affichage | `DISPLAY WS-I` | pas directement : `SET WS-N TO PRD-IDX` d'abord |

Un index appartient à sa table, et il est obligatoire pour `SEARCH`.

### SEARCH : recherche séquentielle

```cobol
           SET PRD-IDX TO 1
           SEARCH PRD-ENTREE
               AT END
                   DISPLAY "produit inconnu"
               WHEN PRD-CODE (PRD-IDX) = WS-CODE-CHERCHE
                   MOVE PRD-PRIX (PRD-IDX) TO WS-PRIX
           END-SEARCH
```

- On cite le nom qui porte l'`OCCURS` (`PRD-ENTREE`), pas la table 01.
- `SEARCH` avance l'index jusqu'à ce qu'un `WHEN` soit vrai ; l'index désigne
  alors l'entrée trouvée. Sinon, `AT END`.
- **`SEARCH` part de la valeur courante de l'index.** Il faut un
  `SET ... TO 1` avant *chaque* recherche. Oublié, ou fait une seule fois avant
  une boucle, la recherche suivante repart de là où la précédente s'est
  arrêtée : les entrées situées avant ne sont plus jamais trouvées.
- La condition du `WHEN` est libre (`>=`, plusieurs `WHEN`…), ce qui permet les
  recherches par tranche dans un barème.

### SEARCH ALL : recherche dichotomique

```cobol
           05  PRD-ENTREE          OCCURS 6 TIMES
                                   ASCENDING KEY IS PRD-CODE
                                   INDEXED BY PRD-IDX.
```

```cobol
           SEARCH ALL PRD-ENTREE
               AT END
                   DISPLAY "produit inconnu"
               WHEN PRD-CODE (PRD-IDX) = WS-CODE-CHERCHE
                   MOVE PRD-PRIX (PRD-IDX) TO WS-PRIX
           END-SEARCH
```

- Pas de `SET` préalable : la recherche gère l'index elle-même.
- Le `WHEN` ne peut tester que l'**égalité** sur la clé déclarée.
- **La table doit être réellement triée** sur cette clé. `ASCENDING KEY` est
  une promesse faite au compilateur, pas un tri : si les données ne sont pas
  dans l'ordre, certaines entrées ne sont pas trouvées, sans aucun message.

Séquentiel pour les petites tables ou les recherches par tranche ; dichotomique
pour les grandes tables consultées par clé exacte.

## 6. Ce que tu croiseras aussi

- `OCCURS 1 TO 500 TIMES DEPENDING ON WS-NB` : table de taille variable (la
  mémoire est réservée pour le maximum ; `WS-NB` borne les recherches).
- `INITIALIZE TAB-PRODUITS` : remet toutes les zones numériques à zéro et les
  alphanumériques à espaces, élément par élément.
- `MOVE SPACES TO TAB-PRODUITS` : copie de texte sur tout le groupe, donc des
  espaces aussi dans les zones numériques (données invalides, leçon 02).
