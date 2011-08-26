(in-package :ad-exe)

(eval-when (:execute :load-toplevel)
  ;; Experiences

  ; raw experience
  (roll:define-raw-experience navigation-time-hierarchy-exp
      :specification (top
                       :task (:tagged my-tag)
                       :begin ( (timestep-top (get-universal-time)) )
                       :end ( (timestep-top (get-universal-time)) )
                       :children ( (nav
                                     :task (:plan at-location)
                                     ;:invariant (fl-funcall (alexandria:compose #'(lambda (x) (< x 0.7))  #'abs #'cl-tf:x #'cl-tf:origin #'pose) (getgv :robot 'jido))
                                                ;(< {abs {cl-tf:x {cl-tf:origin {pose (getgv :robot 'jido)}}}} 0.7)
                                     :begin ( (timestep (get-universal-time))
                                              (start-pose (pose [getgv :robot 'jido]))
                                              (goal-pose (:desig-value 'pose)) )
                                     :end ( (timestep (get-universal-time)) )) )))

  ; test showing raw data
  (roll:define-abstract-experience navigation-time-hierarchy-exp-format
    :parent-experience navigation-time-hierarchy-exp
    :specification (nil
                     :begin ( (start-top (:var timestep-top (:begin top)))
                              (start-times-nav (:var timestep (:begin nav) :all-occurrences)) )
                     :end ( (end-top (:var timestep-top (:end top)))
                            (end-times-nav (:var timestep (:end nav) :all-occurrences)) ))
    :experience-class roll:format-experience)


  ;; Learning Problems

)
