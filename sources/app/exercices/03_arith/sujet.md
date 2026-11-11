# Exercice 03 — Une ligne de facture qui calcule faux

Prérequis : `lecon.md`.

## Objectifs

- Lire les verbes `ADD`, `SUBTRACT`, `MULTIPLY`, `DIVIDE`, `COMPUTE`.
- Diagnostiquer troncature, perte de précision et arrondi.
- Protéger un calcul avec `ON SIZE ERROR`.
- Présenter des montants avec des PICTURE d'édition.

## Le contexte

`sujet.cob` calcule une ligne de facture : 125 articles à 89,90 €, remise de
5,5 %, TVA à 20 %. La comptabilité a refait le calcul à la main et attend :

| Élément        | Valeur attendue |
| -------------- | --------------- |
| Montant brut   | 11 237,50       |
| Remise (5,5 %) | 618,06          |
| Net HT         | 10 619,44       |
| TVA (20 %)     | 2 123,89        |
| Total TTC      | 12 743,33       |

Règles de gestion : la remise et la TVA sont arrondies au centime le plus
proche.

## Partie 1 — Maintenance : trois causes

1. Lance le programme et compare avec le tableau :

   ```bash
   just ex-run 03
   ```

2. Il y a **trois** défauts indépendants. Procède dans l'ordre des calculs :
   corrige le premier montant faux, relance, et recommence. Pour chacun, note
   la ligne, la cause (leçon §2 ou §3) et la correction. Deux se corrigent dans
   la `DATA DIVISION`, un dans la `PROCEDURE DIVISION`.

3. Avant de corriger, recalcule à la main ce que le programme obtient pour la
   remise avec le taux qu'il affiche : tu dois retrouver sa valeur fausse. C'est
   comme ça qu'on confirme un diagnostic.

## Partie 2 — Évolution : présentation et garde-fou

Toujours dans `sujet.cob` :

- Remplace l'affichage brut par des zones d'édition, pour obtenir :

  ```
  Quantite       : 125
  Prix unitaire  :  89.90
  Montant brut   : 11,237.50
  Remise  5.5 %  :    618.06
  Net HT         : 10,619.44
  TVA            :  2,123.89
  Total TTC      : 12,743.33
  ```

  Une seule zone d'édition peut servir pour tous les montants.

- Protège le calcul du montant brut avec `ON SIZE ERROR` : message d'erreur et
  arrêt. Teste en mettant temporairement 999 articles à 999,99 €. Que se
  passait-il sans la clause ?

## Partie 3 — Quiz : prédire l'édition

`edition.cob` fait 12 `MOVE` vers des zones d'édition. **Sans le lancer**,
écris ce que tu attends pour Q1 à Q12, en comptant les espaces (la largeur de
chaque zone est le nombre de symboles de sa PICTURE). Ensuite :

```bash
just ex-run 03 edition
```

## Bonus — Version française

Copie ton `sujet.cob` corrigé en `francais.cob`, ajoute `DECIMAL-POINT IS COMMA`
et adapte ce qu'il faut pour afficher `11.237,50`. Combien d'endroits as-tu dû
modifier, et lesquels auraient cassé la compilation si tu les avais oubliés ?

```bash
just ex-run 03 francais
```

## Rendu

Ton `sujet.cob` final, tes notes sur les trois causes, et tes prédictions du
quiz avec les écarts. Corrigé dans `solution.md`.
