;;; semaphoreci-debug.el --- Debug SemaphoreCI jobs  -*- lexical-binding: t; -*-
(require 'tramp)
(require 'transient)

(defvar-local semaphoreci-job-id nil)
(defvar-local semaphoreci-job-id-requested nil)

(defconst semaphoreci--job-id-regexp
  "\\([0-9a-fA-F]\\{8\\}-[0-9a-fA-F]\\{4\\}-[0-9a-fA-F]\\{4\\}-[0-9a-fA-F]\\{4\\}-[0-9a-fA-F]\\{12\\}\\)")

(defun semaphoreci--ask-job-id (output)
  (when (and (not semaphoreci-job-id-requested)
             (string-match-p comint-prompt-regexp output))
    (setq semaphoreci-job-id-requested t)
    (comint-send-string
     (get-buffer-process (current-buffer))
     "echo $SEMAPHORE_JOB_ID\n"))
  output)

(defun semaphoreci--extract-job-id (output)
  (when (and semaphoreci-job-id-requested
             (not semaphoreci-job-id)
             (string-match semaphoreci--job-id-regexp output))
    (setq semaphoreci-job-id (match-string 1 output))
    (setq default-directory
          (format "/sem:%s:~/" semaphoreci-job-id)))
  output)


(defun semaphoreci-start (job)
  (interactive "sJob: ")
  (let* ((job (string-replace "sem debug job " "" job))
         (buffer-name (format "*sem-debug %s*" job))
         (buffer (get-buffer-create buffer-name)))
    (with-current-buffer buffer
      (comint-mode)
      (add-hook 'comint-preoutput-filter-functions
                #'semaphoreci--ask-job-id nil t)
      (add-hook 'comint-preoutput-filter-functions
                #'semaphoreci--extract-job-id nil t)
      (make-comint-in-buffer buffer-name buffer
                              "sem" nil "debug" "job" job))
    (switch-to-buffer buffer)))

(add-to-list 'tramp-methods
             '("sem"
               (tramp-login-program "sem")
               (tramp-login-args (("attach") ("%h")))
               (tramp-remote-shell "/bin/sh")
               (tramp-remote-shell-args ("-c"))))

(provide 'semaphoreci-debug)
