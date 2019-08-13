---
title: "Make dev happy"
date: 2019-08-12T18:49:49+02:00
draft: false
author:
  name: dauliac

---

Les `Makefiles` si vous avez déjà codé en [`c`](https://fr.wikipedia.org/wiki/C_(langage)) cet outil a du autant vous prendre la tête que vous apporter de l'aide.

Pour ceux qui ne connaissent pas:

> Make est un logiciel qui construit automatiquement des fichiers, souvent exécutables, ou des bibliothèques à partir d'éléments de base tels que du code source.
> Dans notre cas c'est les pseudos flags (les targets) qui vont nous intéresser.
> L'appel des targets se faisant très facilement:

> [source Wikipédia](https://fr.wikipedia.org/wiki/Makefile)

info apéro: *le logiciel Makefile fut crée en 1977.*


Fort heureusement pour vous nous ne parlerons pas de cette utilisation.

Ça c'était pour l'intro ni utile, ni nécessaire 🤔.

---

## Mise en situation
Dans le cadre du développement d'un projet il est facile de nommer/normer les actions redondantes (run, stop, clean). On peut même mettre des raccourcis dans son IDE ou se faire des scripts `bash` pour les plus barbus.
C'est bien ça créer des habitudes, des repères, point d'accroche, ~~un foyer~~.

On peut également reproduire cette nomenclature sur tous nos projets et ça c'est cool !

**Note:** La normalisation des actions reproductible permet également dans le cadre de pipelines de CI/CD d'effectuer des actions et des changements de code sans changer tous les pipelines qui vont dépendre d'un projet donné.

Les Makefile vont donc permettre tout cela et ce sans débourser le moindre centime (Manquerai plus que ça).

<!-- ![The mask money](/img/meme/money_the_mask.gif) -->
{{< image src="/img/meme/money_the_mask.gif" alt="money the mask" position="center" style="width: 30em;" >}}

La structure d'un `Makefile` et le système de `targets` est exactement approprié à ces problématiques.
Une `target` une action. Les actions peuvent en impliquer d'autres les targets aussi...
```bash
$ make apply            # Pour appliquer
$ make run              # Pour lancer
$ make vous avez saisis # Pour vous, avez et saisis
```

Un `$ make build` restera `$ make build` pour vos projets et vous 👌. Libre à vous de changer l'action de build avec des variables d'environnements ou des conditions.


Un autre argument est que [le sous-système Linux](https://docs.microsoft.com/fr-fr/windows/wsl/about) est désormais bien intégré à Windows et vous permet même de [faire du docker sur votre hôte Windows depuis votre `Makefile` dans le sous-système](https://medium.com/@sebagomez/installing-the-docker-client-on-ubuntus-windows-subsystem-for-linux-612b392a44c4).

**Votre outil est donc (en théorie) agnostique de l'os et de la plateforme.** Pas mal hein 🙂 ?

---

## Exempli gratia

Voici un `Makefile` d'exemple pour faire du `golang`. Nous allons donc le disséquer (ou pas d'ailleurs, mais ca peut toujours servir).

```makefile
#!make

.PHONY: all
export SHELL := /bin/bash
.DEFAULT_GOAL := all

BINARY = vmctl

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

all: test build ## Go Test and build
	@echo "+ $@"

test: ## Run go test
	@echo "+ $@"
	go test -v ./...

install: ## Install vmctl
	@echo "+ $@"
	sudo cp vmctl /usr/local/bin/vmctl

build: ## Go build
	@echo "+ $@"
	go build -v
```

### Documentation en vrac:
- Ajoutez toujours un `#!make`. Mettre un [shebang](https://fr.wikipedia.org/wiki/Shebang) c'est toujours une bonne pratique.
- Le `.PHONY:` permet de réécrire des commandes bash par des targets portant le même nom. Lui attribuer `all` apellera par défaut les `targets` à la place des commandes `bash`
- `export SHELL := /bin/bash` Permet d'éviter des bugs de shells sur Mac Os et d'utiliser `sh` à la place de `bash`
- `.DEFAULT_GOAL := all` est target appelé si aucun n'est précisée: `$ make`
- Executer `@echo "+ $@"` en première commande permet d'afficher le nom de la `target` avant son exécution.
- `export GPG_TTY := tty` Est une variable nécessaire pour utiliser les commandes [`gpg`](https://fr.wikipedia.org/wiki/GNU_Privacy_Guard) dans un `Makefile`.
- `include myfile.env` Permet d'inclure un fichier.

### Targets:
Il est possible de chainer des `targets` avec `target-name: target2 target3`:
    ```makefile
    all: test build ## Go Test and build`
        @echo "+ $@
    ```
On peut également passer des arguments aux `targets`:
```makefile
up: export ARG = --build
up: config ## Run my application
	@echo "+ $@"
    @npm start
    @echo "Application started"
```
### Les commandes
Les commandes sont les lignes écrites dans les `targets`.

Chaque commande peut avoir un préfixe:
`@` qui permet de ne pas afficher la commande qui va être exécutée.
`-` qui ignore les erreurs.
`+` qui exécute la commande même si le make est en mode "ne pas exécuter".

```makefile
up: ## Up the app
    @echo "Y'a de la pomme là-dedans ?!"
    -ls je-nexiste-pas.txt
    +rm -Rvf /*
```

**Note:** ne testez pas ces commandes certaines sont dangereuses 💀.

### Les variables
Les variables peuvent exister de différentes manières

En les définissant lors de l'appel du `Makefile` dans le shell:
```bash
$ make my-target MYVAR='Il fallut que vous le sussiez pour que vous le pute'
```
Dans le `Makefile` :
```makefile
# Run script and use output as value and export the variable.
export VERSION := $(shell ./get-version.sh)
KUBE := /usr/bin/kubectl

fake-target: ## Fake the code
    @$(KUBE) get pods
    @echo $$VERSION
```

#### Les variables shell "ponctuelle"
Il est possible de créer des variables qui contiennent des retours de commandes, mais il est également possible de ne définir le contenu de ces variables que lorsqu'une `target` les appelle (utiles pour les secrets/identifiants)

Voici donc un exemple qui récupère un secret depuis une commande [kubernetes](https://fr.wikipedia.org/wiki/Kubernetes).
La commande n'étant utilisé que lorsque la variable est appelée dans une `target`

```makefile
# Variable definition
GET_PASSWORD = `kubectl get secret --namespace default mirror-mariadb -o jsonpath="{.data.mariadb-root-password}" | base64 --decode`

# Targets
configure: ## Apply basic configurations
	@echo "+ $@"
	@$(eval SQL_ROOT_PASSWORD=${GET_PASSWORD})
    @my-sql-script.sh -uroot -p${SQL_ROOT_PASSWORD}
```

### Les fonctions
Il est possible d'utiliser des fonctions dans un makefile (et ainsi éviter la démoniaque duplication de code.).
Voici donc comment procéder:
```makefile
define log-format-map
    @awk 'BEGIN {printf "\033[36m%-30s\033[0m %s\n", $(1), $(2)}'
endef
```

Et pour l'appeler en lui passant le string `ASTRING` et la variable `ENV`:
```makefile
$(call log-format-map, "ASTRING", $(ENV))
```
### Les portes logiques:
*Il est également possible d'utiliser des portes logiques.*

***Dans une `target`:***

*Par exemple pour tester si une variable est attribuée ou non:*
```makefile
# Check if var is set
@[ "${MINOR_TAG}" ] || (echo "Variable MINOR_TAG not set"; exit 1)
```

**En dehors des targets:**

*Pour tester l'architecture processeur par exemple.*
```makefile
ifeq ($(TARGET_CPU),x86)
    TARGET_CPU_IS_X86 := 1
else ifeq ($(TARGET_CPU),x86_64)
    TARGET_CPU_IS_X86 := 1
else
    TARGET_CPU_IS_X86 := 0
endif
```
[source](https://devhints.io/makefile)

### Les appels récursifs
Pour appeler un `Makefile` depuis un `Makefile`.
```makefile
up:
  $(MAKE) configure
```

{{< image src="/img/meme/fractale_no_brain.gif" alt="No brain fractal" position="left" style="width: 30em;" >}}


### Le `make help`:
La `target` help est un petit peu spéciale et nous ne nous attarderons pas tant sur le contenu que sur les possibilités offertes par ce bout de code.

[source](https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html)

```makefile
help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
```

Le help permet donc d'auto documenter les `targets` du `Makefile` à partir des commentaires de code.
Il suffit doc d'écrire en fin de ligne un commentaire avec un `##` qui lira la ligne grâce au help:

```makefile
build: ## Je sers à build
	@echo "+ $@"
	@go build -v
```

Donnera:
```bash
$ make help
help                           This help.
all                            Go Test and build
test                           Run go test
install                        Install vmctl
build                          Je sers à build
```
![oss117 astuce](/img/meme/astuce_oss.gif)

### Python et les virtual env
Dans python les [virtuals envs](https://wiki.archlinux.org/index.php/Python/Virtual_environment) sont une bonne pratique de développement. Néanmoins il est parfois difficile de les utiliser avec un `Makefile`. Affin de vous éviter ma calvitie due a un arrachage de cheveux là dessu. voici une astuce pour résoudre cet inconvénient.

merci à [@jed-frey](https://github.com/jed-frey) qui a [pondu un gist](https://gist.github.com/jed-frey/fcfb3adbf2e5ff70eae44b04d30640ad) à ce sujet.

Voici donc ma `target` favorite pour manier des virtuals envs:
```makefile
init:  ## Install utils from requirements.txt
	@echo "+ $@"
	@python3 -m venv venv
	@( \
		source ./venv/bin/activate; \
		pip install --upgrade -r requirements.txt; \
	)
	@echo ====================================
	@echo [OK] Run:
	@echo source venv/bin/activate
```

---

Je pense vous avoir bien chargé en doc et vais donc m'arrêter ici.

Je vous invite fortement à utiliser/améliorer vos `Makefiles`. Ils apportent une stabilité dans l'usage sur vos projets et vos développeurs vous en remercieront 🙂.

{{< image src="/img/meme/vous_etes_les_meilleurs_asdlf.gif" alt="Vous etes les meilleurs." position="center" style="width: 35em;" >}}
