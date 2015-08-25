;; with separator: "d \u2502 "
(setq linum-format
      (lambda (line)
        (propertize (format
                     (let ((w (length (number-to-string (count-lines (point-min) (point-max))))))
                       (concat "%" (number-to-string w) "d ")) line) 'face 'linum)))

;(set-variable diff-hl-margin-side 'left)
