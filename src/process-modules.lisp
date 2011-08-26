(in-package :ad-exe)

;; registers the process modules aliases for this executive

;; (cpm:process-module-alias :ptu 'fake-process-modules:fake-ptu)
(cpm:process-module-alias :ptu 'mjido-pm:morse-jido-ptu-process-module)
;(cpm:process-module-alias :manipulation 'mjido-pm:morse-jido-manip-process-module)
(cpm:process-module-alias :manipulation 'fake-process-modules:fake-manipulation)
(cpm:process-module-alias :perception 'fake-process-modules:fake-perception)
;; todo replace above with real PMs
(cpm:process-module-alias :navigation 'mjido-pm:morse-jido-navigation-process-module)