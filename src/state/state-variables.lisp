(in-package :ad-exe)

(create-global-structure :robot)
(create-global-structure :human)
(create-global-structure :furniture)
(create-global-structure :kitchen-object)



(addgv :robot 'jido
  (make-fluent :name 'jido
               :value (make-instance 'jido
                        :pose (tf:make-pose-stamped
                                "map"                         ; frame-id
                                0.0                           ; stamp
                                (tf:make-3d-vector 0 0 0)     ; translation/origin
                                (tf:make-quaternion 0 0 0 1)) ; rotation/orientation
                        :width 0.71
                        :depth 0.66
                        :height 1.6)))

(addgv :human 'louis
  (make-fluent :name 'louis
               :value (make-instance 'human
                        :pose (tf:make-pose-stamped
                                "map"
                                0.0
                                (tf:make-3d-vector 0 0 0)
                                (tf:make-quaternion 0 0 0 1)))))

;;; Objekte -> werden in state-update erzeugt
