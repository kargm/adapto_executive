(in-package :ad-exe)

;; general things
(defclass thing (geometrical-form)
  ( (id :initarg :id :reader id) ))


;; agents
(defclass agent (thing) ())

(defclass human (agent) ())

(defclass robot (agent) ())

(defclass jido (robot jido-base-form kuka-arm-form)
  ( (arm-base-joint :initarg :arm-base-joint :accessor arm-base-joint) ))


;; objects
(defclass entity (thing) ())

(defclass cube (entity cuboid) ())

; furniture
(defclass furniture (entity) ())

(defclass cuboard (furniture cuboid)
  ( (doors :initform () :initarg :doors :accessor doors)
    (door-joints :initform () :initarg :door-joints :accessor door-joints) ))

(defclass chair (furniture chair-form) ())

(defclass table (furniture cuboid) ())


; cutlery
(defclass cutlery (entity) ())

(defclass knife (cutlery cuboid) ())

(defclass fork (cutlery spoon-like) ())

(defclass spoon (cutlery spoon-like) ())

; tableware
(defclass tableware (entity) ())

(defclass plate (tableware cylinder) ())

(defclass cup (tableware cylinder)
  ( (handle-position :initform :handle-position :accessor handle-position) ))
