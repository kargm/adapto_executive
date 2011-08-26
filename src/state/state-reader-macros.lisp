(in-package :ad-exe)


;; private auxilliary function helping with macro building
;; returns the reader-macro-expansion for reader sequences between until the next "]" or "}"
(defun value-and-fluent-reader (stream macro-char)
  (labels (
           ;; returns the closing bracket char
           (inverse-macro-char (mchar)
             (ccase mchar
               (#\[ #\])
               (#\{ #\}))) )
    (let ( (content (read-delimited-list (inverse-macro-char macro-char) stream t)) )
      (case macro-char
        (#\[
          (if (null (rest content))
            `(value ,@content)
            `(value ,content)))
        (#\{
          (if (and (symbolp (first content)) (null (cddr content)))
            `(fl-funcall (symbol-function ',(first content)) ,(second content))
            content))))))


;; define the functions to call when reader encounters the given char
(set-macro-character #\{ #'value-and-fluent-reader)
(set-macro-character #\} (get-macro-character #\)))
(set-macro-character #\[ #'value-and-fluent-reader)
(set-macro-character #\] (get-macro-character #\)))


