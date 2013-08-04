;; (require '[clojure.contrib.math])
(require '[clojure.contrib.generic.math-functions :as math])

;; 補助関数
(defn positive? [x] (> x 0))
(defn negative? [x] (< x 0))
(defn average [a b] (/ (+ a b) 2.0))
(defn abs [x] (if (< x 0) (* x -1) x))
(defn close-enough? [a b] (< (abs (- b a)) 0.001))

;; search 本体
(defn search [f neg-point pos-point]
  (let [midpoint (average neg-point pos-point)]
    (if (close-enough? neg-point pos-point)
      midpoint
      (let [test-value (f midpoint)] ;; ここ忘れがち
        (cond
          (positive? test-value) (search f neg-point midpoint)
          (negative? test-value) (search f midpoint pos-point)
          :else midpoint)))))

(defn half-interval-method [f a b]
  (let [a-value (f a)
        b-value (f b)]
    (cond (and (negative? a-value) (positive? b-value)) (search f a b)
          (and (negative? b-value) (positive? a-value)) (search f b a)
          :else
            (throw (Exception. (str "Values are not of opposite sign" a b))))))

(half-interval-method math/sin 2.0 4.0)
;; => 3.14111328125

(def tolerance 0.00001)
(defn fixed-point [f first-guess]
  (defn close-enough? [v1 v2]
    (< (abs (- v1 v2)) tolerance))
  (defn my-try [guess] ;; cannot overwrite "try" in Clojure
    (let [next (f guess)]
      (if (close-enough? guess next)
        next
        (my-try next))))
  (my-try first-guess))

(fixed-point math/cos 1.0)
;; => 0.7390822985224024

;; y = sin(y) + cos(y)
(fixed-point #(+ (math/sin %) (math/cos %)) 1.0)
;; => 1.2587315962971173

