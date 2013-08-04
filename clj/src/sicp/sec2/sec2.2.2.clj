;; count-leavesが動かない!
(defn count-leaves [x]
  (cond (nil? x) 0 ; null? => nil?
        (not (sequential? x)) 1 ; sequential?, list? どちらもだめ
        :else (+ (count-leaves (first x))   ; car => first
                 (count-leaves (rest x))))) ; cdr => rest

(def x (conj (list 3 4) (list 1 2))) ; => ((1 2) 3 4)
(count-leaves x)
;; => StackOverflowError   clojure.lang.RT.first (RT.java:577)
;; あれ?

(def x2 (conj (conj (conj nil 4) 3) (conj (conj nil 2) 1))) ; => ((1 2) 3 4)
(count-leaves x2)
;; => StackOverflowError   clojure.lang.RT.first (RT.java:577)

;; consとconjの違い.
;; http://qiita.com/T_Hash/items/c6db359b664178239306
(def z (cons (list 1 2) (list 3 4))) ; => ((1 2) 3 4)
(class z) ; => clojure.lang.Cons
(list? z) ; => false

(def y (conj (list 3 4) (list 1 2))) ; => ((1 2) 3 4)
(class y) ; => clojure.lang.PersistentList
(list? y) ; => true

