;;;===========================================================================
;;; Applescript
;;;---------------------------------------------------------------------------
(require 'applescript-mode)
(add-to-list 'auto-mode-alist '("\\.osa$" . applescript-mode))

(use-package magit-section) ; required for roam

(setq org-html-postamble nil)
;(setq org-html-postamble-format
;      '(("en" "<p class=\"author\">Author: %a</p>
;               <p class=\"date\">Date: %T</p>")))

;; Without ALPHA, finding nodes always creates a new node, even if it already exists:
;; https://org-roam.discourse.group/t/cant-open-node-if-another-nodes-name-starts-with-the-same-string/1890?u=nobiot
;;
;; Without BETA, org-roam-node-(find|insert) gets "Template needs to specify :if-new" errors
;; https://org-roam.discourse.group/t/v2-error-running-org-roam-dailies-find-today/1511/4
(use-package org-roam
  :ensure t
  :custom
  ;(org-roam-database-connector 'sqlite-builtin)
  ;(org-roam-db-connection "~/org-roam2")
  ;(org-roam-v2-ack t)
  (org-roam-directory (file-truename "~/org-roam2"))
  (org-roam-graph-executable "/usr/local/bin/dot")
  (org-roam-dailies-capture-templates ; BETA
   '(("d" "default" entry "* %?" :if-new
      (file+head "%(concat org-roam-dailies-directory \"/%<%Y-%m-%d>.org\")"
                 "#+title: %<%Y-%m-%d>"))))
  :bind (("C-c n l" . org-roam-buffer-toggle)
         ("C-c n f" . org-roam-node-find)
         ("C-c n g" . org-roam-graph)
         ("C-c n i" . org-roam-node-insert)
         ("C-c n c" . org-roam-capture))
  :config
  (setq org-roam-node-display-template "${title} ${tags}") ; ALPHA
  (org-roam-db-autosync-enable))

(setq org-display-inline-images t)
(setq org-redisplay-inline-images t)
(setq org-startup-with-inline-images "inlineimages")
(setq org-hide-emphasis-markers t)

(use-package org-bullets
  :config
  (add-hook 'org-mode-hook (lambda () org-bullets-mode 1)))

;; from https://zzamboni.org/post/beautifying-org-mode-in-emacs/
(let* ((variable-tuple
          (cond ((x-list-fonts "ETBembo")         '(:font "ETBembo"))
                ((x-list-fonts "Source Sans Pro") '(:font "Source Sans Pro"))
                ((x-list-fonts "Lucida Grande")   '(:font "Lucida Grande"))
                ((x-list-fonts "Verdana")         '(:font "Verdana"))
                ((x-family-fonts "Sans Serif")    '(:family "Sans Serif"))
                (nil (warn "Cannot find a Sans Serif Font.  Install Source Sans Pro."))))
         (base-font-color     (face-foreground 'default nil 'default))
         (headline           `(:inherit default :weight bold :foreground ,base-font-color)))
    (custom-theme-set-faces
     'user
     `(org-level-8 ((t (,@headline ,@variable-tuple))))
     `(org-level-7 ((t (,@headline ,@variable-tuple))))
     `(org-level-6 ((t (,@headline ,@variable-tuple))))
     `(org-level-5 ((t (,@headline ,@variable-tuple))))
     `(org-level-4 ((t (,@headline ,@variable-tuple :height 1.25))))
     `(org-level-3 ((t (,@headline ,@variable-tuple :height 1.25))))
     `(org-level-2 ((t (,@headline ,@variable-tuple :height 1.5))))
     `(org-level-1 ((t (,@headline ,@variable-tuple :height 1.5))))
     `(org-document-title ((t (,@headline ,@variable-tuple :height 1.5 :underline nil))))))
(custom-theme-set-faces
   'user
   '(variable-pitch ((t (:family "ETBembo" :height 130))))
   '(fixed-pitch ((t ( :family "Monaco" :height 120)))))
(add-hook 'org-mode-hook 'variable-pitch-mode)
(add-hook 'org-mode-hook 'visual-line-mode)
(custom-theme-set-faces
   'user
   '(org-block ((t (:inherit fixed-pitch))))
   '(org-code ((t (:inherit (shadow fixed-pitch)))))
   '(org-document-info ((t (:foreground "dark orange"))))
   '(org-document-info-keyword ((t (:inherit (shadow fixed-pitch)))))
   '(org-indent ((t (:inherit (org-hide fixed-pitch)))))
   '(org-link ((t (:foreground "royal blue" :underline t))))
   '(org-meta-line ((t (:inherit (font-lock-comment-face fixed-pitch)))))
   '(org-property-value ((t (:inherit fixed-pitch))) t)
   '(org-special-keyword ((t (:inherit (font-lock-comment-face fixed-pitch)))))
   '(org-table ((t (:inherit fixed-pitch :foreground "#83a598"))))
   '(org-tag ((t (:inherit (shadow fixed-pitch) :weight bold :height 0.8))))
   '(org-verbatim ((t (:inherit (shadow fixed-pitch))))))


;(Load "ol-bibtex")
(setq reftex-default-bibliography '("~/org-roam2/references.bib"))

;(use-package org-roam-bibtex
;  :after org-roam
;  :config
;  (require 'org-ref))

(setq bibtex-completion-display-formats
      '((t . "${author:*} ${title:*} ${year:4}")))

(use-package citar
  :no-require
  :custom
  (org-cite-global-bibliography '("~/org-roam2/references.bib"))
  (org-cite-insert-processor 'citar)
  (org-cite-follow-processor 'citar)
  (org-cite-activate-processor 'citar)
  (citar-bibliography org-cite-global-bibliography)
  :bind
  (:map org-mode-map :package org ("C-c b" . #'org-cite-insert)))

;(setq org-ref-bibliography-notes "~/org-roam2/notes.org"
;      org-ref-default-bibliography '("~/org-roam2/references.bib")
;      org-ref-pdf-directory "~/org-roam2/pdfs")
;(require 'org-ref)

; https://github.com/zweifisch/ob-http
(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp . t)
   (http . t)))

(with-eval-after-load 'org
  (define-key org-mode-map (kbd "C-c C-r") verb-command-map))

;;; make `shell-command` and `shell-command-on-region` read .bash_profile
;;; https://emacs.stackexchange.com/questions/17249/how-to-make-terminal-shell-spawned-inside-emacs-running-on-a-mac-inherit-the-env
(setq shell-command-switch "-lc")

(require 'org-tempo)
;(require 'bibtex-completion)

(require 'ox-md)

;;; for `ag`, e.g.
(add-to-list 'load-path "/usr/local/bin")

;;; `ag` not working even with the above; see
;;; https://github.com/Wilfred/ag.el/issues/93#issuecomment-348003505
(setenv "PATH" (concat (getenv "PATH") ":/usr/local/bin"))
(defun dt-js-goto-import ()
  "Visits the file at the current `import` line"
  (interactive)
  (save-excursion
    (beginning-of-line)
    (unless (re-search-forward "^import.*\\\sfrom\\\s['\"]" (line-end-position) t)
      (error "Not on a Javascript `import' line"))
    (let ((path-start (point)))
      (unless (re-search-forward "[\"']" (line-end-position) t)
        (error "Unterminated file name"))
      (find-file
       (concat (file-name-directory (buffer-file-name))
               (buffer-substring path-start (1- (point))))))))

(require 'js2-mode)
(define-key js2-mode-map (kbd "C-c i") #'dt-js-goto-import)

;;; dumb-jump
(use-package dumb-jump
  :ensure t
  :bind (("M-g o" . dumb-jump-go-other-window)
         ("M-g j" . dumb-jump-go)
         ("M-g b" . dumb-jump-back)
         ("M-g q" . dumb-jump-quick-look)
         ("M-g x" . dumb-jump-go-prefer-external)
         ("M-g z" . dumb-jump-go-prefer-external-other-window)))
(add-hook 'xref-backend-functions #'dumb-jump-xref-activate) ; not sure if this is really needed
(setq xref-show-definitions-function #'xref-show-definitions-completing-read)
(set-frame-font "-*-Monaco-normal-r-*-*-12-90-96-96-c-*-iso8859-1")
;(setq bibtex-completion-pdf-open-function 'org-open-file)

(provide 'local.el)
