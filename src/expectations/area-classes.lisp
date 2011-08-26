(in-package :ad-exe)

;; define area classes for validation if a pose is inside an area

;; superclass of all areas
(defclass area () ())

;; circle defined by x,y and radius
(defclass circle (area)
  ((x :initarg :x :accessor x)
   (y :initarg :y :accessor y)
   (radius :initarg :radius :accessor radius)))

(defmethod inside-area (area pose)
  (error "[area-classes.lisp] - No inside-area function defined for this kind of area"))

(defmethod inside-area ((area circle) pose)
  (< (cl-transforms:v-dist (cl-transforms:make-3d-vector (tf:x (cl-transforms:origin pose))
                                                         (tf:y (cl-transforms:origin pose))
                                                         0)
                           (cl-transforms:make-3d-vector (x area) (y area) 0))
     (radius area)))