# Exercice 04 — Un barème de remise à la logique défaillante

Prérequis : `lecon.md`.

## Objectifs

- Lire du code ancien : une phrase par instruction, `IF` sans `END-IF`,
  `NOT <`, conditions abrégées.
- Diagnostiquer trois défauts de logique qui compilent sans erreur.
- Moderniser avec niveaux 88, `EVALUATE` et `END-IF`.
- Prévoir le comportement des boucles `PERFORM`.

## Les règles de gestion

`sujet.cob` simule des commandes de 25, 50, 75, 100 et 125 articles à 12,00 €
pour trois clients, de statut `A` (actif), `S` (suspendu) et `C` (clos).

| Règle | |
| ----- | - |
| R1 | Un client clos ne peut pas commander. Tout autre statut que A ou S est refusé. |
| R2 | Remise selon la quantité : moins de 50 → 0 %, de 50 à 99 → 5 %, 100 et plus → 10 %. |
| R3 | Un client suspendu peut commander mais n'a aucune remise ; la ligne porte la note `B` (remise bloquée). |

Sortie attendue :

```
Debut du traitement
Client A :
  Qte 025 remise 00 % net    300.00
  Qte 050 remise 05 % net    570.00
  Qte 075 remise 05 % net    855.00
  Qte 100 remise 10 % net  1,080.00
  Qte 125 remise 10 % net  1,350.00
Client S :
  Qte 025 remise 00 % net    300.00 B
  Qte 050 remise 00 % net    600.00 B
  Qte 075 remise 00 % net    900.00 B
  Qte 100 remise 00 % net  1,200.00 B
  Qte 125 remise 00 % net  1,500.00 B
Client C : commandes refusees
Fin du traitement
```

## Partie 1 — Maintenance : trois défauts de logique

Le programme compile sans erreur, et pourtant :

```bash
just ex-run 04
```

1. Compare la sortie avec l'attendu. Note tout ce qui diffère, y compris ce qui
   apparaît **après** `Fin du traitement`.
2. Trouve les trois défauts. Corrige-les un par un, en relançant à chaque fois,
   avec la modification la plus petite possible (c'est du code ancien : on ne
   le réécrit pas dans cette partie). Chaque correction tient en un mot, un
   caractère ou une ligne.
3. Pour chacun, note : la ligne, ce que le programme faisait réellement, et la
   règle de la leçon concernée.

Indice si tu bloques : un défaut par paragraphe.

## Partie 2 — Évolution : moderniser et ajouter le franco de port

Copie ton `sujet.cob` corrigé en `moderne.cob` et, dans cette copie :

- remplace les tests sur `WS-STATUT` et `WS-NOTE` par des **niveaux 88**
  (y compris un 88 qui regroupe les statuts autorisés à commander), et les
  `MOVE "A" TO WS-STATUT` par des `SET ... TO TRUE` ;
- remplace les trois `IF` de calcul de la remise par un seul `EVALUATE TRUE` ;
- supprime tous les points intermédiaires : `END-IF` partout, un seul point par
  paragraphe ;
- ajoute la règle **R4** : frais de port de 15,00 €, offerts si le net atteint
  1 000,00 €. Affiche-les sur chaque ligne :

  ```
    Qte 075 remise 05 % net    855.00 port 15.00
    Qte 100 remise 10 % net  1,080.00 port  0.00
  ```

```bash
just ex-run 04 moderne
```

Question : dans ton `EVALUATE`, que se passe-t-il si tu places le `WHEN` des
50 articles avant celui des 100 ?

## Partie 3 — Quiz : conditions et boucles

`boucles.cob` contient 13 questions. **Sans le lancer**, écris ce que tu
attends pour chacune (nombre de tours, valeur du compteur, vrai ou faux).
Ensuite :

```bash
just ex-run 04 boucles
```

## Rendu

`sujet.cob` corrigé, `moderne.cob`, tes notes sur les trois défauts, et tes
prédictions du quiz avec les écarts. Corrigé dans `solution.md`.
