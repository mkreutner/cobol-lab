# cobol-lab

Bac à sable COBOL : un conteneur Debian trixie avec **GnuCOBOL**, piloté depuis l'hôte
par un `justfile`. Rien n'est installé sur la machine hôte à part Docker et `just`.

## Prérequis

- Docker avec le plugin Compose v2 (`docker compose version`)
- [`just`](https://github.com/casey/just) — sur Debian/Ubuntu : `sudo apt install just`
  (ou `cargo install just`)

## Démarrage après un clone

```bash
git clone https://github.com/mkreutner/cobol-lab.git
cd cobol-lab

just setup        # génère .env avec ton UID/GID/USERNAME (pour que les fichiers créés
                  # dans le conteneur t'appartiennent sur l'hôte)
just build        # construit l'image (debian:trixie-slim + gnucobol)
just run hello    # compile sources/app/src/hello.cob et exécute le binaire
```

`just` seul liste toutes les recettes disponibles.

## Organisation

```
cobol-lab/
├── justfile                 # recettes : setup, build, compile, run, shell, …
├── docker-compose.yml       # service "app" (conteneur cobapp)
├── Dockerfile.dev           # image GnuCOBOL
├── .env.sample              # modèle de .env (copié par `just setup`)
└── sources/app/             # monté dans le conteneur = répertoire de travail
    ├── src/                 # programmes COBOL (*.cob)
    ├── bin/                 # exécutables compilés (ignorés par git)
    └── templates/           # squelette utilisé par `just new`
```

Dans le conteneur, `sources/app` est monté sous `/home/<USERNAME>/app` ; les chemins
`src/…` et `bin/…` sont donc les mêmes des deux côtés.

## Recettes principales

| Commande                    | Effet                                                        |
| --------------------------- | ------------------------------------------------------------ |
| `just setup`                | crée `.env` à partir de `.env.sample`                        |
| `just build` / `rebuild`    | construit l'image (avec / sans cache)                        |
| `just compile <prog>`       | `cobc -x` sur `src/<prog>.cob` → `bin/<prog>`                |
| `just run <prog> [args…]`   | compile puis exécute                                         |
| `just exec-bin <prog>`      | exécute sans recompiler                                      |
| `just check <prog>`         | vérification de syntaxe seule (`-fsyntax-only`)              |
| `just compile-all`          | compile tous les `src/*.cob`                                 |
| `just new <nom>`            | crée `src/<nom>.cob` depuis le squelette                     |
| `just shell`                | bash dans le conteneur (pour `cobc`, `cobcrun`, etc. à la main) |
| `just exec <cmd…>`          | commande arbitraire dans le conteneur, ex. `just exec cobc --info` |
| `just version`              | version et configuration de GnuCOBOL                         |
| `just list`                 | sources et binaires présents                                 |
| `just clean`                | supprime `bin/*`                                             |
| `just up` / `down`          | conteneur persistant en arrière-plan (optionnel)             |

Les recettes de compilation utilisent des conteneurs jetables (`docker compose run --rm`),
il n'est donc pas nécessaire de faire `just up` avant.

### Options de compilation

Variables surchargeables sur la ligne de commande :

```bash
just format=fixed compile vieux_programme   # format fixe (colonnes 7-72) au lieu de -free
just cobc_std=ibm compile prog              # dialecte : default, cobol2014, ibm, mf, …
just cobc_opts="-Wall -O2 -debug" run prog  # options supplémentaires pour cobc
```

Par défaut : format libre, `-std=default`, `-Wall`.

## Écrire un programme

```bash
just new calcul_tva        # → sources/app/src/calcul_tva.cob (PROGRAM-ID. CALCUL-TVA.)
$EDITOR sources/app/src/calcul_tva.cob
just run calcul_tva
```

Les sources sont en **format libre** (`-free`) : pas de contrainte de colonnes, les
commentaires s'écrivent avec `*>`. Pour du code historique en format fixe, passe
`format=fixed`.

## Exercices (formation)

Chaque exercice est un dossier `sources/app/exercices/NN_sujet/` :

| Fichier       | Rôle                                                       |
| ------------- | ---------------------------------------------------------- |
| `lecon.md`    | les connaissances nécessaires pour faire le sujet          |
| `sujet.md`    | l'énoncé                                                   |
| `sujet.cob`   | le programme de départ (à corriger / compléter)            |
| `solution.md` | le corrigé commenté — à ouvrir après avoir essayé          |

Les exercices sont compilés en **format fixe** (`cobc -fixed`), comme le code
legacy que l'on rencontre en maintenance ; `src/` reste en format libre.

```bash
just ex-list                 # exercices disponibles
just ex-compile 01           # compile exercices/01_hello/sujet.cob → bin/01_hello_sujet
just ex-run 01               # compile puis exécute
just ex-check 01             # syntaxe seule
just ex-run 01 libre         # autre fichier du dossier : exercices/01_hello/libre.cob
```

`01` ou `01_hello` sont acceptés indifféremment.

Programme : 01 anatomie / format fixe · 02 PICTURE et structures · 03 arithmétique
et édition · 04 contrôle (IF, EVALUATE, PERFORM, niveaux 88) · 05 tables (OCCURS,
SEARCH) · 06 fichiers séquentiels · 07 état batch avec ruptures · 08 fichiers
indexés · 09 sous-programmes (CALL, COPY) · 10 lecture de code legacy.

## Dépannage

- **`Fichier .env manquant`** → `just setup`.
- **Fichiers créés dans le conteneur appartenant à root** → vérifie que `UID`/`GID`
  dans `.env` correspondent à `id -u` / `id -g`, puis `just rebuild`.
- **Changement de `.env`** (`USERNAME`, `UID`…) → l'utilisateur est créé au build :
  `just rebuild`.
- **`cobc` introuvable après modification du Dockerfile** → `just rebuild`.
