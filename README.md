bkhack: Bách Khoa Hack
======================
`bkhack` is an abstract, heterogeneous full-stack application, currently deployed as a social news website at Ho Chi Minh University of Technology.

The following paper provides more details:

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Develop an educational computer-science-oriented social news website for Ho Chi Minh University of Technology ([pdf][bkhack-paper])  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Phát triển mạng xã hội giáo dục hướng Khoa học Máy tính tại Đại học Bách Khoa TP.HCM  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Lê Nguyễn Gia Bảo, Lê Công Minh Khang, and Hồ Gia Tường  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Undergraduate Thesis 2026  

[bkhack-paper]: https://baorepo.web.app/~ttb-hcmut/bkhack.pdf
- Project Repository: https://github.com/ttb-hcmut/bkhack
- Thesis Paper (PDF): https://baorepo.web.app/~ttb-hcmut/bkhack.pdf
- Live Deployment: https://bkhack-2eb8c.web.app

---

# Repository Structure

```text
src/         Frontend source code
service/     Backend service
build_aux/   Docker and auxiliary tooling
doc/         Thesis and documentation
```

---

# Installation

Add the [bkhack-repo] repository to OPAM:

```sh
opam remote add bkhack git+https://github.com/ttb-hcmut/bkhack
```


Install the package:

```sh
opam install bkhack
```

[bkhack-repo]: https://github.com/ttb-hcmut/bkhack

---

# Usage

`bkhack` is distributed as both a reusable OCaml/Melange library, and a suite of frontend bundling tools.

You can integrate it into your own Melange application:

```dune
(melange.emit
 ; ...
 (libraries bkhack))
```

Bundle the application for deployment:

```sh
export BKHACK_BACKEND_ADDRESS='http://localhost:5000'
bkhack.bundle ./ -o dist
```

This produces a `dist/` directory containing static HTML and JavaScript bundles
suitable for deployment platforms such as Firebase Hosting or Netlify.

---

# Development setup

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

---

# Try it out

The current deployment is available at:

https://bkhack-2eb8c.web.app
