(in-package :ad-exe)

;; Subscribe to planner, and get plan of global navigation
;; Length of the array returns strange values...
;; TODO: Iterate through array and calculate lengths between waypoints
(defun calculate-time (data)
  (format t "~s~%" (length (nav_msgs-msg:poses data)))
  (sleep 2)
  )


(defun get-nav-plan ()
  (roslisp:subscribe "/human_aware_plan" "nav_msgs/Path" #'calculate-time)
  )

;; Wait until a navigation-action starts, then generate an expectation
(let ((last_navp nil))
  (defun start-navigation-watchdog ()
    ;; Check if navigation is running
    (unless (eq [cpm:pm-status :navigation] :WAITING)
      (format t "-")
      ;; check if navigaton action has just started
      (when (eq last_navp 0)
        (format t "STARTED NAVIGATION:")
        (get-nav-plan)))

    ;; Check if nav-pm is waiting
    (unless (eq [cpm:pm-status :navigation] :RUNNING)
      (if (eq last_navp 1)
        (format t "-:NAVIGATION ENDED")))
    ;; Save last status 
    (if (eq [cpm:pm-status :navigation] :RUNNING)
      (setf last_navp 1)
      (setf last_navp 0))
    (sleep 1)
    (start-navigation-watchdog)))
    