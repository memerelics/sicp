;; 本文中手続き<e3>を評価するにあたり,
;;   1. 定義を逐次的に解釈するとき
;;   2. 定義を変換して書きだした時
;; の環境構造の違いを述べよ.

;; http://sicp-study.g.hatena.ne.jp/papamitra/20070715/sicp_4_16
;; > 2の場合letがlambdaに変換されるため, 余分なframeがある.
;; > もし余分なframeを追加することなく同時(simultaneous)定義を行いたいなら, こうする.
(define (rearrange-defines body)
  (let ((defs '())
        (others '()))
    (let scan-iter ((b body))
      (cond ((null? b)
             '())
            ((definition? (car b))
             (set! defs (append defs (list (car b)))))
            (else
              (set! others (append others (list (car b))))))
      (if (not (null? b))
        (scan-iter (cdr b))))
    (if (null? defs)
      body
      (append defs others))))

(define (make-procedure parameters body env)
  (list 'procedure parameters (rearrange-defines body) env))


