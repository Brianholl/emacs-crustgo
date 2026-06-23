;;; init.el --- emacs-crustgo — Emacs mínimo para C, C++, Rust y Go -*- lexical-binding: t; -*-
;;
;; Version: 1.0
;;
;; Crustgo: un Emacs para lenguajes de sistemas — C, C++, Rust y Go.
;; Tema dark + números de línea, lsp-mode (clangd / rust-analyzer / gopls)
;; y debug con gdb/dap. Sin org-mode, sin IA, sin adornos.
;;
;; Hermano de crisol (que es sólo C); crustgo = C + Rust + Go (+ C++).
;;
;; Lanzar:  crustgo            (alias de fish)
;;     o:   emacs --init-directory ~/Dev/emacs-crustgo/

;; ─────────────────────────────────────────────────────────────
;; 1. Paquetes (MELPA + use-package)
;; ─────────────────────────────────────────────────────────────
(require 'package)
(setq package-archives
      '(("gnu"    . "https://elpa.gnu.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/")
        ("melpa"  . "https://melpa.org/packages/")))
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))
(unless (package-installed-p 'use-package)
  (package-install 'use-package))
(require 'use-package)
(setq use-package-always-ensure t)

;; ─────────────────────────────────────────────────────────────
;; 2. UI: tema dark + números de línea
;; ─────────────────────────────────────────────────────────────
(use-package emacs
  :ensure nil
  :config
  (setq ring-bell-function 'ignore)        ; sin sonidos
  ;; Mensaje del buffer *scratch* — ASCII art de crustgo
  (setq initial-scratch-message "\
;;
;;  ██████╗██████╗ ██╗   ██╗███████╗████████╗ ██████╗  ██████╗
;; ██╔════╝██╔══██╗██║   ██║██╔════╝╚══██╔══╝██╔════╝ ██╔═══██╗
;; ██║     ██████╔╝██║   ██║███████╗   ██║   ██║  ███╗██║   ██║
;; ██║     ██╔══██╗██║   ██║╚════██║   ██║   ██║   ██║██║   ██║
;; ╚██████╗██║  ██║╚██████╔╝███████║   ██║   ╚██████╔╝╚██████╔╝
;;  ╚═════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝   ╚═╝    ╚═════╝  ╚═════╝
;;
;;   C · C++ · Rust · Go   ·   F5 compila/corre · F12 def · M-x gdb
;;   primera vez: M-x dap-cpptools-setup  (C/C++/Rust)
\n")
  (setq-default indent-tabs-mode nil
                tab-width 4
                c-basic-offset 4)
  (column-number-mode 1)
  (global-auto-revert-mode 1)              ; recargar archivos cambiados fuera
  ;; Números de línea relativos al costado
  (setq display-line-numbers-type 'relative)
  (global-display-line-numbers-mode 1)
  ;; Fuente (usa la primera disponible)
  (require 'cl-lib)
  (when (display-graphic-p)
    (cl-dolist (f '("JetBrains Mono" "Iosevka" "Hack" "DejaVu Sans Mono"))
      (when (member f (font-family-list))
        (set-face-attribute 'default nil :font f :height 140)
        (cl-return)))))

;; Tema dark
(use-package doom-themes
  :config
  (load-theme 'doom-one t))

;; ─────────────────────────────────────────────────────────────
;; 3. Autocompletado
;; ─────────────────────────────────────────────────────────────
(use-package company
  :hook (after-init . global-company-mode)
  :config
  (setq company-minimum-prefix-length 1
        company-idle-delay 0.2))

;; ─────────────────────────────────────────────────────────────
;; 4. Modos de lenguaje (Rust y Go; C/C++ ya vienen en cc-mode)
;; ─────────────────────────────────────────────────────────────
(use-package rust-mode
  :mode "\\.rs\\'"
  :config
  ;; Formatear con rustfmt al guardar
  (setq rust-format-on-save t))

(use-package go-mode
  :mode "\\.go\\'"
  :config
  ;; gofmt al guardar (Go usa tabs; respetamos su estilo nativo)
  (add-hook 'before-save-hook #'gofmt-before-save nil t))

;; ─────────────────────────────────────────────────────────────
;; 5. LSP — clangd (C/C++) · rust-analyzer (Rust) · gopls (Go)
;; ─────────────────────────────────────────────────────────────
(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :hook ((c-mode    . lsp-deferred)
         (c++-mode  . lsp-deferred)
         (rust-mode . lsp-deferred)
         (go-mode   . lsp-deferred)
         ;; organizar imports de Go al guardar (gopls)
         (go-mode   . (lambda ()
                        (add-hook 'before-save-hook
                                  #'lsp-organize-imports nil t))))
  :init
  (setq lsp-keymap-prefix "C-c l")
  :config
  (setq lsp-headerline-breadcrumb-enable nil
        lsp-idle-delay 0.5)
  ;; F12 = ir a definición · Shift-F12 = referencias
  (define-key lsp-mode-map (kbd "<f12>")   #'lsp-find-definition)
  (define-key lsp-mode-map (kbd "S-<f12>") #'lsp-find-references))

(use-package lsp-ui
  :commands lsp-ui-mode
  :config
  (setq lsp-ui-doc-enable nil
        lsp-ui-sideline-enable t))

;; ─────────────────────────────────────────────────────────────
;; 6. Debug — dap-mode + gdb / delve
;; ─────────────────────────────────────────────────────────────
(autoload 'dap-cpptools-setup "dap-cpptools" "Install dap-cpptools" t)
(use-package dap-mode
  :after lsp-mode
  :config
  (require 'dap-cpptools)        ; adaptador C/C++/Rust (usa gdb por debajo)
  (require 'dap-dlv-go)          ; adaptador Go (usa delve / dlv)
  (dap-auto-configure-mode 1))

;; GDB nativo de Emacs — es lo más sólido para VER REGISTROS (C/C++/Rust).
;; M-x gdb  → abre el layout completo; con gdb-many-windows tenés
;; locals/stack/breakpoints. Para registros: en el buffer de gud,
;; M-x gdb-display-registers-buffer (o cambiá una ventana a ese buffer);
;; se actualizan en cada paso.
;; Para Go, lo idiomático es delve:  M-x dap-debug → "Go Dlv ...".
(setq gdb-many-windows t
      gdb-show-main t)

;; ─────────────────────────────────────────────────────────────
;; 7. Compilar / correr con F5 (según el proyecto o el archivo)
;; ─────────────────────────────────────────────────────────────
(setq compilation-scroll-output t)

(defun crustgo-compile ()
  "F5: guarda y compila/corre. Detecta el proyecto (Cargo.toml, go.mod,
Makefile) y, si no hay, compila el archivo suelto según su extensión:
C → gcc, C++ → g++, Rust → rustc, Go → go run."
  (interactive)
  (save-buffer)
  (let* ((file  buffer-file-name)
         (ext   (and file (downcase (or (file-name-extension file) ""))))
         (base  (and file (file-name-base file)))
         (name  (and file (file-name-nondirectory file)))
         (cargo (locate-dominating-file default-directory "Cargo.toml"))
         (gomod (locate-dominating-file default-directory "go.mod"))
         (make  (locate-dominating-file default-directory "Makefile"))
         dir cmd)
    (cond
     ;; ── Rust ────────────────────────────────────────────────
     ((string= ext "rs")
      (if cargo
          (setq dir cargo cmd "cargo run")
        (setq dir default-directory
              cmd (format "rustc %s -o %s && ./%s"
                          (shell-quote-argument name) base base))))
     ;; ── Go ──────────────────────────────────────────────────
     ((string= ext "go")
      (if gomod
          (setq dir default-directory cmd "go run .")
        (setq dir default-directory
              cmd (format "go run %s" (shell-quote-argument name)))))
     ;; ── C ───────────────────────────────────────────────────
     ((string= ext "c")
      (if make
          (setq dir make cmd "make")
        (setq dir default-directory
              cmd (format "gcc -Wall -Wextra -g %s -o %s && ./%s"
                          (shell-quote-argument name) base base))))
     ;; ── C++ ─────────────────────────────────────────────────
     ((member ext '("cpp" "cc" "cxx" "c++" "hpp"))
      (if make
          (setq dir make cmd "make")
        (setq dir default-directory
              cmd (format "g++ -std=c++17 -Wall -Wextra -g %s -o %s && ./%s"
                          (shell-quote-argument name) base base))))
     ;; ── Sin extensión conocida: probar Makefile ─────────────
     (make (setq dir make cmd "make")))
    (if cmd
        (let ((default-directory dir))
          (compile cmd))
      (message "crustgo: no sé cómo compilar este buffer (%s)" (or name "?")))))

(dolist (map-sym '(c-mode-map c++-mode-map))
  (with-eval-after-load 'cc-mode
    (when (boundp map-sym)
      (define-key (symbol-value map-sym) (kbd "<f5>") #'crustgo-compile))))
(with-eval-after-load 'rust-mode
  (define-key rust-mode-map (kbd "<f5>") #'crustgo-compile))
(with-eval-after-load 'go-mode
  (define-key go-mode-map (kbd "<f5>") #'crustgo-compile))
(global-set-key (kbd "<f5>") #'crustgo-compile)

;; ─────────────────────────────────────────────────────────────
;; 8. ESP32 / embebido — flashear con F6
;; ─────────────────────────────────────────────────────────────
;; F5 compila/corre en el HOST. Para microcontroladores el build+flash
;; lo maneja cada ecosistema (idf.py / espflash / tinygo), así que F6 va
;; aparte. Lo más confiable: un archivo .crustgo-flash en la raíz del
;; proyecto con el comando exacto (puerto, target, etc.). Si no está,
;; intentamos detectar ESP-IDF / cargo-espflash / TinyGo.
(defun crustgo-esp-flash ()
  "F6: build + flash a un ESP32.
Usa el comando del archivo `.crustgo-flash' del proyecto si existe; si no,
detecta ESP-IDF (sdkconfig), Rust (Cargo.toml) o TinyGo (go.mod)."
  (interactive)
  (when buffer-file-name (save-buffer))
  (let* ((root (or (locate-dominating-file default-directory ".crustgo-flash")
                   (locate-dominating-file default-directory "sdkconfig")
                   (locate-dominating-file default-directory "sdkconfig.defaults")
                   (locate-dominating-file default-directory "Cargo.toml")
                   (locate-dominating-file default-directory "go.mod")
                   default-directory))
         (flashfile (expand-file-name ".crustgo-flash" root))
         cmd)
    (cond
     ;; 1) comando explícito del proyecto (gana siempre)
     ((file-exists-p flashfile)
      (setq cmd (string-trim
                 (with-temp-buffer
                   (insert-file-contents flashfile)
                   (buffer-string)))))
     ;; 2) ESP-IDF (C/C++)
     ((or (file-exists-p (expand-file-name "sdkconfig" root))
          (file-exists-p (expand-file-name "sdkconfig.defaults" root)))
      (setq cmd "idf.py flash monitor"))
     ;; 3) Rust embebido (espflash como runner de cargo)
     ((file-exists-p (expand-file-name "Cargo.toml" root))
      (setq cmd "cargo run --release"))
     ;; 4) TinyGo
     ((file-exists-p (expand-file-name "go.mod" root))
      (setq cmd "tinygo flash -target=esp32 -monitor .")))
    (if (and cmd (not (string-empty-p cmd)))
        (let ((default-directory root))
          (compile cmd))
      (message "crustgo: no sé cómo flashear. Creá un .crustgo-flash con el comando."))))

(global-set-key (kbd "<f6>") #'crustgo-esp-flash)

;; ─────────────────────────────────────────────────────────────
;; 9. Final: GC normal + custom-file separado
;; ─────────────────────────────────────────────────────────────
(setq gc-cons-threshold (* 32 1024 1024))
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file) (load custom-file))

;;; init.el ends here
