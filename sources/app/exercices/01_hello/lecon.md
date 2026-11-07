# Leçon 01 — Anatomie d'un programme COBOL

## 1. Les 4 DIVISION, toujours dans cet ordre

```
IDENTIFICATION DIVISION.    obligatoire : au minimum PROGRAM-ID.
ENVIRONMENT DIVISION.       optionnelle : fichiers (SELECT ... ASSIGN), config machine
DATA DIVISION.              optionnelle : FILE SECTION, WORKING-STORAGE, LINKAGE SECTION
PROCEDURE DIVISION.         optionnelle en théorie ; en pratique c'est là que ça s'exécute
```

Le plus petit programme valide :

```cobol
       IDENTIFICATION DIVISION.
       PROGRAM-ID. RIEN.
       PROCEDURE DIVISION.
           STOP RUN.
```

Chaque division se découpe en SECTION (facultatives dans PROCEDURE DIVISION), et
chaque section en **paragraphes**. Un paragraphe est un nom suivi d'un point, puis
d'instructions. C'est l'unité de base que l'on appelle avec `PERFORM` (leçon 04).

## 2. Format fixe : la carte perforée de 80 colonnes

C'est **le** piège n° 1 en maintenance. Dans le code historique (et dans tout ce qui
tourne sur mainframe), chaque ligne est découpée ainsi :

| Colonnes | Nom            | Usage                                                                  |
| -------- | -------------- | ---------------------------------------------------------------------- |
| 1–6      | séquence       | ignorées par le compilateur (anciens numéros de ligne, souvent vides)  |
| 7        | indicateur     | `*` commentaire, `/` saut de page, `-` continuation, `D` ligne de debug |
| 8–11     | **zone A**     | en-têtes de DIVISION et SECTION, noms de paragraphes, niveaux `01`/`77`, `FD` |
| 12–72    | **zone B**     | tout le reste : instructions, niveaux 02–49, clauses                   |
| 73–80    | identification | ignorées (sur mainframe : nom du programme, dates de modification…)    |

Conséquences pratiques :

- Un `*` en colonne 8 au lieu de 7 n'est plus un commentaire : le compilateur lit
  la ligne comme du code et plante dessus.
- Un nom de paragraphe qui commence en colonne 12 est pris pour une instruction, et
  une instruction en colonne 8 peut être prise pour un nom de paragraphe. Selon le
  compilateur c'est une erreur, un avertissement, ou rien du tout (GnuCOBOL est
  tolérant). Un programme qui compile chez toi peut donc ne pas compiler ailleurs.
- Tout ce qui dépasse la colonne 72 est **silencieusement ignoré**. Un guillemet
  fermant ou un point qui déborde en colonne 73 disparaît sans message précis : tu
  obtiens une erreur de littéral non terminé ou de syntaxe plus loin, pas « ligne
  trop longue ». Classique après un renommage de variable qui allonge une ligne.
- Les éditeurs modernes n'affichent pas les colonnes : active une règle à 72 dans
  VS Code (`"editor.rulers": [7, 11, 72]` dans les settings, éventuellement limité
  à `[cobol]`) dès que tu ouvres du COBOL.

Une ligne de suite (littéral trop long) se fait avec `-` en colonne 7 et un guillemet
d'ouverture en zone B sur la ligne suivante :

```cobol
           DISPLAY "Un texte tres long qui ne tient pas sur une seule lign
      -    "e de 72 colonnes"
```

### Format libre

GnuCOBOL (et les compilateurs mainframe récents) acceptent le **format libre** :
pas de contrainte de colonne, commentaires avec `*>` n'importe où sur la ligne.
On l'active avec l'option `-free` de `cobc`, ou directement dans le source avec la
directive en première ligne :

```cobol
       >>SOURCE FORMAT IS FREE
```

Dans le lab, `just run` / `just compile` utilisent `-free` par défaut ; les
exercices sont compilés en format fixe (`just ex-*`) parce que c'est ce que tu
rencontreras en maintenance. Tu peux écrire tes nouveaux programmes en libre.

## 3. Le point, cet ennemi

En COBOL le point termine :

- chaque en-tête : `IDENTIFICATION DIVISION.`, `PROGRAM-ID. HELLO01.`,
  `WORKING-STORAGE SECTION.` ;
- chaque description de donnée : `01  WS-NOM  PIC X(30).` ;
- chaque **paragraphe** de la PROCEDURE DIVISION : son nom (`MAIN-PARA.`) et sa
  dernière instruction.

À l'intérieur d'un paragraphe, les instructions s'enchaînent **sans point**. Un
point au milieu d'un `IF` ferme l'`IF` : tout ce qui suit est exécuté
inconditionnellement, sans que le compilateur ne dise rien. C'est la source de bugs
n° 1 du code ancien, et la raison pour laquelle le COBOL moderne (depuis 1985)
utilise les terminateurs explicites `END-IF`, `END-PERFORM`, `END-READ`…

Règle de survie quand tu écris : **un seul point, à la fin du paragraphe**, et des
`END-xxx` partout.

Un oubli de point sur un en-tête (`PROGRAM-ID. HELLO01` sans point) donne une
erreur de syntaxe souvent signalée **sur la ligne suivante**, car le compilateur
continue à lire l'en-tête.

## 4. Les instructions du jour

```cobol
           DISPLAY "Texte " WS-VAR " suite"      *> concatene ses arguments, saut de ligne a la fin
           DISPLAY "Prompt : " WITH NO ADVANCING  *> sans saut de ligne
           ACCEPT WS-NOM                          *> lit une ligne sur stdin dans WS-NOM
           ACCEPT WS-DATE FROM DATE YYYYMMDD      *> date systeme, 8 chiffres
           ACCEPT WS-HEURE FROM TIME              *> HHMMSSCC
           STOP RUN                               *> fin du programme (code retour 0)
```

`ACCEPT` dans une zone `PIC X(30)` : la saisie est cadrée à gauche et complétée
par des espaces. Pour afficher sans les espaces de fin : `FUNCTION TRIM(WS-NOM)`.

Pour afficher une date `AAAAMMJJ` au format `JJ/MM/AAAA`, on la découpe en
sous-zones (c'est le sujet de la leçon 02, en voici un avant-goût) :

```cobol
       01  WS-DATE.
           05 WS-AAAA   PIC 9(4).
           05 WS-MM     PIC 9(2).
           05 WS-JJ     PIC 9(2).
       ...
           ACCEPT WS-DATE FROM DATE YYYYMMDD
           DISPLAY WS-JJ "/" WS-MM "/" WS-AAAA
```

## 5. Conventions de nommage et de style

- Les mots-clés et identifiants ne sont **pas** sensibles à la casse. Les majuscules
  sont une tradition (cartes perforées), pas une obligation.
- Le trait d'union est autorisé dans les noms (`WS-NOM`), jusqu'à 30 caractères ;
  pas de souligné dans le standard (GnuCOBOL le tolère, les mainframes non).
- Préfixes courants que tu croiseras : `WS-` (working-storage), `LS-` (linkage),
  `FD-`/`REC-` (enregistrements de fichier), `WS-EOF`, `WS-CPT-…` (compteurs).
- Noms de paragraphes souvent numérotés (`0000-MAIN`, `1000-INIT`, `2000-TRAITE`,
  `9000-FIN`) pour refléter l'ordre d'exécution.

## 6. Compiler avec GnuCOBOL

| Option            | Effet                                                        |
| ----------------- | ------------------------------------------------------------ |
| `cobc -x`         | produit un exécutable (sans `-x` : un module `.so`)          |
| `-free`           | format libre                                                 |
| `-fixed`          | format fixe (défaut)                                         |
| `-Wall`           | tous les avertissements                                      |
| `-std=ibm`        | dialecte IBM Enterprise COBOL (utile pour tester du legacy)  |
| `-fsyntax-only`   | vérifie sans produire de binaire                             |
| `-o bin/x`        | nom de sortie                                                |

Les messages d'erreur donnent `fichier:ligne: error: …`. Le numéro de ligne est
celui du fichier source, pas la colonne de séquence.
