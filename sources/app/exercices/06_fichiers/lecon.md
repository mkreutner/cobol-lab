# Leçon 06 — Fichiers séquentiels

Un programme COBOL de gestion typique lit un fichier enregistrement par
enregistrement, calcule, et écrit un ou plusieurs fichiers. Tout ce que tu as
vu jusqu'ici (dessins d'enregistrement, `MOVE`, conditions, boucles) sert à ça.
Un fichier se déclare en **trois endroits**, et c'est ce découpage qu'il faut
savoir retrouver dans un programme inconnu.

## 1. Les trois déclarations

```cobol
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT F-CLIENTS
               ASSIGN TO "exercices/06_fichiers/clients.dat"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-FS-CLIENTS.
      *
       DATA DIVISION.
       FILE SECTION.
       FD  F-CLIENTS.
       01  CLIENT-REC.
           05  CLI-ID              PIC 9(06).
           05  CLI-NOM             PIC X(20).
           ...
       WORKING-STORAGE SECTION.
       01  WS-FS-CLIENTS           PIC X(02).
```

| Où | Quoi | Rôle |
| -- | ---- | ---- |
| `SELECT` (FILE-CONTROL) | nom **logique** → fichier physique, organisation, zone de statut | le lien avec l'extérieur |
| `FD` (FILE SECTION) | le dessin de l'enregistrement | le tampon de lecture/écriture |
| `WORKING-STORAGE` | la zone `FILE STATUS`, les indicateurs de fin | le pilotage |

Le programme ne manipule que le nom logique (`F-CLIENTS`). Sur mainframe,
`ASSIGN TO CLIENTS` désigne un nom de DD que le JCL associe à un fichier réel
au moment de l'exécution : le même programme tourne sur n'importe quel fichier.
Ici, par simplicité, le chemin est écrit en dur, relatif au répertoire d'où
`just` lance le programme (`sources/app`).

### L'organisation

- `LINE SEQUENTIAL` : fichier **texte**, une ligne par enregistrement, terminée
  par un saut de ligne. C'est ce qu'on utilise sous Linux, lisible avec `cat`.
  Une ligne plus courte que le dessin est complétée par des espaces.
- `SEQUENTIAL` (le défaut) : enregistrements de **longueur fixe collés bout à
  bout**, sans séparateur. C'est le format mainframe classique ; il peut
  contenir du binaire (`COMP`, `COMP-3`).

### La zone d'enregistrement

Le niveau 01 sous la `FD` n'est pas une variable ordinaire : c'est le
**tampon** du fichier. Il contient le dernier enregistrement lu (ou celui que
l'on prépare à écrire), et son contenu n'a de sens qu'entre un `OPEN` et un
`CLOSE`, après une lecture réussie. Après une lecture en fin de fichier, il
contient encore l'enregistrement précédent : rien ne l'efface.

## 2. Les instructions

```cobol
           OPEN INPUT  F-CLIENTS          lecture
           OPEN OUTPUT F-SORTIE           ecriture (cree ou ECRASE le fichier)
           OPEN EXTEND F-JOURNAL          ecriture a la suite

           READ F-CLIENTS
               AT END
                   SET FIN-FICHIER TO TRUE
               NOT AT END
                   ADD 1 TO WS-NB-LUS
           END-READ

           WRITE SORTIE-REC

           CLOSE F-CLIENTS
```

À retenir, parce que c'est contre-intuitif : **on lit un fichier, on écrit un
enregistrement**. `READ` prend le nom de la `FD`, `WRITE` le nom du niveau 01.

Variantes courantes : `READ F-CLIENTS INTO WS-CLIENT` (lit puis copie dans une
zone de travail) et `WRITE SORTIE-REC FROM WS-LIGNE` (copie puis écrit).

## 3. La boucle de lecture

Le schéma canonique, dit de **lecture anticipée** : on lit une première fois
avant la boucle, et on relit à la fin de chaque tour.

```cobol
       0000-MAIN.
           PERFORM 1000-OUVRIR
           PERFORM 2000-LIRE
           PERFORM 3000-TRAITER UNTIL FIN-FICHIER
           PERFORM 9000-FERMER
           STOP RUN.
      *
       2000-LIRE.
           READ F-CLIENTS
               AT END
                   SET FIN-FICHIER TO TRUE
               NOT AT END
                   ADD 1 TO WS-NB-LUS
           END-READ.
      *
       3000-TRAITER.
           ... traitement de l'enregistrement courant ...
           PERFORM 2000-LIRE.
```

Ainsi `3000-TRAITER` n'est exécuté que si un enregistrement a réellement été
lu, y compris quand le fichier est vide.

Le défaut le plus répandu est l'inverse : **lire puis traiter sans regarder le
résultat de la lecture**.

```cobol
       1000-LIRE-TRAITER.
           READ F-CLIENTS
           ADD 1 TO WS-NB-LUS
           ... traitement ...
```

La dernière lecture échoue (fin de fichier), mais le traitement s'exécute
quand même sur le tampon, qui contient toujours le dernier enregistrement :
il est **traité deux fois**. Un enregistrement compté en trop et un total trop
élevé du montant de la dernière ligne sont la signature de ce défaut.

Variante plus sournoise : la lecture anticipée est bien là, mais la relecture
est placée **au début** du traitement au lieu de la fin. Le premier
enregistrement est lu puis aussitôt remplacé par le deuxième sans avoir été
traité, et le dernier est traité deux fois. Le nombre d'enregistrements
« lus » est alors exact, ce qui rend le défaut difficile à voir : seuls le
contenu et les totaux sont faux.

## 4. FILE STATUS

Chaque opération sur un fichier range un code à deux caractères dans la zone
déclarée par `FILE STATUS`.

| Code | Signification |
| ---- | ------------- |
| `00` | opération réussie |
| `10` | fin de fichier (plus rien à lire) |
| `30` | erreur d'entrée-sortie permanente |
| `35` | `OPEN` : le fichier n'existe pas |
| `37` | `OPEN` : mode d'ouverture impossible pour ce fichier |
| `39` | `OPEN` : le fichier ne correspond pas à sa description |
| `41` | `OPEN` d'un fichier déjà ouvert |
| `42` | `CLOSE` d'un fichier qui n'est pas ouvert |
| `46` | `READ` alors que la fin de fichier a déjà été signalée |
| `47` | `READ` sur un fichier non ouvert en lecture |
| `48` | `WRITE` sur un fichier non ouvert en écriture |

Le premier caractère donne la famille : `0` succès, `1` fin de fichier, `3`
erreur permanente, `4` erreur de logique du programme.

Le point essentiel :

- **sans** clause `FILE STATUS`, une erreur arrête le programme avec un message
  (`libcob: error: file does not exist (status = 35)`) ;
- **avec** `FILE STATUS`, le programme **continue comme si de rien n'était** :
  c'est à lui de tester la zone.

Déclarer le statut sans le tester est donc pire que ne pas le déclarer. Un
`OPEN OUTPUT` qui échoue en silence, suivi de `WRITE` qui échouent tous en
silence (statut `48`), donne un traitement « terminé normalement » dont le
fichier de sortie n'existe pas. À faire après
chaque `OPEN`, au minimum :

```cobol
           OPEN INPUT F-CLIENTS
           IF WS-FS-CLIENTS NOT = "00"
               DISPLAY "ERREUR ouverture clients, statut " WS-FS-CLIENTS
               MOVE 8 TO RETURN-CODE
               STOP RUN
           END-IF
```

`RETURN-CODE` est le code retour du programme (le `$?` du shell, le « code
condition » d'une étape de JCL). Par convention : 0 normal, 4 avertissement,
8 erreur, 12 et plus erreur grave.

## 5. Ne pas faire confiance aux données

Un fichier vient de l'extérieur. Une zone déclarée `PIC 9` peut très bien
contenir des lettres ou des espaces : la lecture ne vérifie rien, elle copie
des octets dans le tampon. Calculer dessus donne un résultat faux (GnuCOBOL) ou
un arrêt brutal (abend S0C7 sur mainframe).

```cobol
           IF CLI-SOLDE IS NOT NUMERIC
               PERFORM 3100-REJETER
           ELSE
               ADD CLI-SOLDE TO WS-TOTAL
           END-IF
```

Le schéma habituel : contrôler chaque enregistrement, écrire les invalides dans
un **fichier de rejets** avec un motif, et afficher en fin de traitement les
compteurs (lus, traités, rejetés). Ces compteurs sont le premier outil de
diagnostic : lus = traités + rejetés + ignorés, sinon il y a un défaut.

## 6. Écrire un fichier

```cobol
       FD  F-REJETS.
       01  REJET-REC.
           05  REJ-MOTIF           PIC X(16).
           05  REJ-DONNEES         PIC X(64).
```

```cobol
           MOVE "NON NUMERIQUE : " TO REJ-MOTIF
           MOVE CLIENT-REC         TO REJ-DONNEES
           WRITE REJET-REC
```

On alimente **toutes** les zones du tampon avant le `WRITE` : ce qui n'a pas
été renseigné contient ce qu'il y avait avant. Une zone remplie seulement
« quand la condition est vraie » garde la valeur de la ligne précédente dans
tous les autres cas. Le réflexe : `MOVE SPACES TO REJET-REC` en tête du
paragraphe d'écriture, puis les `MOVE` zone par zone. En `LINE SEQUENTIAL`,
les espaces de fin de ligne ne sont pas écrits.

Ne pas oublier le `CLOSE` : c'est lui qui garantit que les dernières écritures
arrivent sur le disque.
