bkhack: Bách Khoa Hack
======================
`bkhack` is an abstract, heterogeneous full-stack application, currently deployed as a social news website at Ho Chi Minh University of Technology.

The following paper provides more details:

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Develop an educational computer-science-oriented social news website for Ho Chi Minh University of Technology ([pdf][bkhack-paper])  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Phát triển mạng xã hội giáo dục hướng Khoa học Máy tính tại Đại học Bách Khoa TP.HCM  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Lê Nguyễn Gia Bảo, Lê Công Minh Khang, and Hồ Gia Tường  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Undergraduate Thesis 2026  

[bkhack-paper]: https://baorepo.web.app/~ttb-hcmut/thesis.pdf

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

## Usage

`bkhack` is distributed as a front-end library and a suite of bundling tools. Once you've installed the package, you can use the library in the composition of your own front-end.

```dune
(melange.emit
 ; ...
 (libraries bkhack))
```

Bundle your front-end as a web package

```sh
export BKHACK_BACKEND_ADDRESS='http://localhost:5000' # configure a back-end server to plug in
bkhack.bundle ./ -o dist
```

You will get a `dist` folder with the necessary static HTML and JavaScript bundles for deployment e.g. Firebase Hosting, Netlify.

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
