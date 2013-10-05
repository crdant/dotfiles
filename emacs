; Required due to Darwin pty issues
(setq process-connection-type nil)

;; Update load path
; (setq load-path (cons "/opt/local/share/emacs/site-lisp" load-path))


; use JDEE for Java
(load "cedet.el")
(require 'jde)
(setq semanticdb-default-save-directory "~/tmp/semantic.cache")

; use MMM mode for rails and jsp
(require 'mmm-mode)
(setq mmm-global-mode 'maybe)

; set up JSP mode with MMM
(setq auto-mode-alist
      (cons '("\\.jsp" . html-mode)
            auto-mode-alist))
(mmm-add-mode-ext-class 'html-mode "\\.jsp\\'" 'jsp)
(mmm-add-group 'jsp
 '(
   (html-css-attribute
    :submode css-mode
    :face mmm-declaration-submode-face
    :front "style=\""
    :back "\"")
   (jsp-code
    :submode java
    :match-face (("<%!" . mmm-declaration-submode-face)
                 ("<%=" . mmm-output-submode-face)
                 ("<%"  . mmm-code-submode-face))
    :front "<%[!=]?"
    :back "%>"
    :insert ((?% jsp-code nil @ "<%" @ " " _ " " @ "%>" @)
    	     (?! jsp-declaration nil @ "<%!" @ " " _ " " @ "%>" @)
    	     (?= jsp-expression nil @ "<%=" @ " " _ " " @ "%>" @))
    )
   (jsp-directive
    :submode text-mode
    :face mmm-special-submode-face
    :front "<%@"
    :back "%>"
    :insert ((?@ jsp-directive nil @ "<%@" @ " " _ " " @ "%>" @))
    )
   ))

; use PMD to help with Java code
(autoload 'pmd-current-buffer "pmd" "PMD Mode" t)
(autoload 'pmd-current-dir "pmd" "PMD Mode" t)

; ruby
(autoload 'ruby-mode "ruby-mode"
  "Mode for editing ruby source files" t)
(setq auto-mode-alist
      (append '(("\\.rb$" . ruby-mode)) auto-mode-alist))
(setq interpreter-mode-alist (append '(("ruby" . ruby-mode))
                                        interpreter-mode-alist))
(autoload 'run-ruby "inf-ruby"
  "Run an inferior Ruby process")
(autoload 'inf-ruby-keys "inf-ruby"
  "Set local key defs for inf-ruby in ruby-mode")

(add-hook 'ruby-mode-hook
          (lambda()
            (inf-ruby-keys)
            (add-hook 'local-write-file-hooks
                      '(lambda()
                         (save-excursion
                           (untabify (point-min) (point-max))
                           (delete-trailing-whitespace)
                           )))
            (set (make-local-variable 'indent-tabs-mode) 'nil)
            (set (make-local-variable 'tab-width) 2)
            (imenu-add-to-menubar "IMENU")
            (require 'ruby-electric)
            (ruby-electric-mode t)
            ))

; interactive ruby execution
(defun ruby-eval-buffer () (interactive)
   "Evaluate the buffer with ruby."
   (shell-command-on-region (point-min) (point-max) "ruby"))

; ruby on rails
(require 'ecb)
(semantic-load-enable-code-helpers)
(setq auto-mode-alist  (cons '("\\.rhtml$" . html-mode) auto-mode-alist))
(modify-coding-system-alist 'file "\\.rb$" 'utf-8)
(modify-coding-system-alist 'file "\\.rhtml$" 'utf-8)

(require 'snippet)
(require 'rails)

(defun rails-find-and-goto-error ()
  "Finds error in rails html log go on error line" 
  (interactive)
  (search-forward-regexp "RAILS_ROOT: \\([^<]*\\)")
  (let ((rails-root (concat (match-string 1) "/")))
    (search-forward "id=\"Application-Trace\"")
    (search-forward "RAILS_ROOT}")
    (search-forward-regexp "\\([^:]*\\):\\([0-9]+\\)")
    (let  ((file (match-string 1))
       (line (match-string 2)))
      ;(kill-buffer (current-buffer))
      (message
       (format "Error found in file \"%s\" on line %s. "  file line))
      (find-file (concat rails-root file))
      (goto-line (string-to-int line)))))

; set all source code "tabs" to 4 spaces
(setq-default tab-width 4 indent-tabs-mode nil)

;; use traditional font-lock
(cond ((fboundp 'global-font-lock-mode)
       ;; Turn on font-lock in all modes that support it
       (global-font-lock-mode t)
       ;; Maximum colors
       (setq font-lock-maximum-decoration t)))

;; Use no tabs when editing Java for cross-editor indentation compatibility.
(defun my-jde-indent-setup ()
  (setq indent-tabs-mode nil)
  (setq jde-basic-offset 4))

;;
;; Add the above hook to the jde-mode.
(add-hook 'jde-mode-hook 'my-jde-indent-setup)

; use Ant for JDE compilation
(add-hook 'java-mode-hook
	  (function (lambda ()
		      (make-local-variable 'compile-command)
		      (setq compile-command
			    "/usr/bin/java -Dant.home=/Developer/Java/J2EE/apache-ant-1.5.3 -classpath c:/program files/javasoft/jdk1.3/lib/tools.jar:/Developer/Java/J2EE/apache-ant-1.5.3/lib/ant.jar:/Developer/Java/J2EE/apache-ant-1.5.3/lib/jaxp.jar:/Developer/Java/J2EE/apache-ant-1.5.3/lib/parser.jar org.apache.tools.ant.Main -emacs "))))

; use nXML for XML editing
(load "rng-auto.el")
(setq auto-mode-alist
      (cons '("\\.\\(xml\\|xsl\\|xsd\\|rng\\|wsdl\\|xhtml\\)\\'" . nxml-mode)
            auto-mode-alist))

; set up XQuery mode
(require 'xquery-mode)
(setq auto-mode-alist
      (cons '("\\.\\(xquery\\|xqy\\|xql\\|xq\\|xqry\\)\\'" . xquery-mode)
            auto-mode-alist))

; Replace yes-or-no question responses with y-or-n responses
(fset 'yes-or-no-p 'y-or-n-p)

;show ascii table
(defun ascii-table ()
  "Print the ascii table. Based on a defun by Alex Schroeder <asc@bsiag.com>"
  (interactive)
  (switch-to-buffer "*ASCII*")
  (erase-buffer)
  (insert (format "ASCII characters up to number %d.\n" 254))
  (let ((i 0))
    (while (< i 254)
      (setq i (+ i 1))
      (insert (format "%4d %c\n" i i))))
  (beginning-of-buffer))

;convert a buffer from dos ^M end of lines to unix end of lines
(defun dos2unix ()
  (interactive)
    (goto-char (point-min))
      (while (search-forward "\r" nil t) (replace-match "")))

;vice versa
(defun unix2dos ()
  (interactive)
    (goto-char (point-min))
      (while (search-forward "\n" nil t) (replace-match "\r\n")))

; convert DOS environment variables references to Unix
(defun convert-env-vars ()
  (interactive)
  (set-mark (point-min))
  (replace-regexp "%\\([A-Z_]+\\)%" "$\\1")
)

;switch to "Text Fill" with one command
(defun text-fill-mode ()
  (interactive)
  (text-mode)
  (auto-fill-mode)
  (flyspell-mode)
)

; use text-fill-fly-mode for text-files
(setq auto-mode-alist
      (cons '("\\.txt" . text-fill-mode)
	    auto-mode-alist))

; Select everything, from http://dotfiles.com/files/6/139_.emacs
(defun select-all ()
  (interactive)
  (set-mark (point-min))
  (goto-char (point-max)))

; bind to ctrl-x a
(global-set-key "\C-xa" 'select-all)

; goto-line with a command
(global-set-key "\C-xl" 'goto-line)

; set the home key and end key to go to the start/end of buffer
(global-set-key [home] 'beginning-of-buffer)
(global-set-key [end] 'end-of-buffer)

;;; from customize functionality
(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(c-basic-offset 4)
 '(c-echo-syntactic-information-p t)
 '(c-hanging-braces-alist (quote ((brace-list-open before after) (brace-entry-open before after) (substatement-open before after) (block-close . c-snug-do-while) (extern-lang-open before after) (inexpr-class-open before after) (inexpr-class-close before after))))
 '(jde-wiz-get-set-variable-prefix "p")
 '(nxml-attribute-indent 4)
 '(nxml-auto-insert-xml-declaration-flag t)
 '(nxml-child-indent 4)
 '(nxml-slash-auto-complete-flag t)
 '(pmd-home "/opt/local/share/pmd-2.0")
 '(pmd-java-home "/System/Library/Frameworks/JavaVM.framework/Versions/1.4.2/Home"))

; sometimes this is helpful (rarely)
(put 'upcase-region 'disabled nil)
; more helpful
(put 'downcase-region 'disabled nil)

; add policy, property files, and files decompiled with JAD  to list of files opened with java mode
(setq auto-mode-alist
      (cons '("\\.\\(policy\\|properties\\|jad\\)\\'" . java-mode)
	    auto-mode-alist))

; customize stuff

(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 )

; set up the gnuserver for access via command-line and Eclipse
; (server-start)
