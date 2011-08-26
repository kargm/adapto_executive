(in-package :cl-user)

(desig-props:def-desig-package :adapto-executive-tests
  (:documentation "Package for the adapto test-suite")
  (:nicknames :ad-exe-tests)
  (:use #:cpl
        #:cram-plan-library
        #:desig
        ;; rtest included in sbcl, also available freely
        #+sbcl :sb-rt #-sbcl :rtest
        #:alexandria)
  (:export
   ;; main function used by binary
   #:integration-tests-main)
  (:desig-properties #:pose #:reach-location))