(lang dune 3.8)
(name bkhack)
(generate_opam_files true)
(using melange 0.1)
(license "MIT")
(maintainers "Kinten Le <kinten108101@protonmail.com>")
(authors ttb-hcmut)

(package
 (name bkhack)
 (synopsis "bkhack website")
 (depends
  (ocaml (>= 5.2.0)) (reason (>= 3.13.0))
  (melange (>= 4.0.0)) (melange-fetch (>= 0.1.0)) (melange-json (>= 2.0.0))
  (reason-react (>= 0.15.0)) (reason-react-ppx (>= 0.15.0))
  (eio (>= 1.3)) (eio_main (>= 1.3))
  (containers (>= 3.16))
  (iter (>= 1.9))
  (re (>= 1.14.0))
 ))

(package
 (name bkhack-compiler)
 (synopsis "bkhack compile time tools")
 (description "bkhack compile time tools")
 (depends
  (ocaml (>= 5.2.0)) (reason (>= 3.1.30))
  (containers (>= 3.16))
  (utop (>= 2.16.0))
  (sexplib (>= 0.17.0))
 ))
