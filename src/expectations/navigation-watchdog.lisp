(in-package :ad-exe)

;; Subscribe to planner, and get plan of global navigation
;; Length of the array returns strange values...
;; TODO: Iterate through array and calculate lengths between waypoints
(defun calculate-time (data)
  (format t ".")
  (format t "Found path of length ~s~%" (length (nav_msgs-msg:poses data)))
  ;; calculate distance btw. poses

  (format t "loop: ~s~%"
          (loop for i from 1 to (- 1 (length (nav_msgs-msg:poses data))) collect i))
  
  (format t "Distance: ~s~%" (cl-transforms:v-dist
                              (cl-transforms::make-3d-vector
                               (geometry_msgs-msg:x (geometry_msgs-msg:position (geometry_msgs-msg:pose (elt (nav_msgs-msg:poses data) 0))))
                               (geometry_msgs-msg:y (geometry_msgs-msg:position (geometry_msgs-msg:pose (elt (nav_msgs-msg:poses data) 0))))
                               (geometry_msgs-msg:z (geometry_msgs-msg:position (geometry_msgs-msg:pose (elt (nav_msgs-msg:poses data) 0)))))
                              (cl-transforms:make-3d-vector
                               (geometry_msgs-msg:x (geometry_msgs-msg:position (geometry_msgs-msg:pose (elt (nav_msgs-msg:poses data) 2))))
                               (geometry_msgs-msg:y (geometry_msgs-msg:position (geometry_msgs-msg:pose (elt (nav_msgs-msg:poses data) 2))))
                               (geometry_msgs-msg:z (geometry_msgs-msg:position (geometry_msgs-msg:pose (elt (nav_msgs-msg:poses data) 2))))
                               )
                              ))
  
  ;; (format t "~s~%" (elt (nav_msgs-msg:poses data) 1))
  (sleep 2)
  )

;; Wait until a navigation-action starts, then generate an expectation
(let ((last_navp nil) (subscriber nil))
  (defun start-navigation-watchdog ()
    ;; Check if navigation is running
    (unless (eq [cpm:pm-status :navigation] :WAITING)
      (format t "-")
      ;; check if navigaton action has just started and subscribe to navigation plan
      (when (eq last_navp 0)
        (format t "STARTED NAVIGATION:")
        (setf subscriber (roslisp:subscribe "/human_aware_plan" "nav_msgs/Path" #'calculate-time))
        ))
    ;; Check if navigation-action has ended and unsubscribe
    (unless (eq [cpm:pm-status :navigation] :RUNNING)
      (when (eq last_navp 1)
        (roslisp:unsubscribe subscriber)
        (format t "-:NAVIGATION ENDED")))
    ;; Save last status 
    (if (eq [cpm:pm-status :navigation] :RUNNING)
      (setf last_navp 1)
      (setf last_navp 0))
    (sleep 1)
    (start-navigation-watchdog)))
    