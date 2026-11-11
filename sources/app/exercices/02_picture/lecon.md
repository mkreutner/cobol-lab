# Leçon 02 — PICTURE, groupes et REDEFINES

En COBOL, on ne déclare pas des « types » : on **dessine** la mémoire, octet par
octet. Avec ton bagage C, pense `struct` packée sans alignement, où chaque champ
a une taille fixe et où tout est (par défaut) du texte. Savoir lire un dessin
d'enregistrement et en calculer les positions est LA compétence de maintenance.

## 1. Niveaux : groupes et zones élémentaires

```cobol
       01  CLIENT-REC.                        groupe (pas de PIC)
           05  CLI-ID          PIC 9(06).     zone elementaire
           05  CLI-IDENTITE.                  sous-groupe
               10  CLI-NOM     PIC X(20).
               10  CLI-PRENOM  PIC X(15).
```

- Le numéro de niveau exprime l'imbrication : `01` est la racine, tout niveau
  supérieur (02 à 49) appartient au niveau plus petit qui le précède. Les valeurs
  sont libres ; l'usage est 01 / 05 / 10 / 15 pour pouvoir intercaler.
- Une **zone élémentaire** a une clause `PIC`. Un **groupe** n'en a pas : sa
  taille est la somme de ses composants, et il est **toujours traité comme du
  texte** (`PIC X`), même s'il ne contient que des chiffres.
- `01` et `77` (zone isolée, vieux style) en zone A ; les autres en zone B.
- `FILLER` : zone sans nom, pour réserver des octets (séparateurs, zones
  inutilisées, « réserve pour évolution » en fin d'enregistrement).

## 2. La clause PICTURE

| Symbole | Signification                                   | Octets (USAGE DISPLAY) |
| ------- | ----------------------------------------------- | ---------------------- |
| `X`     | un caractère quelconque                          | 1                      |
| `A`     | une lettre ou espace (rare)                      | 1                      |
| `9`     | un chiffre                                       | 1                      |
| `V`     | virgule **virtuelle** : position du séparateur décimal | **0**            |
| `S`     | la zone est signée                               | **0** (voir §5)        |

`PIC 9(07)V99` = `PIC 9999999V99` : 9 chiffres, 9 octets, dont les 2 derniers
sont des décimales. La virgule n'est **pas stockée** : `000125075` en mémoire
vaut 1250,75. C'est du décimal en virgule fixe, exact, sans flottant : la raison
d'être de COBOL en comptabilité.

Conséquence en maintenance : en regardant un fichier brut, rien n'indique où est
la virgule ni si un champ est signé. Seul le dessin d'enregistrement le dit.

`VALUE` initialise la zone. Constantes figuratives utiles : `SPACES`, `ZEROS`,
`HIGH-VALUES` (octets 0xFF), `LOW-VALUES` (0x00), `ALL "-"`.

Une zone sans `VALUE` n'est **pas initialisée** (contenu indéfini, comme en C).
Une zone numérique contenant des espaces ou autre chose que des chiffres est
« invalide » : GnuCOBOL affiche n'importe quoi ou calcule faux ; sur mainframe
c'est l'abend **S0C7**, le plus célèbre du monde COBOL.

## 3. MOVE : les règles de cadrage et de troncature

`MOVE source TO cible` ne copie pas des octets : il **convertit selon la cible**.

| Cible                 | Cadrage                    | Si trop court           | Si trop long                          |
| --------------------- | -------------------------- | ----------------------- | ------------------------------------- |
| alphanumérique (`X`)  | à gauche                   | complété par des espaces à droite | tronqué **à droite**         |
| numérique (`9`)       | sur la virgule (`V`)       | complété par des zéros  | tronqué **à gauche** (poids forts !) et à droite pour les décimales |
| groupe                | à gauche, comme du `X`     | espaces à droite        | tronqué à droite                      |

Les troncatures sont **silencieuses** : `MOVE 12345 TO` une zone `PIC 9(3)`
donne 345, sans erreur à l'exécution. Un `MOVE` vers une zone non signée perd
le signe. Un `MOVE` dont la source ou la cible est un groupe est une copie de
texte, sans aucune conversion numérique.

## 4. REDEFINES : deux vues sur les mêmes octets

C'est l'`union` du C.

```cobol
           05  CLI-DATE-NAISS      PIC 9(08).
           05  CLI-DATE-R REDEFINES CLI-DATE-NAISS.
               10  CLI-NAISS-AAAA  PIC 9(04).
               10  CLI-NAISS-MM    PIC 9(02).
               10  CLI-NAISS-JJ    PIC 9(02).
```

Règles :

- même numéro de niveau que la zone redéfinie, et placée **juste après** elle ;
- ne consomme aucun octet de plus (ne compte pas dans la longueur du groupe) ;
- pas de `VALUE` sur la redéfinition ;
- elle ne doit pas être plus longue que la zone d'origine.

Usages typiques dans le legacy : découper une date, voir un nombre comme du
texte pour le tester, et surtout les enregistrements à plusieurs formats (un
code type en tête, puis une zone redéfinie N fois selon le type).

## 5. Signe et USAGE : ce que l'on trouve dans les fichiers

Par défaut (`USAGE DISPLAY`), un chiffre = un caractère lisible. Le signe d'une
zone `S9(3)` n'occupe pas d'octet : il est **encodé dans le dernier chiffre**
(« overpunch », héritage des cartes perforées). -123 s'affiche `-123` avec
`DISPLAY`, mais les octets bruts sont `12s` avec GnuCOBOL en ASCII (`12L` sur
mainframe en EBCDIC). Quand tu vois une lettre à la fin d'un montant dans un
fichier, c'est ça. `SIGN IS LEADING SEPARATE` stocke un vrai `+`/`-` (1 octet).

Deux autres représentations, omniprésentes sur mainframe :

| USAGE                       | Stockage                                      | Taille                                   |
| --------------------------- | --------------------------------------------- | ---------------------------------------- |
| `COMP-3` (`PACKED-DECIMAL`) | BCD : un chiffre par demi-octet, signe dans le dernier demi-octet (`C` +, `D` -, `F` non signé) | `n/2 + 1` octets (division entière) |
| `COMP` (`BINARY`)           | entier binaire, big-endian                    | 1–4 chiffres : 2 · 5–9 : 4 · 10–18 : 8   |

Exemples : `PIC S9(7)V99 COMP-3` → 9 chiffres → 5 octets (`00 01 25 07 5C`).
`PIC S9(4) COMP` → 2 octets. Ces zones sont illisibles dans un éditeur de texte :
un fichier qui en contient ne s'ouvre pas avec `cat`.

## 6. Calculer un dessin d'enregistrement

Méthode, à faire au crayon devant tout nouveau fichier :

1. une ligne par zone élémentaire (ignorer les groupes et les `REDEFINES`) ;
2. taille de chacune d'après `PIC` et `USAGE` ;
3. position de début = position de fin précédente + 1 (on compte à partir de 1) ;
4. la dernière position de fin = longueur de l'enregistrement, à comparer à la
   longueur réelle du fichier (`LRECL` sur mainframe).

Pour vérifier à l'exécution : `DISPLAY LENGTH OF CLIENT-REC`.

Une erreur d'un seul octet dans une zone **décale toutes les suivantes** : c'est
le symptôme classique « à partir du champ N, tout est faux ».
