(in-package :ad-exe)

;; in repl, once slime is up, run
;; ros-load-system adapto_executive adapto-executive
;;
;; (in-package :ad-exe)
;; (startup-ros)
;;
;; (foo-at-loc 1.0 1.0 0.0)

(def-top-level-plan foo-at-loc (x y angle)
  "tutorial function, robot goes to location and prints message foo to REPL"
  (pursue
    ;; make sure process modules are running
    (maybe-run-process-modules)
    (with-designators
        (( loc
           (location `((pose
                        ,(tf:make-pose-stamped "/map" 0.0
                                               (tf:make-3d-vector x y 0.0)
                                               (tf:euler->quaternion :az (/ angle pi))))))))
      (at-location (loc) (format t "foo~%")))))

