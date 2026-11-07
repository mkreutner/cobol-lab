# Exercice 01 — Hello, en format fixe

Prérequis : `lecon.md` (10 minutes de lecture).

## Objectifs

- Reconnaître les 4 DIVISION et savoir lesquelles sont obligatoires.
- Lire du **format fixe** (colonnes) sans se faire piéger.
- Savoir où un point `.` est obligatoire, et où il est dangereux.
- Utiliser `DISPLAY`, `ACCEPT`, `STOP RUN`.

## Partie 1 — Maintenance : faire compiler `sujet.cob`

`sujet.cob` est un programme en format fixe qui **ne compile pas**. Il contient
3 erreurs typiques de ce que l'on trouve après une édition hâtive dans du code
ancien. Travaille comme en maintenance : on touche le minimum.

1. Compile-le tel quel et lis les messages :

   ```bash
   just ex-compile 01_hello
   ```

2. Corrige les 3 erreurs **sans réécrire le programme**. Pour chacune, note :
   la ligne, la colonne en cause, et pourquoi le compilateur n'était pas content.
   Attention : un des messages d'erreur ne pointe pas sur la ligne fautive.

3. Vérifie que ça compile et que les trois `DISPLAY` s'affichent :

   ```bash
   just ex-run 01_hello
   ```

## Partie 2 — Évolution : saluer l'utilisateur

Toujours dans `sujet.cob`, ajoute :

- une variable `WS-PRENOM` (30 caractères) et une demande de saisie :
  afficher `Votre prenom ? ` (sans saut de ligne), puis `ACCEPT` ;
- un `DISPLAY` qui salue : `Bonjour, Michel !` (sans les espaces de fin de zone) ;
- l'affichage de la date du jour au format `JJ/MM/AAAA`.

Reste en format fixe : respecte les zones A et B et la colonne 72.

```bash
just ex-run 01_hello
```

## Bonus — Format libre

Crée `libre.cob` dans ce dossier : le même programme converti en format libre,
avec la directive `>>SOURCE FORMAT IS FREE` en première ligne et des commentaires
`*>`. Compile-le avec :

```bash
just ex-compile 01_hello libre
just ex-run 01_hello libre
```

## Rendu

Montre-moi ton `sujet.cob` (et `libre.cob` si tu as fait le bonus) avec tes notes
sur les 3 erreurs. Le corrigé commenté est dans `solution.md` — ne l'ouvre
qu'après avoir essayé.
