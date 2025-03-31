;; Stop welcome screen
(setq inhibit-splash-screen t
      visible-bell t) ; Flash when out of range

;; Enable MELPA packages
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
;; Comment/uncomment this line to enable MELPA Stable if desired.  See `package-archive-priorities`
;; and `package-pinned-packages`. Most users will not need or want to do this.
;;(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(package-initialize)

;; Bug with package signatures and ELPA
(setq package-check-signature 'allow-unsigned)

;;;-------------- LOOKING PRETTY----------------------------- ;;;
;; Some basic UI settings
(tool-bar-mode -1)
(scroll-bar-mode -1)

;; Line numbers in every buffer
(global-display-line-numbers-mode 1)

;; Highlight line in every buffer
(global-hl-line-mode 1)

;; Autocomplete parenthesis
(electric-pair-mode t)

;; Change cursor type for all frames
(setq-default cursor-type 'bar)
(set-cursor-color "#c38ff7")

;; icomplete vertical mode
(require 'icomplete-vertical)
;; Config not mine
;; TODO: learn use-package
(use-package icomplete
  :bind (:map icomplete-minibuffer-map
              ("C-n" . icomplete-forward-completions)
              ("C-p" . icomplete-backward-completions)
              ("C-v" . icomplete-vertical-toggle)
              ("RET" . icomplete-force-complete-and-exit))
  :hook
  (after-init . (lambda ()
                  (fido-mode -1)
                  (icomplete-mode 1)
                  (icomplete-vertical-mode 1)
                  ))
  :config
  (setq tab-always-indent 'complete)  ;; Starts completion with TAB
  (setq icomplete-delay-completions-threshold 0)
  (setq icomplete-compute-delay 0)
  (setq icomplete-show-matches-on-no-input t)
  (setq icomplete-hide-common-prefix nil)
  (setq icomplete-prospects-height 10)
  (setq icomplete-separator " . ")
  (setq icomplete-with-completion-tables t)
  (setq icomplete-in-buffer t)
  (setq icomplete-max-delay-chars 0)
  (setq icomplete-scroll t)
  (advice-add 'completion-at-point
              :after #'minibuffer-hide-completions))


;; Load and stylizing modus-vivendi theme
;; Stylizing ALWAYS before loading the theme

(setq modus-themes-mode-line '(accented borderless)
      modus-themes-bold-constructs t
      modus-themes-italic-constructs t
      modus-themes-fringes 'subtle
      modus-themes-tabs-accented t
      modus-themes-paren-match '(bold intense)
      modus-themes-prompts '(bold intense)
     ; modus-themes-completions 'opinionated
      modus-themes-org-blocks 'tinted-background
      modus-themes-scale-headings t
      modus-themes-region '(bg-only)
      modus-themes-headings
      '((1 . (rainbow overline background 1.4))
        (2 . (rainbow background 1.3))
        (3 . (rainbow bold 1.2))
        (t . (semilight 1.1))))

(load-theme 'modus-vivendi t)
;;----- End of looking pretty ---------------- ;;
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ediprolog-system 'swi)
 '(ispell-dictionary nil)
 '(package-selected-packages
   '(use-package icomplete-vertical modus-themes flymake-swi-prolog ediprolog gnu-elpa-keyring-update))
 '(prolog-system nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(cursor ((t (:background "plum")))))


;; ------- Prolog settings -------------;;
;; Required packages for Prolog
(require 'ediprolog)
(require 'flymake-swi-prolog)

;; Some basic system setup
(setq prolog-system 'swi
      prolog-program-switches '((swi ("-G128M" "-T128M" "-L128M" "-O"))
                                (t nil))
      prolog-electric-if-then-else-flag t)


;; Read .pl files as Prolog files (never use Perl)
(add-to-list 'auto-mode-alist '("\\.pl$" . prolog-mode))

;; Function to insert a Prolog library
(defun prolog-insert-library ()
  "Insert a Prolog library directive"
  (interactive)
  (insert ":- use_module(library()).")
  (forward-char -3))

;; Function for inserting a Prolog comment block
(defun prolog-insert-comment-block ()
  "Insert a PceEmacs-style comment block like /* - - ... - - */ "
  (interactive)
  (let ((dashes "-"))
    (dotimes (_ 36) (setq dashes (concat "- " dashes)))
    (insert (format "/* %s\n\n%s */" dashes dashes))
    (forward-line -1)
    (indent-for-tab-command)))

;; Local Prolog keybinds
;; C-c l to insert a Prolog library
;; C-c q to insert a Prolog comment block
;; Shifttab to autocomplete word (dabbrev-expand)

(add-hook 'prolog-mode-hook
	  (lambda ()
	    (local-set-key (kbd "C-c l") 'prolog-insert-library)
	    (local-set-key (kbd "C-c q") 'prolog-insert-comment-block)
	    (local-set-key (kbd "<backtab>") 'dabbrev-expand)))

(defun prolog-insert-header ()
  "Insert a comment header with useful keybindings when creating a new Prolog file."
  (when (zerop (buffer-size))  ;; Only insert if the file is empty
    (insert "/* Prolog Mode Shortcuts %%\n")
    (insert "C-c l  -> Insert use_module(library()) \n")
    (insert "C-c q  -> Insert comment block \n")
    (insert "S-TAB  -> Expand with dabbrev \n")
    (insert "F10  -> Consult with ediprolog  */ \n \n")))

(add-hook 'prolog-mode-hook 'prolog-insert-header)


;; Global  keybind F10 to query question/load Prolog program
(global-set-key [f10] 'ediprolog-dwim)

;; On the fly syntax checking using the swiprolog compiler
;; TODO: It works, but i don't understand how

;; Hook for flymake to check grammar
(add-hook 'prolog-mode-hook #'flymake-swi-prolog-setup-backend)

;; ;; This I don't understand
  (add-hook 'prolog-mode-hook
             (lambda ()
                (require 'flymake)
                (make-local-variable 'flymake-allowed-file-name-masks)
                (make-local-variable 'flymake-err-line-patterns)
                (setq flymake-err-line-patterns
                      '(("ERROR: (?\\(.*?\\):\\([0-9]+\\)" 1 2)
                        ("Warning: (\\(.*\\):\\([0-9]+\\)" 1 2)))
                (setq flymake-allowed-file-name-masks
                      '(("\\.pl\\'" flymake-prolog-init)))
                (flymake-mode 1)))

 ;; (defun flymake-prolog-init ()
 ;;    (let* ((temp-file   (flymake-init-create-temp-buffer-copy
 ;;                         'flymake-create-temp-inplace))
 ;;           (local-file  (file-relative-name
 ;;                         temp-file
 ;;                         (file-name-directory buffer-file-name))))
 ;;      (list "swipl" (list "-q" "-t" "halt" "-s " local-file))))

;;------------- End of Prolog settings ------------------------
