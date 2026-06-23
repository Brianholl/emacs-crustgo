;;; early-init.el --- emacs-crustgo — arranque temprano -*- lexical-binding: t; -*-

;; Sin barras ni adornos: se desactivan ANTES de dibujar el frame (sin parpadeo).
(setq inhibit-startup-screen t)
(menu-bar-mode -1)
(tool-bar-mode -1)
(when (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))

;; GC alto durante el arranque; se normaliza al final de init.el.
(setq gc-cons-threshold (* 128 1024 1024))

;; package.el se inicializa manualmente en init.el.
(setq package-enable-at-startup nil)

;;; early-init.el ends here
