;; (defn make-branch [^Integer length structure] {:length length :structure structure})
;; (defn make-mobile [left right] {:left left :right right})
;; (def b1 (make-branch 2 10))
;; (def b2 (make-branch 5 2))
;; (def m12 (make-mobile b1 b2))
;; (def b3 (make-branch 8 2))
;; (def b4 (make-branch 1 m12))
;; (def m34 (make-mobile b3 b4))

;; Recordを使う(hash-mapでもあまり変わらない)
(defrecord Branch [length structure]) ; structure = Integer | Mobile
(defrecord Mobile [left right]) ; Branch
(def b1 (Branch. 2 10))
(def b2 (Branch. 5 2))
(def m12 (Mobile. b1 b2))
(def b3 (Branch. 8 2))
(def b4 (Branch. 1 m12))
(def m34 (Mobile. b3 b4))

;; hash-mapを使わないならfnext(Scheme's cadr)が便利.
(defn left-branch  [mobile] (:left mobile))
(defn right-branch [mobile] (:right mobile))
(defn branch-length    [branch] (:length branch))
(defn branch-structure [branch] (:structure branch))

(defn has-weight? [x] (integer? (:structure x)))
(defn mobile? [x] (= (type x) user.Mobile)) ;; REPL namespace

;; 作った選択子を使わずrecordに直接アクセス
(defn total-weight [target]
  (cond (mobile? (:structure target)) (total-weight (:structure target))
        (has-weight? target) (:structure target)
        :else
        (+ (total-weight (:left target))
           (total-weight (:right target)))))

(defn torque [branch]
  (* (:length branch) (total-weight branch)))

(defn balanced? [mobile]
  (= (torque (:left mobile)) (torque (:right mobile))))

(def b10 (Branch. 1 10))
(def b11 (Branch. 5 2))
(def m1011 (Mobile. b10 b11))

