(in-package :ad-exe)

(def-top-level-plan explore-navigation-cmds ()
  (start-statevar-update) ;sollte irgendwo zentral gestartet werden

  (with-tags
    (pursue
      (cram-plan-library:maybe-run-process-modules)

      ; Data Acquisition
      ;(acquire-experiences-navigation-time-exp)
      (acquire-experiences-navigation-time-hierarchy-exp :my-tag collect-experiences)

      ; Program
      (:tag collect-experiences
        (roll:with-parameter-samples (:parameters ( (x :random :min -1.0 :max 1.0 :samples 3)
                                                    (y :random :min -1.0 :max 1.0)
                                                    (az :random :min (* -1 pi) :max pi) )
                                 :relation (:indep x y az))
          (let ( (goal-pose (tf:make-pose-stamped "/map" 0.0
                                                  (tf:make-3d-vector x y 0.0)
                                                  (tf:euler->quaternion :az az))) )
            (with-designators ( (loc-desig (location `((pose ,goal-pose)))) )
              (cram-plan-library:at-location (loc-desig))))
          (sleep 5))))))
