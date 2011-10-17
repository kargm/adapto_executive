(defsystem integration-test
  :depends-on (adapto-executive
               designators
               ;; unit testing framework also included in sbcl
               #+sbcl sb-rt
               #-sbcl rtest
               )
  :components
  ((:file "package")
   (:file "tutorial-tests-suite" :depends-on ("package"))))