;;;; Utilities for jumping between model/controller/view/test based on Phoenix
;;;; filename conventions.

(require 's)

(defun dt/elixir-utils-base-name (remove-segments)
  "Returns the basic name of the module based on stripping down the buffer file name.\
\
REMOVE-SEGMENTS are parts of the buffer file name that are removed in addition to the\
path and the extension."
  (interactive)
  (let ((basename buffer-file-name))
    (setq basename (file-name-sans-extension basename))
    (setq basename (replace-regexp-in-string remove-segments "" basename))
    (setq basename (replace-regexp-in-string ".*/" "" basename))
    basename))

(defun dt/elixir-utils-goto-model ()
  "Goes to the model file corresponding with the current buffer."
  (interactive)
  (let* ((basename (dt/elixir-utils-base-name "\\(_test\\)\\|\\(_controller\\)\\|\\(_view\\)"))
         (model_path
          (seq-find (lambda (pathname) (s-contains? (concat basename ".ex") pathname))
                    (project-files (project-current t)))))
    (if model_path
        (find-file model_path)
      (message "Couldn't find model for %s"  basename))))

(defun dt/elixir-utils-goto-controller ()
  "Goes to the controller file corresponding with the current buffer."
  (interactive)
  (let* ((basename (dt/elixir-utils-base-name "\\(_test\\)\\|\\(_controller\\)\\|\\(_view\\)"))
         (controller_path
          (seq-find (lambda (pathname) (s-contains? (concat basename "_controller.ex") pathname))
                    (project-files (project-current t)))))
    (if controller_path
        (find-file controller_path)
      (message "Couldn't find controller for %s"  basename))))

(defun dt/elixir-utils-goto-view ()
  "Goes to the view file corresponding with the current buffer."
  (interactive)
  (let* ((basename (dt/elixir-utils-base-name "\\(_test\\)\\|\\(_controller\\)\\|\\(_view\\)"))
         (view_path
          (seq-find (lambda (pathname) (s-contains? (concat basename "_view.ex") pathname))
                    (project-files (project-current t)))))
    (if view_path
        (find-file view_path)
      (message "Couldn't find view for %s"  basename))))

(defun dt/elixir-utils-goto-test ()
  "Goes to the test file corresponding with the current buffer."
  (interactive)
  ;; Must be careful not to remove "_controller" because there are tests
  ;; for both models and controllers, and we want to go to the correct one.
  (let* ((basename (dt/elixir-utils-base-name "\\(_test\\)\\|\\(_view\\)"))
         (test_path
          (seq-find (lambda (pathname) (s-contains? (concat basename "_test.ex") pathname))
                    (project-files (project-current t)))))
    (if test_path
        (find-file test_path)
      (message "Couldn't find test for %s"  basename))))

(provide 'dt/elixir-utils)
