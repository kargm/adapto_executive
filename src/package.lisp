(in-package :cl-user)

(desig-props:def-desig-package adapto-executive
    (:nicknames :ad-exe)
  (:use #:cpl
        #:desig
        #:cram-plan-library;; contains achieve and maybe-run-process-modules
        )
  (:shadowing-import-from #:desig
                          #:name)
  (:import-from :cram-utilities
                #:map-global-structure #:create-global-structure #:remove-global-structure #:clear-global-structure
                #:addgv #:isgv #:getgv #:setgv #:remgv #:putgv)
  (:import-from :cram-roslisp-common
                #:startup-ros
                #:shutdown-ros)
  (:desig-properties
   ;; adapto
   #:reach-location
   ;; from designators
   #:obj #:location #:object #:pose #:of #:at #:type #:trajectory
   ;; from cram_plan_library
   #:to #:see #:reach #:open #:side
   #:grasp #:lift #:carry :reach #:at #:parked #:close
   #:gripper #:follow #:pick-up #:put-down #:height #:orientation #:in
   #:obstacle
   ))

;; All CRAM PROLOG code masks errors and treats them simply as false.
;; setting the var below to true raises errors in REPL instead. This
;; is a better default for adapto.
(setf crs:*break-on-lisp-errors* t)