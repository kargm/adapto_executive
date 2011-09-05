(in-package :ad-exe)

;; Update human position (map from nav_msgs/Odometry to PoseStamped)
(defun store-human-position-data (data)
  (setf (pose (value (getgv :human 'louis)))
        (tf:make-pose-stamped
         "map"
         (roslisp:ros-time)
         (cl-transforms:make-3d-vector
          (geometry_msgs-msg:x (geometry_msgs-msg:position (geometry_msgs-msg:pose data)))
          (geometry_msgs-msg:y (geometry_msgs-msg:position (geometry_msgs-msg:pose data)))
          (geometry_msgs-msg:z (geometry_msgs-msg:position (geometry_msgs-msg:pose data))))
         (cl-transforms:make-quaternion
          (geometry_msgs-msg:x (geometry_msgs-msg:orientation (geometry_msgs-msg:pose data)))
          (geometry_msgs-msg:y (geometry_msgs-msg:orientation (geometry_msgs-msg:pose data)))
          (geometry_msgs-msg:z (geometry_msgs-msg:orientation (geometry_msgs-msg:pose data)))
          (geometry_msgs-msg:w (geometry_msgs-msg:orientation (geometry_msgs-msg:pose data))))))
  (pulse (getgv :human 'louis)))

;; Update robot position (TODO: should also be possible shorter...)
(defun store-position-data (data)
  (setf (pose (value (getgv :robot 'jido)))
        (tf:make-pose-stamped
         "map"
        (std_msgs-msg:stamp (nav_msgs-msg:header data))
        (cl-transforms:make-3d-vector 
         (geometry_msgs-msg:x (geometry_msgs-msg:position (geometry_msgs-msg:pose (nav_msgs-msg:pose data))))
         (geometry_msgs-msg:y (geometry_msgs-msg:position (geometry_msgs-msg:pose (nav_msgs-msg:pose data))))
         (geometry_msgs-msg:z (geometry_msgs-msg:position (geometry_msgs-msg:pose (nav_msgs-msg:pose data)))))
        (cl-transforms:make-quaternion
         (geometry_msgs-msg:x (geometry_msgs-msg:orientation (geometry_msgs-msg:pose (nav_msgs-msg:pose data))))
         (geometry_msgs-msg:y (geometry_msgs-msg:orientation (geometry_msgs-msg:pose (nav_msgs-msg:pose data))))
         (geometry_msgs-msg:z (geometry_msgs-msg:orientation (geometry_msgs-msg:pose (nav_msgs-msg:pose data))))
         (geometry_msgs-msg:w (geometry_msgs-msg:orientation (geometry_msgs-msg:pose (nav_msgs-msg:pose data)))))))
  (pulse (getgv :robot 'jido)))

;; Creates one object from object data
(defun create-object (name type x y z qx qy qz qw )       
  (when (null  (find-class type NIL))
    (warn "[state-update.lisp]: Class for type ~a not defined. Mapped to type entity~%" type) (setf type 'entity))
  (addgv :kitchen-object name
         (make-fluent :name name
                      :value (make-instance type
                               :pose (tf:make-pose-stamped
                                      "map"                         ; frame-id
                                      (roslisp:ros-time)            ; stamp
                                      (tf:make-3d-vector x y z)     ; translation/origin
                                      (tf:make-quaternion qx qy qz qw)))))) ; rotation/orientation

;; Updates Object data from list of objects. Objects have format: ( Name Description x y z qx qy qz qw ) (qx, qy, qz, qw refer to objects' rotation as qaternion )
(defun store-object-data (data)
  (let ( (*package* (find-package :ad-exe)) )
    (dolist (obj-data (read-from-string (std_msgs-msg:data data)))
      (destructuring-bind (name type x y z qx qy qz qw) obj-data      
        (cond  ((isgv :kitchen-object name)
                (setf (pose (value (getgv :kitchen-object name)))
                  (tf:make-pose-stamped
                   "map"
                   (roslisp:ros-time)
                   (cl-transforms:make-3d-vector x y z)
                   (cl-transforms:make-quaternion qx qy qz qw)))
                (pulse (getgv :kitchen-object name)))
               (t (create-object name type x y z qx qy qz qw)))))))
        
;;; Objekte:
;;; - am Anfang einmal Ground Truth topic abhören (dann unsubscriben), dabei statevars für Objekte erzeugen
;;; - dann Topic mit kamera-gefilterten Daten zum Update verwenden

;; topics stores arguments for roslisp::subscribe function (topic, callback-funtion). 
(let ( (topics `(("/Jido/Pose_sensor" "nav_msgs/Odometry" store-position-data)
                 ("/Human/Pose" "geometry_msgs/PoseStamped" store-human-position-data)
                 ("/Jido/Object_tracker" "std_msgs/String" store-object-data)))
       (subscribers '()) )
  (defun start-statevar-update ()
    (dolist (top topics)
      (destructuring-bind (topic topic-type callback) top
        (push (roslisp:subscribe topic topic-type (symbol-function callback)) subscribers)))
    (sleep 2))

  (defun stop-statevar-update ()
    (when subscribers
      (roslisp:unsubscribe (pop subscribers))
      (stop-statevar-update)))
)

;(setf (gethash 'start-adapto-statevar-update cram-roslisp-common::*ros-init-functions*)
;      #'start-statevar-update)
