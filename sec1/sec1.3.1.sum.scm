;;; 1.3 高階手続きによる抽象
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(add-load-path ".")
(load "my_defs")

;;; 1.3.1 引数としての手続き

;; 1/(1*3) + 1/(5*7) + 1/(9*11) + ...という配列がPI/8に収束する.
(define (pi-sum a b)
  (if (> a b)
    0
    (+ (/ 1.0 (* a (+ a 2))) (pi-sum (+ a 4) b))
    )
  )

;  gosh> (* 8 (pi-sum 1 100))
;  3.1215946525910105
;  gosh> (* 8 (pi-sum 1 1000))
;  3.139592655589783

;; term = 手続き. procedure that applied to each item
;; next = how to jump to the next item (for ex: +1)
(define (sum term a next b)
  (if (> a b) ;; 終了条件はaがbを超えること
    0
    (+ (term a) ;; (いまの)aにtermを作用させたものを...
       (sum term (next a) next b)))) ;; 再帰的に足していく.

;; sumは抽象的な手続きとして定義した.
;; termとnextに無名手続きlambdaを渡すことでも使える.
;; gosh> (sum (lambda (x) x) 1 (lambda (x) (+ x 1)) 10)
;; 55

;; で, まあincとかidentity(そのまま返せばいいけど手続きという制限があるから)を定義してやって,
(define (inc n) (+ n 1))
(define (sum-cubes a b)
  (sum cube a inc b))

;(print (sum-cubes 1 10))

(define (identity x) x)

;; たとえば整数をaからbまで足し続けるsum-integersが定義できる.
(define (sum-integers a b)
  (sum identity a inc b))


(trace sum)
; (print (sum-integers 1 10))

; (trace sum) =>...
; CALL sum #[proc] 1 #[proc] 10
;   CALL sum #[proc] 2 #[proc] 10
;     CALL sum #[proc] 3 #[proc] 10
;       CALL sum #[proc] 4 #[proc] 10
;         CALL sum #[proc] 5 #[proc] 10
;         RETN sum 45
;       RETN sum 49
;     RETN sum 52
;   RETN sum 54
; RETN sum 55


;; 抽象的なsumを利用してさっきのpi-sumを作ってみる.
;; pi-sum with abstract procedure "sum".
(define (pi-sum2 a b)
  (define (pi-term x) ;; term: 各要素にどんな手続きを作用させるか
    (/ 1.0 (* x (+ x 2))))
  (define (pi-next x) ;; next: どういう基準で進めるか.
    (+ x 4))
  (sum pi-term a pi-next b))

;(print (* 8 (pi-sum2 1 100)))

; (use math.const)
; (print pi)


;; ここまでで学んだ抽象化手法を使って積分(integral)手続きも作ってみる.
(define (integral f a b dx)
  (define (add-dx x) (+ x dx)) ;; 微小値dxずつ進めていく(sumの引数nextに利用)
  (* (sum f (+ a (/ dx 2.0)) add-dx b)
     dx))

; (trace sum)
; (print (integral cube 0 1 0.001))

; この部分は1.3.2でlambdaを利用してもっと書きやすくなる。
