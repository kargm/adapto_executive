(in-package :ad-exe)

;; general classes
(defclass geometrical-form ()
  ( (pose :initarg :pose :accessor pose) ))

(defclass joint ()
  ( (first-part :initarg :first-part :accessor first-part)
    (second-part :initarg :second-part :accessor second-part)
    (angle :initform 0 :initarg :angle :accessor angle) ))

(defgeneric point-occupied-by-object (3d-point geometrical-form))
(defgeneric free-space-distance-between-objects (geometrical-form-1 geometrical-form-2))


;; basic geometrical shapes
(defclass cuboid (geometrical-form)
  ( (width :initform 0 :initarg :width :accessor width)
    (depth :initform 0 :initarg :depth :accessor depth)
    (height :initform 0 :initarg :height :accessor height) ))

(defclass cylinder (geometrical-form)
  ( (radius :initform 0 :initarg :radius :accessor radius)
    (height :initform 0 :initarg :height :accessor height) ))


;; robot shapes
(defclass jido-base-form (cuboid) ())

(defclass kuka-arm-form ()
  ( (arm-elements :initform () :initarg :arm-elements :accessor arm-elements)
    (joints :initform () :initarg :joints :accessor joints) ))

;; specific object shapes

(defclass chair-form (cuboid)
  ( (backrest-height :initform 0 :initarg :backrest-height :accessor backrest-height) ))

(defclass spoon-like (geometrical-form)
  ( (thickness :initform 0 :initarg :thickness :accessor thickness)
    (grip-length :initform 0 :initarg :grip-length :accessor grip-length)
    (grip-width :initform 0 :initarg :grip-width :accessor grip-width)
    (upper-part-length :initform 0 :initarg :upper-part-length :accessor upper-part-length)
    (upper-part-width :initform 0 :initarg :upper-part-width :accessor upper-part-width) ))

