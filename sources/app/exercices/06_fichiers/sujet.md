# Exercice 06 — Lire un fichier clients, écrire une extraction

Prérequis : `lecon.md`.

## Objectifs

- Retrouver les trois déclarations d'un fichier (`SELECT`, `FD`, statut).
- Diagnostiquer les défauts classiques d'une boucle de lecture et d'une
  écriture.
- Tester le `FILE STATUS` et renvoyer un code retour.
- Contrôler les données lues et écrire un fichier de rejets.

## Le contexte

`clients.dat` contient 8 clients, un par ligne, au format de l'exercice 02 :

| Zone               | Positions | Contenu                                 |
| ------------------ | --------- | --------------------------------------- |
| Identifiant        | 1–6       | numérique                               |
| Nom                | 7–26      | texte                                   |
| Prénom             | 27–41     | texte                                   |
| Code postal        | 42–46     | numérique                               |
| Date de naissance  | 47–54     | AAAAMMJJ                                |
| Solde              | 55–63     | 7 entiers et 2 décimales, sans virgule  |
| Statut             | 64        | `A` actif, `S` suspendu, `C` clos       |

Regarde-le d'abord : `cat sources/app/exercices/06_fichiers/clients.dat`.

`sujet.cob` doit :

- afficher chaque client lu (identifiant, nom, solde, statut) ;
- écrire dans `actifs.txt` une ligne par client **non clos**, avec
  l'observation `SUSPENDU` pour les clients suspendus, et rien pour les autres ;
- afficher les compteurs et le total des soldes.

Résultat attendu à l'écran :

```
000427 DURAND                   1,250.75 A
000512 MARTIN                      35.00 A
000633 PETIT                    2,500.00 S
000748 BERNARD                      0.00 C
000801 ROBERT                     899.90 A
000915 RICHARD                  4,120.50 S
001024 MOREAU                      75.25 A
001137 SIMON                    1,560.00 A
Clients lus     : 0008
Lignes ecrites  : 0007
Total soldes    :      10,441.40
Rapport ecrit dans actifs.txt
```

et dans `sources/app/exercices/06_fichiers/actifs.txt` :

```
000427 DURAND                   1,250.75
000512 MARTIN                      35.00
000633 PETIT                    2,500.00 SUSPENDU
000801 ROBERT                     899.90
000915 RICHARD                  4,120.50 SUSPENDU
001024 MOREAU                      75.25
001137 SIMON                    1,560.00
```

Les chemins des fichiers sont relatifs à `sources/app`, le répertoire d'où
`just` lance les programmes.

## Partie 1 — Maintenance : trois défauts

```bash
just ex-run 06
cat sources/app/exercices/06_fichiers/actifs.txt
```

1. Compare l'écran avec l'attendu, ligne par ligne, y compris la première et
   la dernière. Le compteur « Clients lus » est-il un bon témoin ?
2. Le programme annonce avoir écrit le rapport. Vérifie.
3. Il y a **trois** défauts indépendants : un dans la boucle de lecture, un
   dans une déclaration de fichier, un dans l'écriture. Le troisième n'est
   visible qu'une fois le fichier de sortie obtenu. Corrige-les un par un.
4. Pour chacun, note la ligne, ce que le programme faisait réellement, et la
   section de la leçon concernée.

Indice pour le défaut du fichier de sortie : ajoute temporairement un
`DISPLAY` du `FILE STATUS` après l'`OPEN OUTPUT` et après le `WRITE`, et
cherche les codes dans le tableau de la leçon.

## Partie 2 — Évolution : statuts, contrôles et rejets

Copie ton `sujet.cob` corrigé en `controle.cob`, puis :

1. **Statuts** : après chaque `OPEN`, si le statut n'est pas `00`, affiche un
   message avec le nom du fichier et le code, mets `RETURN-CODE` à 8 et arrête.
   Teste en modifiant temporairement un nom de fichier, puis vérifie le code
   retour dans le shell.

2. **Données douteuses** : fais lire `clients-v2.dat` au lieu de `clients.dat`.
   Ce fichier contient 11 lignes, dont 3 anormales. Lance d'abord **sans rien
   ajouter** et regarde le total des soldes. Y a-t-il un message d'erreur ?

3. **Contrôles** : rejette tout enregistrement dont l'identifiant ou le solde
   n'est pas numérique, ou dont le statut n'est pas `A`, `S` ou `C`. Un rejet
   n'est ni affiché, ni compté dans le total, ni écrit dans `actifs.txt` : il
   est écrit dans un nouveau fichier `rejets.txt`, précédé d'un motif sur 16
   caractères (`SOLDE INVALIDE`, `ID INVALIDE`, `STATUT INCONNU`).

4. **Compteurs** : affiche en fin de traitement les lus, les écrits, les
   comptes clos et les rejets. Vérifie que lus = écrits + clos + rejets.

```bash
just ex-run 06 controle
```

Résultat attendu : 11 lus, 7 écrits, 1 clos, 3 rejets, total 10 441,40.

Question : la troisième ligne anormale est plus courte que les autres. Que
contient le tampon après sa lecture, et pourquoi est-elle rejetée ?

## Partie 3 — Quiz : prédire les FILE STATUS

`statuts.cob` enchaîne 14 opérations sur des fichiers et affiche le statut
après chacune. **Sans le lancer**, écris le code que tu attends pour Q1 à Q14
en t'aidant du tableau de la leçon. Ensuite :

```bash
just ex-run 06 statuts
```

## Rendu

`sujet.cob` corrigé, `controle.cob`, tes notes sur les trois défauts, ta
réponse à la question de la partie 2, et tes prédictions du quiz écrites avant
de lancer (même en un code par ligne), avec les écarts. Corrigé dans
`solution.md`.
