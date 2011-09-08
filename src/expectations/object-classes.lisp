(in-package :ad-exe)

;; define area classes for validation if a pose is inside an area

;; superclass of all objects
(defclass object () ())

(defclass kitchen-object (object)
  ((pose :initarg :pose :accessor pose)
   (last-detection :initarg :last-detection :initform NIL :accessor last-detection)))

(defgeneric has-moved (object))

(defmethod has-moved (object)
  (declare (ignore object))
  (error "[object-classes.lisp] - No has-moved function defined for this kind of object"))

;; Checks if object has moved since last detection. Returns T or NIL
(defmethod has-moved ((object kitchen-object))
  (let ((has-moved-p
        (unless (null (last-detection object))
          (format t "last-detection: ~s ~%" (cl-transforms:origin (last-detection object)))
          (format t "pose: ~s ~%" (cl-transforms:origin [(pose object)]))
          (> (cl-transforms:v-dist (cl-transforms:origin [(pose object)]) (cl-transforms:origin (last-detection object)))
             0.1 ))))
    (setf (last-detection object) [(pose object)])
    (format t "has-moved-p: ~s ~%" has-moved-p) 
    has-moved-p))