;;; 1.3.2 lambdaを使う手続きの構築
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(add-load-path ".")
(load "my_defs")
(load "sec1.3.1.sum")

; sumの確認
;(print (sum cube 1 inc 3))

(define (pi-sum a b)
  (sum (lambda (x) (/ 1.0 (* x (+ x 2))))
       a
       (lambda (x) (+ x 4))
       b))

(print (* 8 (pi-sum 1 100)))
(display "---------")
(newline)

; 積分
(define (integral f a b dx)
  (* (sum f
          (+ a (/ dx 2.0))
          (lambda (x) (+ x dx))
          b)
     dx))

(print (integral square 0 1 0.001 ))

; (define (plus4 x) (+ x 4))
; は、以下と同じ
; (define plus4 (lambda (x) (+ x 4)))

;;; 局所変数letを作る

; pattern1: use function helper
(define (f x y)
  (define (f-helper a b) ;; 補助的な手続きで局所変数を束縛
    (+ (* x (square a b))
       (* y b)
       (* a b)))
  (f-helper (+ 1 (* x y))
            (- 1 y)))

; pattern2: use lambda. やってることは同じ
(define (f x y)
  ((lambda (a b)
    (+ (* x (square a b))
       (* y b)
       (* a b)))
   (+ 1 (* x y))
   (- 1 y)))

; pattern2': use let.
(define (f x y)
   (let ((a (+ 1 (* x y)))
         (b (- 1 y)))
     (+ (* x (square a b))
        (* y b)
        (* a b))))


; letはlamdaを使いやすくしただけのもの(syntax sugar)

; ちなみにlambdaではないが、aをletするときに
; define a (+ 1 (* x y))
; としても同じである。が、普通使わない。

