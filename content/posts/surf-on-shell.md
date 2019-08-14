---
title: "Surf on Shell"
date: 2019-08-13T16:53:16+02:00
draft: false
toc: false
author:
  name: dauliac
images:
tags:
  - shell
  - cli
  - ricing
  - tools
  - dotfiles
---

Je passe un temps infini à gérer mes configurations système (le tout en cli). Non pas qu'elles en nécesite le besoin (un fichier ça n'a pas de besoins).
Il s'agirait plutôt d'une douce névrose qui s'installe petit à petit, jusqu'à me ronger complètement. Je me transforme en mamie gâteau qui au lieu d'arroser ses plantes configure ses [dotfiles](https://github.com/Dauliac/dotfiles) car: "Il n'y a qu'eux qui ~~m'~~ l'aiment vraiment".

Bref ! On va voir comment surfer sur le shell comme un ~~hipster~~ **ricer**.

{{< image src="/img/meme/surf_dog.gif" alt="dog surfin'" position="center" style="width: 30em;" >}}


---

## Mais dit moi Jamy c'est quoi un ricer ?

Euh bien le ricing d'après l'internaute [@mooseV2](https://www.reddit.com/r/unixporn/comments/3iy3wd/stupid_question_what_is_ricing/):

> Ricing comes from the car terminology "ricing" or "RICEing".
> In the car world, RICE stands for Race Inspired Cosmetic Enhancement.
> When you put a scoop on your car (that doesn't lead to a cold air intake) or a big spoiler (which won't make a difference), you're ricing. The idea is to increase its perceived performance through cosmetics.

Je ne sais pas si sa définition est la bonne, mais on s'en contentera. Et un ricer c'est par extension quelqu'un qui fait du ricing (cqfd).

Nous pouvons donc continuer.

## CLI et compagnie

Le shell c'est de [la ligne de commande](https://en.wikipedia.org/wiki/Command-line_interface) éventuellement du [ncurse](https://en.wikipedia.org/wiki/Ncurses) mais surtout jamais [d'interfaces graphiques](https://en.wikipedia.org/wiki/Graphical_user_interface).

> Mais c'est moche et austère le cli moi je veux de vrais outils.

Alors oui mais non.

Déja [c'est pas moche](https://www.reddit.com/r/unixporn/search/?q=rice&restrict_sr=1) !

Et en plus on a pas toujours accès à une session graphique ! imaginez votre sys-admin est mort, vous ~~êtes coincé dans la jungle~~ n'avez pas d'outil de journalisation des logs (mauvaise idée) et votre prod vient de tomber.

Bah va falloir aller sur la machine et tripatouiller dans le cambouis.

Sans parler du grain de temps dû à la personnalisation et combinaison d'outils très modulaires (*la [sortie standard](https://fr.wikipedia.org/wiki/Flux_standard) ça marche bien !*)

**NLDR:** Je n'explore pas les options de ces outils [#RTFM](https://lmqt.fyi/?q=rtfm). Le but est plus de présenter un mix des outils que j'utilise affin de les partager.

Donc voici une liste d'outil permettant kiffer sa race dans ce cas précis.

## Les outils

### 1. "ag" the silversearcher
Pour le premier je ne me mouille pas trop, voici `ag`.

C'est un outil permettant tout simplement de trouver une string dans un système de fichiers.

[code source](https://github.com/ggreer/the_silver_searcher)

Il est:
- rapide (plus que [ack](https://github.com/beyondgrep/ack3/) en tout cas)
- en couleur (j'arrive à voir de 400 à 800nm à peu près)
- intuitif
- il respecte le principe [kiss](https://en.wikipedia.org/wiki/KISS_principle)

**Exemple:**
```bash
$ ag password

mysupersecretapp/secrets
12:ADMIN_PASSWORD=guest
```

Voilà !

{{< image src="/img/meme/password_guest_archer.gif" alt="password is guest" position="left" style="width: 30em;" >}}

**TIPS:** Voici comment faire pareil avec find et grep.
C'est un peu plus lent mais suffisant dans la majorité des cas
```bash
$ grep -nri password
mysupersecretapp/secrets:12:ADMIN_PASSWORD=guest
```

### 2. "fd" 50% shorter than find
Une alternative pour "brainless" de find.
`fd` permet tout simplement de trouver un fichier dans un système de fichier.

Tu appelles le binaire ("BINNAAAAAAAAAAIRE !"), ta string et tu appuies sur entrée.
```bash
fd sex /
/home/dauliac/Videos/sextape.mp4
/home/dauliac/Videos/sextape_2.mp4
/home/dauliac/Videos/sextape-4.mp4
```
Et hop vous pouvez retrouver vos fichiers mal nommés/perdus !

[code source](https://github.com/sharkdp/fd)

La version find:

```bash
find /home/username/ -name "sex.*"
```

### 3. "fzf" The fuzzy finder
Difficile à décrire. En gros on pipe une liste de ligne au binaire et il affiche une interface permettant de choisir dans cette liste.
La grosse plus-value se trouve dans l'ordre d'affichage qui se met à jour à chaque saisie et trie par pertinence en ordre décroissant.

[code source](https://github.com/junegunn/fzf)

{{< image src="/img/screenshot/fzf_history.png" alt="fzf history" position="left" style="width: 50em;" >}}
*Je n'ai qu'à faire la macro `CTRL+R` comme d'habitude pour lire mon historique.*

Il peut donc servir à trancher dans tout type de liste à n'importe quel moment:
- Dans l'historique bash.
- Pour faire un `kill`.
- Saisir un fichier trouvé grâce à `fd`.
- Ouvrir un fichier contenant une string trouvée avec `ag`.
- Être combiné avec `vim`.
- Containers docker, pods kubernetes, machines virtuelles.

Mais vu que je suis sympa je vous offre une petite liste de mes tips `fzf`

#### `git branch`
Ajoutez cela dans votre `~/.bashrc`
```bash
function gfb {
    # git checkout $(git branch | fzf | awk '{print $2}')
    local tags branches target
      tags=$(
    git tag | awk '{print "\x1b[31;1mtag\x1b[m\t" $1}') || return
      branches=$(
    git branch --all | grep -v HEAD |
    sed "s/.* //" | sed "s#remotes/[^/]*/##" |
    sort -u | awk '{print "\x1b[34;1mbranch\x1b[m\t" $1}') || return
      target=$(
    (echo "$tags"; echo "$branches") |
        fzf --no-hscroll --no-multi --delimiter="\t" -n 2 \
            --ansi --preview="git log -200 --pretty=format:%s $(echo {+2..} |  sed 's/$/../' )" ) || return
      git checkout $(echo "$target" | awk '{print $2}')
}
```
Et vous aurez droit en tapant `gfb` à un joli menu pour changer de branche git:

{{< image src="/img/screenshot/gfb.png" alt="git branch fzf" position="left" style="width: 50em;" >}}

#### `gitignore`
Ajoutez dans votre `$PATH` ce fichier [`gitignore`](https://gist.github.com/phha/cb4f4bb07519dc494609792fb918e167) et rendez le executable.

```bash
mkdir -p ~/.local/bin/
curl -o gitignore ~/.local/bin/gitignore -L -O https://gist.github.com/phha/cb4f4bb07519dc494609792fb918e167
chmod +x ~/.local/bin/gitignore
```

maintenant quand vous lancez `gitignore` il vous permettra de choisir grâce à une [api](https://www.gitignore.io/api/`) quel est le `.gitignore` adapté pour votre projet.

{{< image src="/img/screenshot/fzf_gitignore.png" alt="gitignore fzf" position="left" style="width: 50em;" >}}

---
Liste d'autres outils cools:
[`bat`](https://github.com/sharkdp/bat)
[`ripgrep`](https://github.com/BurntSushi/ripgrep)
[`chezmoi`](https://github.com/twpayne/chezmoi)
[`hyperfine`](https://github.com/sharkdp/hyperfine)

---

Je ferai sûrement d'autres articles sur mes configurations afin de partager mes outils de travail.
N'hésitez pas à aller voir mes [dotfiles](https://github.com/Dauliac/dotfiles).


**Bye !**

{{< image src="https://media.giphy.com/media/jyPgrG8iqMu6Da7RWb/giphy.gif" alt="gitignore fzf" position="left" style="width: 30em;" >}}
