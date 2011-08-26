(in-package :ad-exe-tests)

;; uses rt test framework
;; see http://cl-cookbook.sourceforge.net/testing.html
;; to run:
;; ros-load-system adapto-executive integration-test
;; > (in-package :ad-exe-tests)
;; > (integration-test-main) ;; to run all
;; > (do-test 'xyz) ;; to run a single test


(rem-all-tests);; removes previous other tests

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defvar *fixtures* (make-hash-table)))

;; test framework helper macros
(defmacro def-fixture (name args &body body)
  "defines a test fixture. Use (&body) where the test body should go."
  `(eval-when (:compile-toplevel :load-toplevel :execute)
     (setf (gethash ',name *fixtures*) (cons ',args ',body))
     ',name))

(defmacro with-fixture (fixture-name args &body body)
  "Insert BODY into the fixture named FIXTURE-NAME."
  (assert (gethash fixture-name *fixtures*)
          (fixture-name)
          "Unknown fixture ~S." fixture-name)
  (destructuring-bind (largs &rest lbody) (gethash fixture-name *fixtures*)
    `(macrolet ((&body () '(progn ,@body)))
       (funcall (lambda ,largs ,@lbody) ,@args))))

;; fixture starting and stopping process modules
(def-fixture with-cram-init ()
  (cram-roslisp-common:startup-ros)
  (let ((result (&body)))
    (cram-roslisp-common:shutdown-ros)
    result))

;; fixture starting and stopping a rosnode (for lightweight unit tests)
(def-fixture with-ros-node ()
  (roslisp:start-ros-node "rt_unit_test")
  (let ((result (&body)))
    (roslisp:shutdown-ros-node)
    result))



;;;;;; MAIN TEST FUNCTION, calls all tests define with deftest
(defun integration-tests-main ()
  "binary main entry function. Runs integration tests, requires morse for adapto to be running."
  (format t "Remember to start a roscore,~%MORSE in simulation mode,~%and the adapto roslaunch file~%roslaunch adapto_executive adapto_morse_nodes.launch ~%")
  ;; TODO: write this as a node, use launch file to start adapto roslaunch file
  (do-tests))


;; simple test to show ho to use rt-test
;; call this with (do-test 'addition)
(deftest test-addition
    ;; the test
    (+ 21 21)
  ;; the expected result
  42)

;; another simple test. Note the expected result argument does not get
;; evaluated, therefore (list 1 2) and '(1 2) do not work!!!
(deftest test-append
    ;; the test
    (append '(1) '(2))
  ;; the expected result
  (1 2))



(deftest test-location-desig-pose
    ;; test that location designator resolution works for desig property pose
    (with-fixture with-ros-node ()
        (with-designators
            (( my-desig
               (location `((pose
                            ,(tf:make-pose-stamped "/map" 0.0
                                                   (tf:make-3d-vector 1.0 1.0 0.0)
                                                   (tf:euler->quaternion :az (/ pi 2.0))))))))
          (let ((ref (reference my-desig)))
            (list
             (tf:x (tf:origin ref))
             (tf:y (tf:origin ref))
             (tf:z (tf:origin ref))))))
  (1.0 1.0 0.0))

(deftest test-action-desig-reach-loc
    ;; test that action designator resolution works for desig property pose
    (with-fixture with-ros-node ()
      (let (( target (tf:make-pose-stamped "/calib_kuka_arm_base_link" 0.0
                                           (tf:make-3d-vector 0.8 0.18 0.5)
                                           (tf:make-quaternion 0 0 0 1))))
        (with-designators  ((obj-loc (location `((pose ,target))))
                            (reach-loc
                             (action `((reach-location ,obj-loc)))))
          (type-of (reference reach-loc)))))
  KDL_ARM_KINEMATICS-SRV:GETWEIGHTEDIK-RESPONSE)

;; tells robot to move to pose
(deftest test-navigation-tutorial-pose
  (with-fixture with-cram-init ()
    (top-level (with-designators
                   (( loc-desig
                      (location `((pose
                                   ,(tf:make-pose-stamped "/map" 0.0
                                                          (tf:make-3d-vector 1.0 1.0 0.0)
                                                          (tf:euler->quaternion :az (/ pi 2.0))))))))
                 (pursue
                   (maybe-run-process-modules)
                   (cram-process-modules:pm-execute :navigation loc-desig)))))
  ;; expected result:
  1;; means ok
  ;;;TODO, check robot is at pose
  )

;; requires adapto-designators, which is not part of adapto-executive, yet
;; (deftest test-location-desig-costmap
;;   (with-designators
;;       ((obj-loc (location `((pose ,(tf:make-pose-stamped "/map" 0.0
;;                                                          (tf:make-3d-vector 1.0 -1.0 0.1)
;;                                                          (tf:euler->quaternion :az (/ pi 2.0)))))))
;;        (stand-loc
;;         (location `((close-to ,obj-loc)))))
;;     (reference stand-loc))
;;   ;; expected result:
;;   nil)

;; moves ptu to pose
(deftest test-ptu-tutorial-pose
  (with-fixture with-cram-init ()
    (top-level (with-designators
                   ((my-desig
                     (location `((pose
                                  ,(tf:make-pose-stamped "/map" 0.0
                                                         (tf:make-3d-vector 1.0 1.0 0.0)
                                                         (tf:euler->quaternion :az (/ pi 2.0))))))))
                 (pursue
                   (cram-plan-library:maybe-run-process-modules)
                   (cram-process-modules:pm-execute :ptu my-desig)))))
  ;; expected result:
  1;; means ok
)

;; moves ptu forward
(deftest test-ptu-tutorial-forward
  (with-fixture with-cram-init ()
    (top-level (pursue
                 (maybe-run-process-modules)
                 (achieve `(looking-at :forward)))))
  ;; expected result:
  1;; means ok
)

;; moves arm
(deftest test-manip-reach-location
    (with-fixture with-cram-init ()
      (let ((target (tf:make-pose-stamped "/calib_kuka_arm_base_link" 0.0
                                   (tf:make-3d-vector 0.8 0.18 0.5)
                                   (tf:make-quaternion 0 0 0 1))))
        (top-level (with-designators  ((obj-loc (location `((pose,target))))
               (reach-loc
                (action `((reach-location ,obj-loc)))))

             (pursue
               (cram-plan-library:maybe-run-process-modules)
               (cram-process-modules:pm-execute :manipulation reach-loc))))))
  1;; means ok
  )