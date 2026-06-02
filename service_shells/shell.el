;;; test --- sdf
;;; Commentary:
(use-package nix-mode :ensure t)
(use-package auto-minor-mode :ensure t)
(add-to-list 'auto-minor-mode-alist
						 '("" . flymake-mode))
(use-package typst-ts-mode :ensure t)
(with-eval-after-load 'elgot
 (with-eval-after-load 'typst-ts-mode
	 (add-to-list 'eglot-server-programs
		'(typst-ts-mode . ,(eglot-alternatives `(,typst-ts-lsp-download-path "tinymist" "typst-lsp")))
	   )))
(use-package neocaml :ensure t)
(use-package ocaml-eglot :ensure t :after neocaml
	:hook (neocaml-base-mode . ocaml-eglot-mode) (ocaml-eglot-mode . eglot-ensure))
(use-package reason-mode :ensure t)
(use-package markdown-mode :ensure t
	:mode ("README\\.md\\'" . gfm-mode))
; (use-package git-modes)
