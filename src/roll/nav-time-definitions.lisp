(in-package :ad-exe)

;;; AUXILIARY FUNCTIONS

(defgeneric angle-towards-point (p1 p2))

(defmethod angle-towards-point ((p1 tf:pose) (p2 tf:pose))
  "calculates angle between x-axis and straight line towards p2 between -pi and pi"
  (tf:normalize (tf:euler->quaternion :az (atan (- (tf:y (tf:origin p2)) (tf:y (tf:origin p1)))
                                                (- (tf:x (tf:origin p2)) (tf:x (tf:origin p1)))))))

(eval-when (:execute :load-toplevel)
  ;; Experiences

  ; raw experience
  (roll:define-raw-experience navigation-time-exp
      :specification (nil
                       :task (:plan at-location)
                       :begin ( (timestep (get-universal-time))
                                (start-pose (pose [getgv :robot 'jido]))
                                (goal-pose (:desig-value 'pose)) )
                       :end ( (timestep (get-universal-time)) )
                       :interval-parameters (:frequency 1
                                             :contains-objects T)
                       :interval ( (robot-pose-x (cl-tf:x (cl-tf:origin (pose [getgv :robot 'jido]))))
                                   (robot-pose (pose [getgv :robot 'jido])) )))


  ; database experience
  (roll:define-abstract-experience nav-time-abstract-exp
    :parent-experience navigation-time-exp
    :specification (roll:with-binding ( (p1 (:var start-pose :begin))
                                        (p2 (:var goal-pose :begin))
                                        (timediff (- (:var timestep :end)
                                                     (:var timestep :begin)))
                                        (offset-angle (angle-towards-point p1 p2)) )
                     (roll:with-filter (plusp timediff)
                       (nil
                         :begin ( (dist (tf:v-dist (tf:origin p1) (tf:origin p2)))
                                  (start-phi (tf:angle-between-quaternions offset-angle (tf:orientation p1)))
                                  (end-phi (tf:angle-between-quaternions offset-angle (tf:orientation p2))) )
                                  ; Rechnungen evtl. nochmal prüfen, Vorzeichen könnte falsch sein
                         :end ( (navigation-time timediff) ))))
    :experience-class roll:database-experience
    :experience-class-initargs
      (:database (make-instance 'roll:mysql-database :host "sqlradig" :user "kirsch"
                                                     :user-pw "rolagi" :name "rollagilo")))

  ; test showing abstracted data
  (roll:define-abstract-experience navigation-time-abstract-exp-format
    :parent-experience navigation-time-exp
    :specification (roll:with-binding ( (p1 (:var start-pose :begin))
                                        (p2 (:var goal-pose :begin))
                                        (timediff (- (:var timestep :end)
                                                     (:var timestep :begin)))
                                        (offset-angle (angle-towards-point p1 p2)) )
                     (roll:with-filter (plusp timediff)
                       (nil
                         :begin ( (dist (tf:v-dist (tf:origin p1) (tf:origin p2)))
                                  (start-phi (tf:angle-between-quaternions offset-angle (tf:orientation p1)))
                                  (end-phi (tf:angle-between-quaternions offset-angle (tf:orientation p2))) )
                                  ; Rechnungen evtl. nochmal prüfen, Vorzeichen könnte falsch sein
                         :end ( (navigation-time timediff) ))))
    :experience-class roll:format-experience)


  ; test for intervals in database
  (roll:define-abstract-experience nav-interval-abstract-exp
    :parent-experience navigation-time-exp
    :specification (roll:with-binding ( (robot-position (mapcar #'cl-tf:origin (:var robot-pose :interval)))
                                        (start-pos (cl-tf:origin (:var start-pose :begin)))
                                        (goal-pos (cl-tf:origin (:var goal-pose :begin))) )
                     (nil
                       :begin ( (start-x (cl-tf:x start-pos))
                                (start-y (cl-tf:y start-pos))
                                (start-z (cl-tf:z start-pos))
                                (goal-x (cl-tf:x goal-pos))
                                (goal-y (cl-tf:y goal-pos))
                                (goal-z (cl-tf:z goal-pos)) )
                       :end ( (navigation-time (- (:var timestep :end)
                                                  (:var timestep :begin))) )
                       :interval ( (x (mapcar #'cl-tf:x robot-position))
                                   (y (mapcar #'cl-tf:y robot-position))
                                   (az (mapcar (alexandria:compose
                                                 #'cl-tf:z
                                                 #'cl-tf:quaternion->axis-angle
                                                 #'cl-tf:orientation)
                                               (:var robot-pose :interval))) )))
    :experience-class roll:database-experience
    :experience-class-initargs
      (:database (make-instance 'roll:mysql-database :host "sqlradig" :user "kirsch"
                                                     :user-pw "rolagi" :name "rollagilo")))

  ; test showing raw data
  (roll:define-abstract-experience navigation-time-exp-format
    :parent-experience navigation-time-exp
    :specification (nil
                     :begin ( (start-pose (:var start-pose :begin))
                              (goal-pose (:var goal-pose :begin))
                              (timestep (:var timestep :end)) )
                     :end ( (timestep (:var timestep :end)) ))
    :experience-class roll:format-experience)



  ; test for reading data from DB
  (roll:define-abstract-experience interval-test-read-exp
    :parent-experience nav-interval-abstract-exp
    :specification (nil
                     :begin ( (start-x (:var start-x :begin)) )
                     :end ( (nav-time (:var navigation-time :end)) )
                     :interval ( (robot-x (:var x :interval)) ))
    :experience-class roll:format-experience)


  ;; Learning Problems

  ; SVM
  (roll:define-learning-problem
    :function (:some-function jido-go2pose-time-model-svm pose)
    :use-experience (:parent-experience nav-time-abstract-exp
                     :specification (nil
                                       :begin ( (dist (:var dist :begin))
                                                (start-phi (:var start-phi :begin))
                                                (end-phi (:var end-phi :begin)) )
                                       :end ( (navigation-time (:var navigation-time :end)) ))
                     :experience-class roll:libsvm-experience)
    :learning-system (roll:libsvm
                       :learned-dir (append (pathname-directory (user-homedir-pathname))
                                  '("tmp" "roll"))
                       :model-dir (append (pathname-directory (user-homedir-pathname))
                                  '("tmp" "roll"))
                       :parameters '(:kernel-type :rbf))
    :input-conversion (:generate
                        (:in-experience navigation-time-exp
                          :set-var goal-pose :to pose))
    :output-conversion (navigation-time))

  ; Decision Tree
  (roll:define-learning-problem
    :function (:some-function jido-go2pose-time-model-tree pose)
    :use-experience (:parent-experience nav-time-abstract-exp
                     :specification (nil
                                       :begin ( (dist (:var dist :begin))
                                                (start-phi (:var start-phi :begin))
                                                (end-phi (:var end-phi :begin)) )
                                       :end ( (navigation-time (:var navigation-time :end)) ))
                     :experience-class roll:weka-experience
                     :experience-class-initargs
                       (:attribute-types '((dist numeric) (start-phi numeric) (end-phi numeric) (navigation-time numeric))))
    :learning-system (roll:weka-m5prime
                       :root-dir (append (pathname-directory (user-homedir-pathname))
                                  '("tmp" "roll"))
                       :data-dir (append (pathname-directory (user-homedir-pathname))
                                 '("tmp" "roll" "weka")))
    :input-conversion (:generate
                        (:in-experience navigation-time-exp
                          :set-var goal-pose :to pose))
    :output-conversion (navigation-time))


  ; Neural Net
  (roll:define-learning-problem
    :function (:some-function jido-go2pose-time-model-snns pose)
    :use-experience (:parent-experience nav-time-abstract-exp
                     :specification (nil
                                       :begin ( (dist (- (/ (:var dist :begin) 1.3) 1.25))
                                                (start-phi (- (/ (:var start-phi :begin) 3.03) -0.12))
                                                (end-phi (- (/ (:var end-phi :begin) 3.05) -0.03)) )
                                       :end ( (navigation-time (- (/ (:var navigation-time :end) 525.0) 2.3)) ))
                     :experience-class roll:snns-experience)
    :learning-system (roll:snns
                       :root-dir (append (pathname-directory (user-homedir-pathname))
                                  '("tmp" "roll"))
                       :data-dir (append (pathname-directory (user-homedir-pathname))
                                  '("tmp" "roll"))
                       :c-source-dir (append (pathname-directory (user-homedir-pathname))
                                  '("tmp" "roll"))
                       :foreign-function-dir (append (pathname-directory (user-homedir-pathname))
                                  '("tmp" "roll"))
                       :library-dir (append (pathname-directory (user-homedir-pathname))
                                  '("tmp" "roll"))
                       :hidden-layers '(2)
                       :net-learning-fun "Rprop"
                       :net-initialization-fun '("Randomize_Weights" 0.66 -0.66)
                       :unit-activation-fun "TanH"
                       :cycle-bias 300)
    :input-conversion (:generate
                        (:in-experience navigation-time-exp
                          :set-var goal-pose :to pose)))



)


