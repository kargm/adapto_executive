(defsystem adapto-executive
  :depends-on (process-modules
               cram-plan-library
               cram-roslisp-common
               designators
               designators-ros
               #| adapto-designator |#
               morse-jido-pm
               cl-tf
               cram-plan-failures
               actionlib
               fake-process-modules
               move_base_msgs-msg
               nav_msgs-msg
               roll)
  :components
  ( (:file "package")
    (:file "top-level-plans" :depends-on ("package"))
    (:file "process-modules" :depends-on ("package"))
    (:module "state"
             :depends-on ("package")
             :serial T
             :components
             ( (:file "transform-extensions")
               (:file "state-reader-macros")
               (:file "geometry-objects")
               (:file "object-classes")
               (:file "state-variables")
               (:file "state-update") ))
    (:module "roll"
             :depends-on ("package" "state")
             :components
             ( (:file "nav-time-definitions")
               (:file "nav-time-plan" :depends-on ("nav-time-definitions"))
               (:file "nav-cmd-definitions")
               (:file "nav-cmd-plan" :depends-on ("nav-cmd-definitions"))))
    (:module "expectations"
             :depends-on ("package" "state")
             :serial T
             :components
             ( (:file "navigation-watchdog")
               (:file "area-classes")
               (:file "expectation-classes")
               (:file "expectation-models")
               (:file "expectation-validation")
               (:file "expectation-plans"))) ))


