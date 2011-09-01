(in-package :ad-exe)

;; Here we define the instances of our expectations and put them into a global structure
;; For example here: An expectation about the human beeing no more than 6 meters away from Jido
(defun generate-location-expectations ()
  (create-global-structure :expectations)
  (addgv :expectations 'louis-near-jido (make-instance 'position-expectation
                                    :area (make-instance 'circle
                                            :radius 5
                                            :x (tf:x (tf:origin (pose [getgv :robot 'jido])))
                                            :y (tf:y (tf:origin (pose [getgv :robot 'jido]))))
                                    :pose (pose [getgv :human 'louis])))
  (addgv :expectations 'louis-near-red-cube (make-instance 'position-expectation
                                              :area (make-instance 'circle
                                                      :radius 5
                                                      :x (tf:x (tf:origin (pose [getgv :kitchen-object 'red_cube])))
                                                      :y (tf:y (tf:origin (pose [getgv :kitchen-object 'red_cube]))))
                                              :pose (pose [getgv :human 'louis])))
  (addgv :expectations 'louis-near-red-chair (make-instance 'position-expectation
                                              :area (make-instance 'circle
                                                      :radius 5
                                                      :x (tf:x (tf:origin (pose [getgv :kitchen-object 'red_chair_1])))
                                                      :y (tf:y (tf:origin (pose [getgv :kitchen-object 'red_chair_1]))))
                                              :pose (pose [getgv :human 'louis]))))

(defun generate-object-expectations ()
   (create-global-structure :expectations)
   (addgv :expectations 'red-cube-static (make-instance 'object-expectation
                                           :object (make-instance 'kitchen-object
                                                     :pose (pose [getgv :kitchen-object 'red_cube]))
                                           :flexible NIL)))

(defun clean-expectations ()
  (clear-global-structure :expectations))