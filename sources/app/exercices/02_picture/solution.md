# Corrigé 02 — Décoder un enregistrement client

## Partie 1 — Le décalage

Sortie du programme d'origine :

```
Identifiant    : [000427]
Nom            : [DURAND              ]
Prenom         : [MARIE       ]
Code postal    : [   57]
Date naissance : [00019850]
Solde          : [3140001.25]
Statut         : [0]
```

Identifiant, nom et prénom semblent corrects ; tout est faux **à partir du code
postal**. L'erreur est donc dans la dernière zone « correcte » ou juste avant le
code postal : une zone trop courte ou trop longue qui décale toutes les suivantes.

Dessin tel que codé, face à la documentation :

| Zone            | PIC          | Taille | Codé    | Documentation |
| --------------- | ------------ | ------ | ------- | ------------- |
| CLI-ID          | `9(06)`      | 6      | 1–6     | 1–6           |
| CLI-NOM         | `X(20)`      | 20     | 7–26    | 7–26          |
| CLI-PRENOM      | `X(12)`      | 12     | 27–38   | **27–41**     |
| CLI-CP          | `9(05)`      | 5      | 39–43   | 42–46         |
| CLI-DATE-NAISS  | `9(08)`      | 8      | 44–51   | 47–54         |
| CLI-SOLDE       | `9(07)V99`   | 9      | 52–60   | 55–63         |
| CLI-STATUT      | `X(01)`      | 1      | 61      | 64            |

Le prénom fait 15 caractères (41 − 27 + 1), pas 12. Le code postal lisait donc
les 3 derniers espaces du prénom suivis de `57`, et ainsi de suite. Le dessin
codé faisait 61 octets au lieu de 64 : les 3 derniers caractères de la ligne
étaient perdus par le `MOVE` (troncature à droite, silencieuse).

Correction :

```cobol
           05  CLI-PRENOM          PIC X(15).
```

À retenir : le prénom `MARIE` s'affichait correctement malgré l'erreur, parce
qu'il est court. La zone fautive n'est pas forcément celle qui s'affiche mal ;
c'est celle qui précède la première zone fausse.

Le solde : les octets `000125075` s'affichent `0001250.75`. `DISPLAY` insère le
point à l'emplacement du `V`, mais il n'est pas en mémoire.

## Partie 2 — REDEFINES et longueur

```cobol
           05  CLI-DATE-NAISS      PIC 9(08).
           05  CLI-DATE-R REDEFINES CLI-DATE-NAISS.
               10  CLI-NAISS-AAAA  PIC 9(04).
               10  CLI-NAISS-MM    PIC 9(02).
               10  CLI-NAISS-JJ    PIC 9(02).
           05  CLI-SOLDE           PIC 9(07)V99.
```

```cobol
           DISPLAY "Ne(e) le       : " CLI-NAISS-JJ "/" CLI-NAISS-MM "/"
               CLI-NAISS-AAAA
           DISPLAY "Longueur       : " LENGTH OF CLIENT-REC
```

La longueur reste 64 : une redéfinition ne réserve pas de mémoire, elle décrit
autrement des octets qui existent déjà. C'est pour cela qu'on l'ignore quand on
calcule un dessin d'enregistrement.

La redéfinition doit être au même niveau (05) et immédiatement après la zone
redéfinie ; placée après `CLI-SOLDE`, elle ne compile pas.

## Partie 3 — Quiz

| Q  | MOVE                               | Résultat           | Règle |
| -- | ---------------------------------- | ------------------ | ----- |
| Q1 | `"BONJOUR"` → `X(05)`              | `[BONJO]`          | alphanumérique : cadré à gauche, tronqué à droite |
| Q2 | `"AB"` → `X(05)`                   | `[AB   ]`          | complété par des espaces à droite |
| Q3 | `12345` → `9(03)`                  | `[345]`            | numérique : cadré sur la virgule, **poids forts perdus** |
| Q4 | `42` → `9(05)`                     | `[00042]`          | complété par des zéros à gauche |
| Q5 | `1234.567` → `9(03)V99`            | `[234.56]`         | tronqué des deux côtés ; pas d'arrondi (567 → 56) |
| Q6 | `-123` → `9(03)`                   | `[123]`            | cible non signée : le signe est perdu |
| Q7 | `-123` → `S9(03)`                  | `[-123] brut [12s]`| `DISPLAY` montre le signe ; en mémoire il est dans le dernier chiffre (3 négatif = `s` en ASCII GnuCOBOL) |
| Q8 | `42` (zone `9(02)`) → groupe de 5  | `[42] [   ]`       | cible groupe = copie de texte : `42` + 3 espaces |
| Q9 | `12345` (zone `9(05)`) → groupe de 5 | `[12] [345]`     | même source qu'en Q3, mais copie de texte : rien n'est perdu, les octets se répartissent sur les sous-zones |

Q3 et Q9 sont la paire à retenir : la même source donne `345` vers une zone
numérique et `12`/`345` vers un groupe. Le comportement d'un `MOVE` dépend de la
nature de la **cible**.

Q5 : pour arrondir il faut `COMPUTE ... ROUNDED` (leçon 03) ; un `MOVE` ne fait
que tronquer.

## Bonus — COMP et COMP-3

| Zone        | Déclaration              | Taille | Positions |
| ----------- | ------------------------ | ------ | --------- |
| OP-ID       | `9(06)`                  | 6      | 1–6       |
| OP-MONTANT  | `S9(07)V99 COMP-3`       | 5      | 7–11      |
| OP-QTE      | `S9(04) COMP`            | 2      | 12–13     |
| OP-CODE     | `X(03)`                  | 3      | 14–16     |
| OP-TAUX     | `9V999`                  | 4      | 17–20     |
| OP-DATE     | `9(08) COMP-3`           | 5      | 21–25     |

Longueur : **25 octets** ; `OP-CODE` commence en position **14**.

- `S9(07)V99 COMP-3` : 9 chiffres → 9/2 + 1 = 5 octets (le `V` et le `S` ne
  comptent pas ; le signe occupe le dernier demi-octet).
- `9(08) COMP-3` : 8/2 + 1 = 5 octets. Un nombre pair de chiffres « gaspille »
  un demi-octet, d'où l'habitude de déclarer les COMP-3 avec un nombre impair
  de chiffres.
- `S9(04) COMP` : entier binaire sur 2 octets.
