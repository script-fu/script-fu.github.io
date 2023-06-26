; bubble sorting from;
; https://stackoverflow.com/users/2860713/avery-poole
; https://stackoverflow.com/users/201359/%c3%93scar-l%c3%b3pez
; thanks!
(define (bubble-up lst)
  (if (null? (cdr lst))
    lst
     (if (< (car lst) (cadr lst))
       (cons (car lst) (bubble-up (cdr lst)))
         (cons (cadr lst) (bubble-up (cons (car lst) (cddr lst))))
     )
  )
)
(define (bubble-sort len lst)
  (cond ((= len 1) (bubble-up lst))
    (else (bubble-sort (- len 1) (bubble-up lst)))
  )
)