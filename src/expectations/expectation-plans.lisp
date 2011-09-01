(in-package :ad-exe)

;; Move Jido and validate expectations
(def-top-level-plan expectation-test-1()
  (start-statevar-update)
  ;; Note: start-statevar-update is asynchronous! generate-expectations should somehow check if human and/or
  ;; robot is already percieved and when last detection has been!
  (generate-location-expectations)

   (with-designators 
                  (( loc-desig 
                     (location `((pose 
                                 ,(tf:make-pose-stamped "/map" 0.0 
                                   (tf:make-3d-vector -5.0 -7.0 0.0) 
                                   (tf:euler->quaternion :az (/ pi 2.0))))))))
             (par
               (maybe-run-process-modules)
               (start-expectation-validation)
               (cram-process-modules:pm-execute :navigation loc-desig))))

(def-top-level-plan movable-test-1()
  (start-statevar-update)
  ;; Note: start-statevar-update is asynchronous! generate-expectations should somehow check if human and/or
  ;; robot is already percieved and when last detection has been!
  (generate-object-expectations)

   (with-designators 
                  (( loc-desig 
                     (location `((pose 
                                 ,(tf:make-pose-stamped "/map" 0.0 
                                   (tf:make-3d-vector -5.0 -7.0 0.0) 
                                   (tf:euler->quaternion :az (/ pi 2.0))))))))
             (par
               (maybe-run-process-modules)
               (start-expectation-validation)
               (cram-process-modules:pm-execute :navigation loc-desig))))