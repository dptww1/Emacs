;; -*- lexical-binding: t; -*-

(require 'ht)

(defun dt/org-roam-tag-stats ()
  "Returns an alphabetized list of all tags used in .org files in
`org-roam-directory`, along with their counts."
  (interactive)
  (save-excursion
    (let ((tags-hash (ht)))
      (mapc (lambda (file-name)
              (message "Processing %s" file-name)
              (find-file file-name)
              (org-map-entries (lambda ()
                                 (let ((tags (org-get-tags (point))))
                                   (mapc (lambda (s)
                                           (ht-set! tags-hash s (1+ (ht-get tags-hash s 0)))) tags)))) ; setf?
              (kill-buffer (current-buffer)))
            (directory-files org-roam-directory t ".org$"))
      (let ((out (get-buffer-create "*Org Roam Tag Stats*"))
            (keys (sort (ht-keys tags-hash))))
        (set-buffer out)
        (erase-buffer)
        (org-mode)
        (insert "Generated " (format-time-string "%FT%T") "\n\n")
        (insert "|-\n")
        (insert "| KEY | # REFS |\n")
        (insert "|-\n")
        (mapc (lambda (key)
                (insert (concat "| " key " | " (number-to-string (ht-get tags-hash key)) "|\n")))
              keys)
        (insert "|-\n")
        (previous-line)
        (org-ctrl-c-ctrl-c)
        (pop-to-buffer out)))))

(provide 'dt/org-roam-tag-stats)
