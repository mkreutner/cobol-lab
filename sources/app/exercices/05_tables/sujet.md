# Exercice 05 — Valoriser une commande avec une table de produits

Prérequis : `lecon.md`.

## Objectifs

- Lire une table initialisée par `FILLER` + `REDEFINES`.
- Diagnostiquer les défauts classiques : borne de boucle, index de `SEARCH`,
  nombre d'occurrences.
- Passer d'un `SEARCH` séquentiel à un `SEARCH ALL`.
- Constater ce qui se passe hors des bornes d'une table.

## Le contexte

`sujet.cob` contient deux tables en dur :

- `TAB-PRODUITS` : le tarif (code, libellé, prix unitaire) ;
- `TAB-COMMANDE` : les 5 lignes d'une commande (code produit, quantité).

Pour chaque ligne, il cherche le produit dans le tarif, calcule le montant et
cumule le total. Un code absent du tarif est rejeté. Sortie attendue :

```
P100 ECROU M6     010 x   1.20 =      12.00
P300 VIS 6X40     004 x   4.50 =      18.00
P999 *** produit inconnu ***
P200 BOULON M8    002 x  12.90 =      25.80
P600 CHEVILLE 8MM 100 x   0.80 =      80.00
Total commande  :     135.80
Lignes rejetees : 01
```

## Partie 1 — Maintenance : trois défauts

```bash
just ex-run 05
```

1. Avant de chercher, fais sur papier l'inventaire des deux tables : combien
   d'entrées dans les données, combien dans le dessin, quelle taille pour
   chacune. Vérifie que chaque littéral du tarif respecte le dessin
   (4 + 12 + 5).
2. Compare la sortie avec l'attendu. Il y a **trois** défauts indépendants.
   Corrige-les un par un en relançant à chaque fois ; à chaque étape la sortie
   change et te met sur la piste du suivant.
3. Pour chacun, note : la ligne, ce que le programme faisait réellement, et la
   section de la leçon concernée.

Indice si tu bloques : après le premier lancement, demande-toi pourquoi la
ligne `P100` est trouvée et pas la ligne `P300`, alors que les deux produits
sont dans le tarif. Où se trouve chacun dans la table ?

## Partie 2 — Évolution : recherche dichotomique

Copie ton `sujet.cob` corrigé en `dicho.cob` et remplace la recherche
séquentielle par un `SEARCH ALL`.

1. Fais d'abord **uniquement** les modifications de syntaxe (clé déclarée,
   `SEARCH ALL`, plus de `SET`), sans toucher aux données, et lance :

   ```bash
   just ex-run 05 dicho
   ```

   Note précisément ce qui est faux. Y a-t-il un message d'erreur ?

2. Corrige ce qu'il faut pour retrouver la sortie attendue.

Question : si demain quelqu'un ajoute un produit `P250` à la fin du tarif,
que faut-il vérifier, et que se passe-t-il s'il ne le fait pas ?

## Partie 3 — Quiz : tables et bornes

`tables.cob` contient 10 questions. **Sans le lancer**, écris ce que tu
attends pour chacune. Ensuite :

```bash
just ex-run 05 tables
```

Puis relance-le avec le contrôle des bornes, et observe où il s'arrête :

```bash
just cobc_opts="-Wall -debug" ex-run 05 tables
```

## Bonus — Un barème par tranches

Dans `dicho.cob`, ajoute une seconde table, le barème de remise par quantité :

| À partir de | Remise |
| ----------- | ------ |
| 100         | 10 %   |
| 50          | 5 %    |
| 0           | 0 %    |

Applique la remise à chaque ligne en cherchant la tranche avec un `SEARCH`
séquentiel et une condition `>=`. Pourquoi les tranches doivent-elles être
rangées de la plus haute à la plus basse ? Pourquoi `SEARCH ALL` ne convient-il
pas ici ?

Résultat attendu : la ligne `P600` passe à 72,00 et le total à 127,80.

## Rendu

`sujet.cob` corrigé, `dicho.cob`, tes notes sur les trois défauts, ta réponse
à la question de la partie 2, et tes prédictions du quiz **telles que tu les
avais écrites avant de lancer**, avec les écarts. Corrigé dans `solution.md`.
