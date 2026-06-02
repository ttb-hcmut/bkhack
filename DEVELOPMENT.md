Development setup
=================

Our repository structure is as follows:

```text
src/         Frontend source code
service/     Backend service
build_aux/   Docker and auxiliary tooling
doc/         Thesis and documentation
```

---

`bkhack` supports two development environments:

| Environment | Recommended For |
|---|---|
| Native Linux / WSL2 | Linux users and WSL2 users |
| Windows + Docker | Windows users wanting isolated tooling |

---

## Prerequisites

### Native Linux / WSL2

Install:

- Git
- Nix
- OPAM
- Node.js + pnpm

Recommended:

- direnv

### Windows + Docker

Install:

- Docker Desktop
- WSL2 (enabled in Docker Desktop)
- Git

Recommended:

- Windows Terminal

---

# Development using Nix Shell

> Docker users:
>
> First start the development container:
>
> ```sh
> docker compose -f build_aux/docker-compose.yml up -d
> ```
>
> Then enter the container:
>
> ```sh
> docker exec -it bkhack-shell sh
> ```
>
> Then continue with the same `nix-shell` workflow below.

Update channels and enter the project shell:

```sh
nix-channel --update
nix-shell
```
---

## Initial setup

```sh
[ ! -d _opam ] && opam init
eval $(opam env)

export TEST=$PWD
dune exec bin/bundle.exe
export BKHACK_FIREBASE_KEY=replace_with_actual_firebase_api_key
export BKHACK_BACKEND_ADDRESS='http://localhost:5000'

pnpm install
pnpm run init
```

> Docker note:
>
> If OPAM sandboxing fails inside Docker, choose `y` to disable sandboxing.
> This is expected in containerized environments.

---

Start the frontend development server:

```sh
pnpm dev
```

Voilà!

---

# Backend service

Open another shell:

```sh
cd service
nix-shell
```

> Docker users:
>
> Open another shell inside the container instead:
>
> ```sh
> docker exec -it bkhack-shell sh
> cd /service
> nix-shell
> ```

Install Elixir dependencies:

```sh
mix deps.get
```

Start interactive backend server:

```sh
iex -S mix
```

Inside IEx:

```elixir
App.start
# [info] running server
# => :ok
```

Stop the server:

```elixir
App.stop
# [info] stopped server
# => :ok
```

Backend runs at:

```text
http://localhost:5000
```

---

# Production build

Bundle frontend assets:

```sh
export BKHACK_BACKEND_ADDRESS='http://localhost:5000'
bkhack.bundle ./ -o dist
```

Deploy the generated `dist/` directory to your preferred static hosting provider.
