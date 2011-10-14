(in-package :ad-exe)

;; Subscribe to planner, and get plan of global navigation
;; Length of the array returns strange values...
;; TODO: Iterate through array and calculate lengths between waypoints
(defun calculate-time (data)
  (let ((distances-waypoints nil) (distance-air nil))
  (format t ".")
  ;; (format t "Found path of length ~s~%" (length (nav_msgs-msg:poses data)))

  ;; calculate distance btw. poses of the global plan
  (setf distances-waypoints 
          (loop for i from 1 to (- (length (nav_msgs-msg:poses data)) 1) collect
               (cl-transforms:v-dist
                (cl-transforms::make-3d-vector
                 (geometry_msgs-msg:x (geometry_msgs-msg:position (geometry_msgs-msg:pose (elt (nav_msgs-msg:poses data) (- i 1)))))
                 (geometry_msgs-msg:y (geometry_msgs-msg:position (geometry_msgs-msg:pose (elt (nav_msgs-msg:poses data) (- i 1)))))
                 (geometry_msgs-msg:z (geometry_msgs-msg:position (geometry_msgs-msg:pose (elt (nav_msgs-msg:poses data) (- i 1))))))
                (cl-transforms:make-3d-vector
                 (geometry_msgs-msg:x (geometry_msgs-msg:position (geometry_msgs-msg:pose (elt (nav_msgs-msg:poses data) i))))
                 (geometry_msgs-msg:y (geometry_msgs-msg:position (geometry_msgs-msg:pose (elt (nav_msgs-msg:poses data) i))))
                 (geometry_msgs-msg:z (geometry_msgs-msg:position (geometry_msgs-msg:pose (elt (nav_msgs-msg:poses data) i))))
                 )
                )))

  ;; calculate distance between start- and endpose of the plan
  (setf distance-air
        (cl-transforms:v-dist
         (cl-transforms::make-3d-vector
          (geometry_msgs-msg:x (geometry_msgs-msg:position (geometry_msgs-msg:pose (elt (nav_msgs-msg:poses data) 0))))
          (geometry_msgs-msg:y (geometry_msgs-msg:position (geometry_msgs-msg:pose (elt (nav_msgs-msg:poses data) 0))))
          (geometry_msgs-msg:z (geometry_msgs-msg:position (geometry_msgs-msg:pose (elt (nav_msgs-msg:poses data) 0)))))
         (cl-transforms:make-3d-vector
          (geometry_msgs-msg:x (geometry_msgs-msg:position (geometry_msgs-msg:pose (elt (nav_msgs-msg:poses data) (- (length (nav_msgs-msg:poses data)) 1)))))
          (geometry_msgs-msg:y (geometry_msgs-msg:position (geometry_msgs-msg:pose (elt (nav_msgs-msg:poses data) (- (length (nav_msgs-msg:poses data)) 1)))))
          (geometry_msgs-msg:z (geometry_msgs-msg:position (geometry_msgs-msg:pose (elt (nav_msgs-msg:poses data) (- (length (nav_msgs-msg:poses data)) 1)))))
          )
         )
        )
  (format t "Sum of waypoint-distances: ~s~%" (apply '+ distances-waypoints))
  (format t "Air-distance:              ~s~%" distance-air)
  (format t "Difference: ~s~% ---------------- ~%" (- (apply '+ distances-waypoints) distance-air))
  (sleep 2)
  ))

;; Wait until a navigation-action starts, then generate an expectation (TODO)
(let ((last_navp nil) (subscriber nil))
  (defun start-navigation-watchdog ()
    ;; Check if navigation is running
    (unless (eq [cpm:pm-status :navigation] :WAITING)
      ;; (format t "-")
      ;; check if navigaton action has just started and subscribe to navigation plan
      (when (eq last_navp 0)
        (format t "STARTED NAVIGATION:")
        (setf subscriber (roslisp:subscribe "/human_aware_plan" "nav_msgs/Path" #'calculate-time :max-queue-length 1))
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
    