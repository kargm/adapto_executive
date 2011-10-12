(in-package :ad-exe)

;; Wait until a navigation-action starts, then generate an expectation
(defun start-navigation-watchdog ()
  (if (eq [cpm:pm-status :navigation] :RUNNING)
    (format t "Nav-PM: running ~s ~%" [cpm:pm-status :navigation])
    (format t "Nav-PM: waiting ~s ~%" [cpm:pm-status :navigation]))
  (sleep 2)
  (start-navigation-watchdog))
    