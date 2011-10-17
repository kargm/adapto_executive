(in-package :ad-exe)

;; This file defines the classes of expectations that can be used

;; General expectations: Superclass of all expectations. We might add some common slots there if needed
(defclass expectation () ())

;; Expectations about the position of things defined by an area and and a poseStamped
(defclass position-expectation (expectation)
  ((area :initarg :area :accessor area)
   (pose :initarg :pose :accessor pose)))

(defclass object-expectation (expectation)
  ((object :initarg :object :accessor object)
   (flexible :initarg :flexible :accessor flexible)))

(defclass action-expectation (expectation)
  ((action-type :initarg :action-type :accessor action-type)
   (duration :initarg :duration :accessor duration)
   (start-time :initarg :start-time :accessor start-time)))

(defclass navigation-action-expectation (action-expectation)
  ((action-type :initarg :action-type :accessor action-type :initform 'navigation )
   (path-length :initarg :path-length :accessor path-length)
   (avg-speed :initarg :avg-speed :accessor :avg-speed)))

;; Validation methods of expectations MUST always return number between 0 or 1. 

(defgeneric validate-expectation (x))

(defmethod validate-expectation (x) (error "[expectation-classes.lisp] - No validation-function defined for this type"))

;; For the moment return 1 if pose is inside area, 0 if not
(defmethod validate-expectation ((exp position-expectation))
  (if (inside-area (area exp) (pose exp))
    1
    0))

;; Return 0 if object that is not flexible has moved, otherwise return 1  
(defmethod validate-expectation ((exp object-expectation))
   (cond
     ((and (has-moved (object exp)) (not (flexible exp)))
       (format t "An object moved unexpectedly...~%")
       0)
     (t 1)))

(defmethod validate-expectation ((exp navigation-action-expectation))
  (let ((time-since-start (- (roslisp:ros-time) (start-time exp))))
    ;; (format t "Navigation-action should take ~s seconds for path of length ~s ~%" (duration exp) (path-length exp))
    ;; (format t "Navigation-action in progress since ~s seconds~%" time-since-start)
    ;; If navigation takes longer than expexted
    (cond
      ;; As long as action within the expected time, return 1
      ((> (- (duration exp) time-since-start) 0) 1)
      ;; expected time has passed but not more than 1.25 the time
      ((and (< (- (duration exp) time-since-start) 0)                             ;; diff smaller 0
            (> (- (duration exp) time-since-start) (* -1 (/ (duration exp) 4))))  ;; and bigger -¼*duration
        (format t "Navigation takes a little longer, still no reason to worry...")
       0.75) ;; return 0.75
      ;; expected time has passed but not more than 1.5 the time
      ((and (< (- (duration exp) time-since-start) (* -1 (/ (duration exp) 4)) )                             ;; diff smaller 0
            (> (- (duration exp) time-since-start) (* -1 (/ (duration exp) 2))))  ;; and bigger -¼*duration
        (format t "There could be someting wrong with my navigation-plan....")
       0.5) ;; return 0.75
      ;; expected time has passed but not more than 2x the time
      ((and (< (- (duration exp) time-since-start) (* -1 (/ (duration exp) 2)) )                             ;; diff smaller 0
            (> (- (duration exp) time-since-start) (* -1 (/ (duration exp) 1))))  ;; and bigger -¼*duration
        (format t "I think there IS something wrong with my navigation")
       0.25) ;; return 0.75
      ((< (- (duration exp) time-since-start) (* -1 (duration exp)))
        (format t "Navigation alread takes 2 times longer... time to PANIC!!!!")
       0)
      )
  ))