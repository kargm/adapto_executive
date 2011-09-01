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

(defmethod validate-expectation (x) (error "[expectation-classes.lisp] - No validation-function defined for this type"))

;; For the moment return 1 if pose is inside area, 0 if not
(defmethod validate-expectation ((exp position-expectation))
  (if (inside-area (area exp) (pose exp))
    1
    0))

;; Return 0 if object that is not flexible has moved, otherwise return 1  
(defmethod validate-expectation ((exp object-expectation))
   (if (and (has-moved (object exp)) (not (flexible exp)))
       0
       1))