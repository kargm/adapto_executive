(in-package :ad-exe)

;; Here we define the instances of our expectations and put them into a global structure
;; x,y and pose of location expectations are fluents since they are subject to change
;; For example here: An expectation about the human beeing no more than 6 meters away from Jido
(defun generate-location-expectations ()
  (create-global-structure :expectations)
  (addgv :expectations 'louis-near-jido (make-instance 'position-expectation
                                    :area (make-instance 'moving-circle
                                            :radius 5
                                            :x (fl-funcall #'(lambda (fl-x) (tf:x (tf:origin (pose fl-x)))) (getgv :robot 'jido))
                                            :y (fl-funcall #'(lambda (fl-y) (tf:y (tf:origin (pose fl-y)))) (getgv :robot 'jido)))
                                    :pose (fl-funcall #'pose (getgv :human 'louis))))

  (addgv :expectations 'louis-near-red-cube (make-instance 'position-expectation
                                              :area (make-instance 'moving-circle
                                                      :radius 5
                                                      :x (fl-funcall #'(lambda (fl-x) (tf:x (cl-transforms:origin (pose fl-x)))) (getgv :kitchen-object 'red_cube))
                                                      :y (fl-funcall #'(lambda (fl-y) (tf:y (cl-transforms:origin (pose fl-y)))) (getgv :kitchen-object 'red_cube)))
                                              :pose (fl-funcall #'pose (getgv :human 'louis))))
  
  (addgv :expectations 'louis-near-desk (make-instance 'position-expectation
                                              :area (make-instance 'moving-circle
                                                      :radius 5
                                                      :x (fl-funcall #'(lambda (fl-x) (tf:x (cl-transforms:origin (pose fl-x)))) (getgv :kitchen-object 'desk_2))
                                                      :y (fl-funcall #'(lambda (fl-y) (tf:y (cl-transforms:origin (pose fl-y)))) (getgv :kitchen-object 'desk_2)))
                                              :pose (fl-funcall #'pose (getgv :human 'louis)))))

(defun generate-object-expectations ()
   (create-global-structure :expectations)
   (addgv :expectations 'red-cube-static (make-instance 'object-expectation
                                           :object (make-instance 'kitchen-object
                                                     :pose (pose [getgv :kitchen-object 'red_cube]))
                                           :flexible NIL)))

(defun clean-expectations ()
  (clear-global-structure :expectations))