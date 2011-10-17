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


;; Navigate to 3 points and monitor time of navigation-action
(def-top-level-plan navigation-task()
  (start-statevar-update)
  (create-global-structure :expectations)
  ;; (generate-location-expectations)
  
  (with-designators 
      (( loc1-desig 
         (location `((pose 
                      ,(tf:make-pose-stamped "/map" 0.0 
                                             (tf:make-3d-vector 2.0 0.0 0.0) 
                                             (tf:euler->quaternion :az (/ pi 2.0)))))))
       ( loc2-desig 
         (location `((pose 
                      ,(tf:make-pose-stamped "/map" 0.0 
                                             (tf:make-3d-vector 2.0 2.0 0.0) 
                                             (tf:euler->quaternion :az (/ pi 2.0)))))))

       ( loc3-desig 
         (location `((pose 
                      ,(tf:make-pose-stamped "/map" 0.0 
                                             (tf:make-3d-vector 2.0 -4.0 0.0) 
                                             (tf:euler->quaternion :az (/ pi 2.0))))))))
    
    (par
      (maybe-run-process-modules)
      (start-navigation-watchdog)
      (seq 
        (cram-process-modules:pm-execute :navigation loc1-desig)
        (sleep 2)
        (cram-process-modules:pm-execute :navigation loc2-desig)
        (sleep 2)
        (cram-process-modules:pm-execute :navigation loc3-desig))
      (start-expectation-validation))
      ))