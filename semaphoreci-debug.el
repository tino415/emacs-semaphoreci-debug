;;; semaphoreci-debug.el --- Debug SemaphoreCI via TRAMP  -*- lexical-binding: t; -*-
(require 'tramp)

(defun semaphoreci-start (job)
  (interactive "sJob: \n")
  (let* ((job (string-replace "sem debug job " "" job))
         (process-name (format "sem-debug-job-%s" job))
         (buffer-name (format "*%s*" process-name))
         (buffer (get-buffer-create buffer-name))
         (folder (format "/sem:%s:~" job)))
    (make-process
     :name process-name
     :buffer buffer
     :command (list "sem" "debug" "job" job)
     :filter (lambda (proc output)
               (with-current-buffer (process-buffer proc)
                 (insert output)
                 (when (string-match "Semaphore CI Debug Session\\." output) (dired folder))))
     :sentinel (lambda (proc event)
                 (when (not (process-live-p proc))
                   (message "sem debug job %s exited: %s" job event))))))

(add-to-list 'tramp-methods
             '("sem"
               (tramp-login-program "sem")
               (tramp-login-args (("attach") ("%h")))
               (tramp-remote-shell "/bin/sh")
               (tramp-remote-shell-args ("-c"))))

(provide 'semaphoreci-debug)
