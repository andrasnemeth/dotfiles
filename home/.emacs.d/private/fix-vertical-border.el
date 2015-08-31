;; vertical border fix

;; Reverse colors for the border to have nicer line
(set-face-inverse-video-p 'vertical-border nil)
(set-face-background 'vertical-border (face-background 'default))

;; Set symbol for the border
(set-display-table-slot standard-display-table
                        'vertical-border
                        (make-glyph-code ?┃))
(set-display-table-slot buffer-display-table
                        'vertical-border
                        (make-glyph-code ?┃))
