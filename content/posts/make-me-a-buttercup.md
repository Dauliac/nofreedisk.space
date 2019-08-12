---
title: "Make Me a Buttercup"
date: 2019-08-12T18:49:49+02:00
draft: true
---

# Make me a butter buttercup
Les makefiles si vous avez déja codé en [`c`](https://fr.wikipedia.org/wiki/C_(langage)) cet outil a du autant vous prendre la tête que vous apporter de l'aide.

Pour ceux qui ne connaissent pas:
> Make est un logiciel qui construit automatiquement des fichiers, souvent exécutables, ou des bibliothèques à partir d'éléments de base tels que du code source.
> Dans notre cas c'est les pseudos flags (les targets) qui vont nous interesser.
> L'appel des targets se faisant très facilement:

info: *Makefile fut crée en 1977.*

[source wikipédia](https://fr.wikipedia.org/wiki/Makefile)

Fort heuresement pour vous nous ne parlerons pas de cette utilisation.

Il est facile de normer les actions redondante d'un devellopement (run, stop, clean) et de les appelers avec les mêmes habitudes dans chacun de vos projets.
C'est une fonctionnalité d'IDE que l'on va donc retrouver celle des actions reproductibles només. La normalisation des actions permet également dans le cadre de pipelines de CI/CD d'effectuer des actions et des changement de code sans changer toutes les pipelines qui vont dépendre d'un projet donner.
`make build` restera `make build` pour tout vos projets :). Libre à vous de changer l'action de build avec des variables d'environement ou des conditions.

```bash
make apply
make run
make vous avez saisis
```
---

Un autre argument est que [le sous système linux](https://docs.microsoft.com/fr-fr/windows/wsl/about) est désormait bien intégré a windows et vous permet même de [faire du docker sur votre host windows depuis votre makefile dans le sous système](https://medium.com/@sebagomez/installing-the-docker-client-on-ubuntus-windows-subsystem-for-linux-612b392a44c4).

Votre outil est donc (en théorie) agnostic de l'os et de la platform. Pas mal hein ;) ?

## Exempli gratia

Voici un makefile d'exemple pour faire du golang. Nous allons donc le diséquer.

```make
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
- Le `.PHONY:` permet de de réecrire des commandes bash par des targets portant le même nom. L'instancier à `all` appelera par défault les targets ou a la place des commandes bash
- `BINARY = vmctl` C'est comme cela que l'on écrit les variables
- Ajouter un `@` devant une commande cache permet de ne pas l'afficher.
- `export SHELL := /bin/bash` Permet d'évider des bugs de shell sur macos et d'utiliser sh
- `.DEFAULT_GOAL := all` est la première target appelée.
- Executer `@echo "+ $@"` en première commande permet d'afficher le nom de la target avant sont execution.
- Il est possible de chainer des targets avec `target-name: target2 target3`:
    ```make
    all: test build ## Go Test and build`
        @echo "+ $@
    ```


### Le help
Le help est un petit peu spécial et nous ne nous attarderons pas tant que le contenu que sur les possibilités offertes par ce bout de code.

[source](https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html)

```make
help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
```

Le help permet donc d'auto documenter les targets du makefile a partir des commentaires de code.
Il suffit doc d'écrire en fin de ligne un commentaire avec un `##` qui lira la ligne grace au help.

```make
build: ## Je sers à build
	@echo "+ $@"
	@go build -v
```

Donera.
```bash
$ make help
help                           This help.
all                            Go Test and build
test                           Run go test
install                        Install vmctl
build                          Je sers à build
```

Je vous invite fortement a utiliser/améliorer vos makefiles. Is apportent une stabilité dans l'usage sur vos projet et vos devellopeurs vos en remercirons :)
