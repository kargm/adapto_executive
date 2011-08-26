(in-package :ad-exe)

; (cram-roslisp-common:startup-ros)
; (cram-plan-library:start-process-modules)
; Schnelltest:
;(top-level
;(with-designators ( (loc-desig (location `((pose ,(tf:make-pose-stamped "/map" 0.0
;                                              (tf:make-3d-vector 1.0 1.0 0.0)
;                                              (tf:euler->quaternion :az 0.0)))))) )
;  (cram-plan-library:at-location (loc-desig))))


(def-top-level-plan explore-navigation ()
  (start-statevar-update) ;sollte irgendwo zentral gestartet werden

  (pursue
    (cram-plan-library:maybe-run-process-modules)

    ; Data Acquisition
    (acquire-experiences-navigation-time-exp)

    ; Program
      (roll:with-parameter-samples (:parameters ( (x :random :min -1.0 :max 1.0 :samples 3)
                                                  (y :random :min -1.0 :max 1.0)
                                                  (az :random :min (* -1 pi) :max pi) )
                               :relation (:indep x y az))
        (let ( (goal-pose (tf:make-pose-stamped "/map" 0.0
                                                (tf:make-3d-vector x y 0.0)
                                                (tf:euler->quaternion :az az))) )
          (with-designators ( (loc-desig (location `((pose ,goal-pose)))) )
            (cram-plan-library:at-location (loc-desig))))
        (sleep 5)))

  ; Learning
  (format t "data acquired, start learning~%")
  (let ( (learning-problems '(:jido-go2pose-time-model-tree-function
                              :jido-go2pose-time-model-svm-function
                              #| :jido-go2pose-time-model-snns-function |#)) )
    (mapcar #'(lambda (lp) (roll:learn (getgv :learning-problem lp))) learning-problems))

  (format t "finished learning~%")

  (format t "testing results~%")
  (let ( (learned-functions (list #'jido-go2pose-time-model-tree
                                  #'jido-go2pose-time-model-svm
                                  #| #'jido-go2pose-time-model-snns |#)) )
    (roll:with-parameter-samples (:parameters ( (x :random :min -2.0 :max 2.0 :samples 2)
                                                (y :random :min -2.0 :max 2.0)
                                                (az :random :min (* -1 pi) :max pi)) :relation (:indep x y az))
      (let ( (test-point (tf:make-pose-stamped "/map" 0.0
                                                      (tf:make-3d-vector x y 0.0)
                                                      (tf:euler->quaternion :az az))) )
        (format t "test point: ~a~%" test-point)
        (mapcar #'(lambda (fun)
                  (format t "result for ~a: ~a~%" fun (funcall fun test-point)))
                learned-functions)
        (format t "~%"))))

)


