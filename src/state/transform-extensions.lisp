(in-package :cl-transforms)

;; add accessor functions for pose
(defgeneric (setf origin) (value pose))
(defmethod (setf origin) (value (ps pose))
  (setf (slot-value ps 'origin) value))

(defgeneric (setf orientation) (value pose))
(defmethod (setf orientation) (value (ps pose))
  (setf (slot-value ps 'orientation) value))

;; add accessor functions for points
(defgeneric (setf x) (value point))
(defgeneric (setf y) (value point))
(defgeneric (setf z) (value point))


(defmethod (setf x) (value (point 3d-vector))
  (setf (slot-value point 'x) value))

(defmethod (setf y) (value (point 3d-vector))
  (setf (slot-value point 'y) value))

(defmethod (setf z) (value (point 3d-vector))
  (setf (slot-value point 'z) value))


(defmethod (setf x) (value (v vector))
  (setf (aref v 0) value))

(defmethod (setf y) (value (v vector))
  (setf (aref v 1) value))

(defmethod (setf z) (value (v vector))
  (setf (aref v 2) value))


;; add accessor functions for quaternions
(defgeneric (setf w) (value quaternion))


(defmethod (setf x) (value (quat quaternion))
  (setf (slot-value quat 'x) value))

(defmethod (setf y) (value (quat quaternion))
  (setf (slot-value quat 'y) value))

(defmethod (setf z) (value (quat quaternion))
  (setf (slot-value quat 'z) value))

(defmethod (setf w) (value (quat quaternion))
  (setf (slot-value quat 'w) value))


(defmethod (setf w) (value (v vector))
  (setf (aref v 3) value))


(in-package :cl-tf)

;; add accessor functions for stamped
(defgeneric (setf stamp) (value stamped))

(defmethod (setf stamp) (value (st stamped))
  (setf (slot-value st 'stamp) value))

