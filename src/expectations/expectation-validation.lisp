(in-package :ad-exe)

;; helper function to calculate average value of a list of numbers
(defun average (args)
  (when args
    (/ (apply #'+ args) (length args))))

;; Validate alle expectations in global structure
(defun validate-expectations ()
  (map-global-structure 'validate-expectation :expectations))

;; Continual validation of expectations every 2 seconds
(defun start-expectation-validation ()
  (let (( normalities (validate-expectations)) (average-normality 0))
    (setf average-normality (average normalities))
   (unless (null normalities)
     (format t "Expectation-Validation: ~s ~%" normalities)
     (format t "Average-normality: ~s ~%" average-normality)
     (cond
       ( (< average-normality 0.1) (format t "There MUST be something wrong!~%"))
       ( (< average-normality 0.25) (format t "I think there IS something wrong...~%"))
       ( (< average-normality 0.5) (format t "Hmmm there could be something wrong...~%")))
     (sleep 2)
     (start-expectation-validation))))
    