(in-package :ad-exe)

;; Move Jido and validate expectations
(def-top-level-plan expectation-test-1()
  (cram-execution-trace:enable-fluent-tracing)
  ;; (cet:enable-auto-tracing)
  (start-statevar-update)
  ;; Note: start-statevar-update is asynchronous! generate-expectations should somehow check if human and/or
  ;; robot is already percieved and when last detection has been!
  (generate-location-expectations)

   (with-designators 
                  (( loc-desig 
                     (location `((pose 
                                 ,(tf:make-pose-stamped "/map" 0.0 
                                   (tf:make-3d-vector -4.6 -1.91 0.0) 
                                   (tf:euler->quaternion :az (/ pi 2.0))))))))
             (par
               (maybe-run-process-modules)
               (start-expectation-validation)
               (achieve `(loc robot ,loc-desig))
               ;; (cram-process-modules:pm-execute :navigation loc-desig)
               )))

(def-top-level-plan movable-test-1()
  (start-statevar-update)
  ;; Note: start-statevar-update is asynchronous! generate-expectations should somehow check if human and/or
  ;; robot is already percieved and when last detection has been!
  (generate-object-expectations)

   (with-designators 
                  (( loc-desig 
                     (location `((pose 
                                 ,(tf:make-pose-stamped "/map" 0.0 
                                   (tf:make-3d-vector -5.739 -1.206 0.01) 
                                   (tf:euler->quaternion :az (/ pi 2.0))))))))
             (par
               (maybe-run-process-modules)
               (start-expectation-validation)
               (cram-process-modules:pm-execute :navigation loc-desig))))

;; Generate watchdog that waits until a navigation process module executes an action
;; and  then generate an navigation expectation


;; TEST: Navigate and try to measure how long it already takes
(def-top-level-plan navigation-task()
  (start-statevar-update)

   (with-designators 
                  (( loc-desig 
                     (location `((pose 
                                 ,(tf:make-pose-stamped "/map" 0.0 
                                   (tf:make-3d-vector -5.0 -5.0 0.0) 
                                   (tf:euler->quaternion :az (/ pi 2.0))))))))
             (par
               (maybe-run-process-modules)
               (start-navigation-watchdog)
               (cram-process-modules:pm-execute :navigation loc-desig)
               ;; Check status of navigation-pm
               (format t "Status of Nav-PM: ~s~%" [cpm:pm-status :navigation]))))