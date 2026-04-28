bkhack: Bách Khoa Hack
======================
`bkhack` is an abstract, heterogeneous full-stack application, currently deployed as a social news website at Ho Chi Minh University of Technology.

## Installation

1. Add the [ttb-hcmut/bkhack][bkhack-repo] repository:
   ```sh
   opam remote add bkhack git+https://github.com/ttb-hcmut/bkhack
   ```

2. Install the `bkhack` package:
   ```sh
   opam install bkhack
   ```

[bkhack-repo]: https://github.com/ttb-hcmut/bkhack

## Development using Nix shell

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

## Development using Nix shell from Docker (courtesy of Tung)

```sh
docker-compose up -d
docker exec -it bkhack bash
```

The rest, follows the *Nix shell* section.

## Try it out

Currently hosted at https://bkhack-2eb8c.web.app
