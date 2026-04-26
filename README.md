bkhack
======
*Abstract, heterogeneous full-stack application*

## How to develop

### Nix shell (courtesy of Tuong)

Start nix shell

```sh
nix-shell
```

Assume you've successfully entered nix shell

> After this, if you have never run opam initialization, you must run at least once, with `opam init`

Prepare

```sh
pnpm install
pnpm run init
```

Run dev server

```sh
pnpm dev
```

Voila!

### Nix shell from Docker (courtesy of Tung)

```sh
docker-compose up -d
docker exec -it bkhack bash
```

The rest, follows the *Nix shell* section.

## Try it out

Currently hosted at https://bkhack-2eb8c.web.app
