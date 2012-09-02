;; The only difference is imprementation of "delay".

(define (force delayed-object)
  (delayed-object))

;; cons, car, cdr
(define-macro (cons-stream a b)
              `(cons ,a (delay ,b)))
(define (stream-car stream) (car stream))
(define (stream-cdr stream) (force (cdr stream)))

;; null
(define the-empty-stream '())
(define stream-null? null?)

;; display
(define (display-stream s)
  (stream-for-each display-line s))

(define (display-line x)
  (newline)
  (display x))


;; utils
(define (stream-for-each proc s)
  (if (stream-null? s)
    'done
    (begin (proc (stream-car s))
           (stream-for-each proc (stream-cdr s)))))

; (define (stream-map proc s)
;   (if (stream-null? s)
;     the-empty-stream
;     (cons-stream (proc (stream-car s))
;                  (stream-map proc (stream-cdr s)))))
;; ↓
;; stream-map is improved in *q3.50.scm
(define (stream-map proc . argstreams)
  (if (stream-null? (car argstreams))
    the-empty-stream
    (cons-stream
      (apply proc (map stream-car argstreams))
      (apply stream-map
             (cons proc (map stream-cdr argstreams))))))


(define (stream-ref s n)
  (if (= n 0)
    (stream-car s)
    (stream-ref (stream-cdr s) (- n 1))))

;; stream-enumerate-interval
(define (stream-enumerate-interval low high)
  (if (> low high)
    the-empty-stream
    (cons-stream
      low
      (stream-enumerate-interval (+ low 1) high))))

;; stream-filter
(define (stream-filter pred stream)
  (cond ((stream-null? stream) the-empty-stream)
        ((pred (stream-car stream))
         (cons-stream (stream-car stream)
                      (stream-filter pred
                                     (stream-cdr stream))))
        (else (stream-filter pred (stream-cdr stream)))))

