# Exercice 02 — Décoder un enregistrement client

Prérequis : `lecon.md`.

## Objectifs

- Lire un dessin d'enregistrement et calculer positions et longueurs.
- Diagnostiquer un décalage de zones.
- Utiliser `REDEFINES` pour voir une même zone de deux façons.
- Prévoir le résultat d'un `MOVE` (cadrage, troncature, signe).

## Le contexte

Un fichier client contient des enregistrements de longueur fixe. La
documentation (la seule qui fasse foi) donne les **positions** :

| Zone               | Positions | Contenu                                         |
| ------------------ | --------- | ----------------------------------------------- |
| Identifiant        | 1–6       | numérique                                       |
| Nom                | 7–26      | texte                                           |
| Prénom             | 27–41     | texte                                           |
| Code postal        | 42–46     | numérique                                       |
| Date de naissance  | 47–54     | AAAAMMJJ                                        |
| Solde              | 55–63     | numérique, 7 entiers et 2 décimales, sans virgule |
| Statut             | 64        | `A` actif, `S` suspendu, `C` clos               |

`sujet.cob` charge une ligne de ce fichier (en dur dans `WS-LIGNE`) dans
`CLIENT-REC` et affiche chaque zone entre crochets.

## Partie 1 — Maintenance : trouver le décalage

1. Lance le programme et observe la sortie :

   ```bash
   just ex-run 02
   ```

2. À partir de quelle zone l'affichage est-il faux ? Qu'est-ce que ça t'apprend
   sur l'endroit où se trouve l'erreur ?

3. Sur papier, fais le tableau du dessin `CLIENT-REC` **tel qu'il est codé** :
   pour chaque zone, taille, position de début, position de fin. Compare avec la
   documentation.

4. Corrige l'erreur (une seule ligne à modifier) et relance. Le solde doit
   s'afficher `0001250.75`.

## Partie 2 — Évolution : date lisible et contrôle de longueur

Dans `sujet.cob` :

- ajoute une redéfinition de `CLI-DATE-NAISS` en trois sous-zones (année, mois,
  jour) et affiche une ligne `Ne(e) le       : 14/03/1985` ;
- affiche la longueur de `CLIENT-REC` avec `LENGTH OF` et vérifie qu'elle vaut
  bien 64 avec la redéfinition en place. Pourquoi n'a-t-elle pas augmenté ?

## Partie 3 — Quiz : prédire les MOVE

`moves.cob` enchaîne 9 `MOVE` et affiche le résultat de chacun. **Sans le
lancer**, lis les déclarations et écris ce que tu penses voir pour Q1 à Q9
(crochets compris, espaces compris). Ensuite seulement :

```bash
just ex-run 02 moves
```

Pour chaque écart entre ta prédiction et la réalité, retrouve la règle de la
leçon (§3 et §5) qui l'explique.

## Bonus — Calcul papier avec COMP et COMP-3

Quelle est la longueur en octets de cet enregistrement, et à quelle position
commence `OP-CODE` ?

```cobol
       01  OPERATION-REC.
           05  OP-ID           PIC 9(06).
           05  OP-MONTANT      PIC S9(07)V99 COMP-3.
           05  OP-QTE          PIC S9(04)    COMP.
           05  OP-CODE         PIC X(03).
           05  OP-TAUX         PIC 9V999.
           05  OP-DATE         PIC 9(08)     COMP-3.
```

Tu peux vérifier ta réponse en écrivant un petit programme avec `LENGTH OF`.

## Rendu

Envoie-moi ton `sujet.cob`, ton tableau de la partie 1, et tes prédictions du
quiz **avec** celles où tu t'es trompé (ce sont les plus intéressantes). Le
corrigé est dans `solution.md`.
