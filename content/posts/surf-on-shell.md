---
title: "Surf on Shell"
date: 2019-08-13T16:53:16+02:00
draft: true
toc: false
author:
  name: dauliac
images:
tags:
  - shell
  - cli
  - ricing
  - tools
---

Je passe un temps infini à gérer mes configurations système. Non pas qu'elles en necessite le besoin (un fichier ca n'a pas de besoins).
Il s'agirait plutot d'une douce névrose qui s'installe petit à petit, jusqu'a me ronger complètement. Je me transforme en mamie gateau qui au lieu d'aroser ses plantes configure ses dotfiles car: "Il n'y a qu'eux qui ~~m'~~ l'aiment vraiment".

Bref ! On va voir comment surfer sur le shell comme un ~~hipster~~ **ricer**.

{{< image src="/img/meme/surf_dog.gif" alt="dog surfin'" position="center" style="width: 30em;" >}}


---

## Mais dis moi jamy c'est quoi un ricer ?

Euh bien le ricing d'après l'internaute [@mooseV2](https://www.reddit.com/r/unixporn/comments/3iy3wd/stupid_question_what_is_ricing/):

> Ricing comes from the car terminology "ricing" or "RICEing".
> In the car world, RICE stands for Race Inspired Cosmetic Enhancement.
> When you put a scoop on your car (that doesn't lead to a cold air intake) or a big spoiler (which won't make a difference), you're ricing. The idea is to increase its perceived performance through cosmetics.

Je ne sais pas si sa définition est la bonne mais on s'en contentera. Et un ricer c'est quelqu'un qui fait du ricing (cqfd).

Nous pouvons donc continuer.

## CLI et compagnie

Le shell c'est du [cli](https://en.wikipedia.org/wiki/Command-line_interface) éventuellement du [ncurse](https://en.wikipedia.org/wiki/Ncurses) mais surtout jamais de [GUI](https://en.wikipedia.org/wiki/Graphical_user_interface).

> Mais c'est moche et austère le cli moi je veux de vrais outils.

Alors oui mais non.

Déja [c'est pas moche](https://www.reddit.com/r/unixporn/search/?q=rice&restrict_sr=1) !

Et en plus on à pas toujours accès a un terminal! imaginez votre sys-admin est mort, vous ~~etes coincé dans la jungle~~ n'avez pas d'outil de journalisation des logs (mauvaise idée) et votre prod vient de tomber.

Bah va falloir aller sur la machine et tripatouiller dans le cambouï.

**NLDR:** Je n'explore pas les options de ces outils [#RTFM](https://lmqt.fyi/?q=rtfm). Le but est plus de présenter un mix des outils que j'utilise affin de les partager.

Donc voici une liste d'outil permettant kiffer sa race dans ce cas précis.

### #1 "ag" the silversearcher
Pour le premier je ne me mouille pas trop, voici `ag`.

C'est un outil permettant tout simplement de trouver une string dans un sysème de fichiers.

[code source](https://github.com/ggreer/the_silver_searcher)

Il est:
- rapide (plus que [ack](https://github.com/beyondgrep/ack3/) en tout cas)
- en couleur (j'arrive a voir de 400 à 800nm à peu près)
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

### #2 "fd" 50% shorter than find
Une alternative pour "brainless" de find.
`fd` permet tout simplement de trouver un fichier dans un système de fichier.

Tu apelles le binaire ("BINNAAAAAAAAAAIRE !"), ta string et tu appuies sur entrer.
```bash
fd sex /
/home/dauliac/Pictures/sextape.mp4
/home/dauliac/Pictures/sextape_2.mp4
/home/dauliac/Pictures/sextape-4.mp4
```
Et hop vous pouvez retrouvez vos fichiers mal només/perdus !

[code source](https://github.com/sharkdp/fd)

La version find:

```bash
find /home/username/ -name "sex.*"
```

### #3 "fzf" The fuzzy finder

[code source](https://github.com/junegunn/fzf)
