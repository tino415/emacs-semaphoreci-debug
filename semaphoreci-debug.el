;;; semaphoreci-debug.el --- Debug SemaphoreCI via TRAMP  -*- lexical-binding: t; -*-
(require 'tramp)

(defun semaphoreci-exec (job)
  (interactive "sJob: \n")
  (thread-last
    (string-replace "sem debug job " "" job)
    (format "/sem:%s:~")
    (call-interactively #'execute-extended-command)))

(add-to-list 'tramp-methods
             '("sem"
               (tramp-login-program "sh")
               (tramp-login-args
                (("-c")
                 ("'sem") ("attach") ("%h")
                 ("||")
                 ("sem") ("debug") ("job") ("%h")
                 ("'")))
               (tramp-remote-shell "/bin/sh")
               (tramp-remote-shell-args ("-c"))))

(provide 'semaphoreci-debug)
