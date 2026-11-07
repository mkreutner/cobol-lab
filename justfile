# justfile — cobol-lab
# Pilote le conteneur GnuCOBOL (docker-compose.yml) depuis l'hôte.
#
#   just              → liste des recettes
#   just setup        → génère .env à partir de .env.sample (UID/GID/USERNAME locaux)
#   just build        → construit l'image
#   just run hello    → compile src/hello.cob puis exécute bin/hello
#   just shell        → bash dans le conteneur
#
# Les sources COBOL vivent dans sources/app/src/, les binaires dans sources/app/bin/
# (sources/app est monté dans le conteneur comme répertoire de travail).

set dotenv-load := true
set shell := ["bash", "-euo", "pipefail", "-c"]

# ---------------------------------------------------------------------------
# Variables (surchargeables : `just format=fixed compile hello`)
# ---------------------------------------------------------------------------

compose   := "docker compose"
service   := "app"
src       := "src"
bin       := "bin"
format    := "free"                     # free | fixed
cobc_std  := "default"                  # default | cobol2014 | ibm | mf | ...
cobc_opts := "-Wall"                    # options supplémentaires passées à cobc

format_flag := if format == "free" { "-free" } else { "" }

# Exécute une commande dans un conteneur jetable (pas besoin de `just up`)
_run := compose + " run --rm " + service

# ---------------------------------------------------------------------------
# Par défaut : lister les recettes
# ---------------------------------------------------------------------------

default:
    @just --list --unsorted

# ---------------------------------------------------------------------------
# Environnement
# ---------------------------------------------------------------------------

# Génère .env à partir de .env.sample avec l'UID/GID/USERNAME de l'utilisateur courant
setup:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ -f .env ]; then
        echo ".env existe déjà — rien à faire (supprime-le pour le régénérer)."
        exit 0
    fi
    sed -e "s/^UID=.*/UID=$(id -u)/" \
        -e "s/^GID=.*/GID=$(id -g)/" \
        -e "s/^USERNAME=.*/USERNAME=$(id -un)/" \
        .env.sample > .env
    mkdir -p sources/app/src sources/app/bin
    echo ".env généré :"
    cat .env

# Construit l'image Docker
build: _need-env
    {{compose}} build

# Reconstruit l'image sans cache
rebuild: _need-env
    {{compose}} build --no-cache

# Démarre le conteneur en arrière-plan (optionnel : les recettes utilisent des conteneurs jetables)
up: _need-env
    {{compose}} up -d

# Arrête et supprime le conteneur
down:
    {{compose}} down

# Ouvre un shell bash dans le conteneur
shell: _need-env
    {{_run}} bash

# Exécute une commande arbitraire dans le conteneur : `just exec cobc --info`
exec +cmd: _need-env
    {{_run}} {{cmd}}

# Affiche la version et la configuration de GnuCOBOL
version: _need-env
    {{_run}} cobc --version

# ---------------------------------------------------------------------------
# Compilation / exécution
# ---------------------------------------------------------------------------

# Compile src/<prog>.cob en exécutable bin/<prog>
compile prog: _need-env
    @mkdir -p sources/app/{{bin}}
    {{_run}} cobc -x {{format_flag}} -std={{cobc_std}} {{cobc_opts}} \
        -o {{bin}}/{{prog}} {{src}}/{{prog}}.cob

# Compile puis exécute bin/<prog> (arguments optionnels passés au programme)
run prog *args: (compile prog)
    {{_run}} ./{{bin}}/{{prog}} {{args}}

# Exécute bin/<prog> sans recompiler
exec-bin prog *args: _need-env
    {{_run}} ./{{bin}}/{{prog}} {{args}}

# Vérifie la syntaxe sans produire de binaire
check prog: _need-env
    {{_run}} cobc -fsyntax-only {{format_flag}} -std={{cobc_std}} {{cobc_opts}} \
        {{src}}/{{prog}}.cob

# Compile tous les src/*.cob
compile-all: _need-env
    #!/usr/bin/env bash
    set -euo pipefail
    shopt -s nullglob
    for f in sources/app/{{src}}/*.cob; do
        p=$(basename "$f" .cob)
        echo "== $p"
        just format={{format}} cobc_std={{cobc_std}} cobc_opts="{{cobc_opts}}" compile "$p"
    done

# Liste les programmes sources et les binaires présents
list:
    @echo "Sources (sources/app/{{src}}) :"; ls -1 sources/app/{{src}}/*.cob 2>/dev/null | xargs -rn1 basename || true
    @echo; echo "Binaires (sources/app/{{bin}}) :"; ls -1 sources/app/{{bin}} 2>/dev/null || true

# Crée un nouveau programme src/<name>.cob à partir du squelette
new name:
    #!/usr/bin/env bash
    set -euo pipefail
    target="sources/app/{{src}}/{{name}}.cob"
    if [ -e "$target" ]; then echo "$target existe déjà."; exit 1; fi
    mkdir -p "$(dirname "$target")"
    prog_id=$(echo "{{name}}" | tr '[:lower:]_' '[:upper:]-')
    sed "s/@PROGRAM_ID@/$prog_id/g; s/@DATE@/$(date +%Y-%m-%d)/" sources/app/templates/program.cob > "$target"
    echo "Créé : $target"

# Supprime les binaires compilés
clean:
    rm -rf sources/app/{{bin}}/*

# ---------------------------------------------------------------------------
# Exercices (sources/app/exercices/NN_sujet/ : lecon.md, sujet.md, sujet.cob, solution.md)
# Les exercices sont compilés en FORMAT FIXE (cobc -fixed), comme du code legacy.
# `just ex-run 01` ou `just ex-run 01_hello` ; fichier alternatif : `just ex-run 01 libre`
# ---------------------------------------------------------------------------

ex_dir := "exercices"

# Liste les exercices disponibles
ex-list:
    @ls -1d sources/app/{{ex_dir}}/*/ 2>/dev/null | xargs -rn1 basename || echo "(aucun exercice)"

# Compile exercices/<ex>/<file>.cob (format fixe) → bin/<ex>_<file>
ex-compile ex file="sujet": _need-env
    #!/usr/bin/env bash
    set -euo pipefail
    dir=$(just _ex-dir "{{ex}}")
    mkdir -p sources/app/{{bin}}
    {{_run}} cobc -x -fixed -std={{cobc_std}} {{cobc_opts}} \
        -o {{bin}}/${dir}_{{file}} {{ex_dir}}/${dir}/{{file}}.cob

# Compile puis exécute exercices/<ex>/<file>.cob
ex-run ex file="sujet" *args: (ex-compile ex file)
    #!/usr/bin/env bash
    set -euo pipefail
    dir=$(just _ex-dir "{{ex}}")
    {{_run}} ./{{bin}}/${dir}_{{file}} {{args}}

# Vérifie la syntaxe de exercices/<ex>/<file>.cob sans produire de binaire
ex-check ex file="sujet": _need-env
    #!/usr/bin/env bash
    set -euo pipefail
    dir=$(just _ex-dir "{{ex}}")
    {{_run}} cobc -fsyntax-only -fixed -std={{cobc_std}} {{cobc_opts}} \
        {{ex_dir}}/${dir}/{{file}}.cob

# Résout "01" ou "01_hello" vers le nom du dossier d'exercice
_ex-dir ex:
    #!/usr/bin/env bash
    set -euo pipefail
    shopt -s nullglob
    matches=(sources/app/{{ex_dir}}/{{ex}}*/)
    if [ ${#matches[@]} -eq 0 ]; then echo "Aucun exercice ne correspond à '{{ex}}' (voir : just ex-list)" >&2; exit 1; fi
    if [ ${#matches[@]} -gt 1 ]; then echo "Plusieurs exercices correspondent à '{{ex}}' : ${matches[*]}" >&2; exit 1; fi
    basename "${matches[0]}"

# ---------------------------------------------------------------------------
# Interne
# ---------------------------------------------------------------------------

_need-env:
    @[ -f .env ] || { echo "Fichier .env manquant → lance d'abord : just setup"; exit 1; }
