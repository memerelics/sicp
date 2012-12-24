;;;   5.2 レジスタ計算機シミュレータ
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; controllerの演算をシミュレートしてくれるプログラムを作成する. こんなイメージ.
;    (make-machine <register-names> <operations> <controller>)
;    (set-register-contents! <machine-model> <register-name> <value>)
;    (get-register-contents <machine-model> <register-names>)
;    (start <machine-model>)

;; => q5.7.scm -- このシミュレータを使い, q5.4.scm で設計した計算機をテストせよ

;;;     5.2.1 計算機モデル machine-model
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; machine
;; machineはdispatchでコマンド渡してOOP的に動かす3章のアレのようだ.
;; 未知: make-new-machine, assemble
(define (make-machine register-names ops controller-text)
  (let ((machine (make-new-machine)))
    (for-each (lambda (register-name)
      ((machine 'allocate-register) register-name))
              register-names)
    ((machine 'install-operations) ops)
    ((machine 'install-instruction-sequence)
     (assemble controller-text machine))
    machine))

;;; register
(define (make-register name)
  (let ((contents '*unassigned*))
    (define (dispatch message)
      (cond ((eq? message 'get) contents)
            ((eq? message 'set)
             (lambda (value) (set! contents value)))
            (else
              (error "Unknown request -- REGISTER" message))))
    dispatch))

(define (get-contents register)
  (register 'get))

(define (set-contents! register value)
  ((register 'set) value))


;;; stack
;; 局所状態を持つ手続きとして表現できる.
(define (make-stack)
  (let ((s '()))
    (define (push x)
      (set! s (cons x s)))
    (define (pop)
      (if (null? s)
        (error "Enpty stack -- POP")
        (let ((top (car s)))
          (set! s (cdr s))
          top)))
    (define (initialize)
      (set! s '())
      'done)
    (define (dispatch message)
      (cond ((eq? message 'push) push)
            ((eq? message 'pop) (pop)) ;; popの時は()で囲う訳は?
            (else (error "Unknown request -- STACK"
                         message))))
    dispatch))

(define (pop stack) (stack 'pop))
(define (push stack value) ((stack 'push) value))


;;; 基本計算機
;; make-new-machine 手続きは, machine オブジェクトを作成する.
;; machine は局所状態としてregister table (初期値はflagとpc(= program cunter))を持つ.
;; machine は局所状態として演算リスト, 空の命令列なども持つ.
(define (make-new-machine)
  (let ((pc (make-register 'pc))
        (flag (make-register 'flag))
        (stack (make-stack))
        (the-instruction-sequence '()))
    ;; the-opsの定義にstackを, register-tableの定義にpc,flagを使うため二重let.
    ;; Gaucheにはlet*というのがあるが.
    (let ((the-ops
            (list (list 'initialize-stack
                        (lambda () (stack 'initialize)))))
          (register-table
            (list (list 'pc pc) (list 'flag flag))))
      (define (allocate-register name)
        (if (assoc name register-table)
          (error "Multiply defined register: " name)
          (set! register-table
            (cons (list name (make-register name))
                  register-table)))
        'register-allocated)
      (define (lookup-register name)
        (let ((val (assoc name register-table)))
          (if val
            (cadr val) ;; これで取れるということはどういう構造になってる?
            (error "Unknown register:" name))))
      (define (dispatch message)
        (cond ((eq? message 'start)
               (set-contents! pc the-instruction-sequence)
               (execute))
              ((eq? message 'install-instruction-sequence)
               (lambda (seq) (set! the-instruction-sequence seq)))
              ((eq? message 'allocate-register) allocate-register)
              ((eq? message 'get-register) lookup-register)
              ((eq? message 'install-operations)
               (lambda (ops) (set! the-ops (append the-ops ops))))
              ((eq? message 'stack) stack)
              ((eq? message 'operations) the-ops)
              (else (error "Unknown request -- MACHINE" message))))
      dispatch)))

;;; 以下, machineを使ういくつかの手続き.
;; assemble: machineモデルに格納すべき命令列をcontroller-textから抽出して返す.
(define (assemble controller-text machine)
  (extract-labels controller-text ; [new] extract-labels
                  (lambda (insts labels)
                    (update-insts! insts labels machine) ; [new] update-insts!
                    insts)))

(define (extract-labels text receive)
  (if (null? text)
    (receive '() '())
    (extract-labels (cdr text)
                    (lambda (insts labels)
                      (let ((next-inst (car text)))
                        (if (symbol? next-inst)
                          (receive insts
                                   (cons (make-label-entry next-inst ; [new] make-label-entry
                                                           insts)
                                         labels))
                          (receive (cons (make-instruction next-inst) ; [new] make-instruction
                                         insts)
                                   labels)))))))

(define (update-insts! insts labels machine)
  (let ((pc (get-register machine 'pc))
        (flag (get-register machine 'flag))
        (stack (machine 'stack))
        (ops (machine 'operations)))
    (for-each
      (lambda (inst)
        (set-instruction-execution-proc! ; [new]
          inst
          (make-execution-procedure ; [new]
            (instruction-text inst) labels machine ; [new] instruction-text
            pc flag stack ops)))
      insts)))

(define (make-instruction text)
  (cons text '()))
(define (instruction-text inst)
  (car inst))
(define (instruction-execution-proc inst)
  (cdr inst))
(define (set-instruction-execution-proc! inst proc)
  (set-cdr! inst proc))

;; label表の要素は対
(define (make-label-entry label-name insts)
  (cons label-name insts))

;; 項目はlookup-labelを使って探す
(define (lookup-label labels label-name)
  (let ((val (assoc label-name labels)))
    (if val
      (cdr val)
      (error "Undefined label -- ASSENBLE" label-name))))

;; => q5.8.scm

;;;     5.2.3 命令の実行手続きの生成
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 4.1.7のanalyze同様, 命令の型に従って処理を振り分ける.
(define (make-execution-procedure inst labels machine
                                  pc flag stack ops)
  (cond ((eq? (car inst) 'assign)
         (make-assign  inst machine labels ops pc)) ; [new] make-assign
        ((eq? (car inst) 'test)
         (make-test    inst machine labels ops flag pc)) ; [new] make-test
        ((eq? (car inst) 'branch)
         (make-branch  inst machine labels flag pc)) ; [new] make-branch
        ((eq? (car inst) 'goto)
         (make-goto    inst machine labels pc)) ; [new] make-goto
        ((eq? (car inst) 'save)
         (make-save    inst machine stack pc)) ; [new] make-save
        ((eq? (car inst) 'restore)
         (make-restore inst machine stack pc)) ; [new] make-restore
        ((eq? (car inst) 'perform)
         (make-perform inst machine labels ops pc)) ; [new] make-perform
        (else (error "Unknown instruction type -- ASSENBLE"
                     inst))))

;;; assign命令に対する実行手続き ;;;
(define (make-assign inst machine labels operations pc)
  (let ((target
          (get-register machine (assign-reg-name inst))) ; [new] assign-reg-name
        (value-exp (assign-value-exp inst))) ; [new] assign-value-exp
    (let ((value-proc
            (if (operation-exp? value-exp) ; [new] operation-exp?
              (make-operation-exp ; [new] => さらに下
                value-exp machine labels operations)
              (make-primitive-exp ; [new] => ちょっと下
                (car value-exp) machine labels))))
      (lambda ()
        (set-contents! target (value-proc))
        (advance-pc pc))))) ; [new] advance-pc

;; このふたつは単なるcadr系のalias.
(define (assign-reg-name assign-instruction)
  (cadr assign-instruction))
(define (assign-value-exp assign-instruction)
  (cddr assign-instruction))

(define (advance-pc pc)
  (set-contents! pc (cdr (get-contents pc))))


;;; test命令に対する実行手続き ;;;
(define (make-test inst machine labels operations flag pc)
  (let ((condition (test-condition inst))) ; [new] test-condition
    (if (operation-exp? condition)
      (let ((condition-proc
              (make-operation-exp
                condition machine labels operations)))
        (lambda ()
          (set-contents! flag (condition-proc))
          (advance-pc pc)))
      (error "Bad TEST instruction -- ASSENBLE" inst))))

(define (test-condition test-instruction)
  (cdr test-instruction))

;;; branch命令に対する実行手続き ;;;
(define (make-branch inst machine labels flag pc)
  (let ((dest (branch-dest inst))) ; [new] branch-dest
    (if (label-exp? dest) ; [new] label-exp?
      (let ((insts
              (lookup-label labels (label-exp-label dest)))) ; [new] label-exp-label
        (lambda ()
          (if (get-contents flag)
            (set-contents! pc insts)
            (advance-pc pc))))
      (error "Bad BRANCH instruction -- ASSENBLE" inst))))

(define (branch-dest branch-instruction)
  (cadr branch-instruction))

;;; goto命令に対する実行手続き ;;;
(define (make-goto inst machine labels pc)
  (let ((dest (goto-dest inst))) ; [new] goto-dest
    (cond ((label-exp? dest)
           (let ((insts
                   (lookup-label labels
                                 (label-exp-label dest))))
             (lambda () (set-contents! pc insts))))
          ((register-exp? dest) ; [new]
           (let ((reg
                   (get-register machine
                                 (register-exp-reg dest)))) ; [new] register-exp-reg
             (lambda ()
               (set-contents! pc (get-contents reg)))))
      (else (error "Bad GOTO instruction -- ASSENBLE"
                   inst)))))

(define (goto-dest goto-instruction)
  (cadr goto-instruction))


;;; その他(save, restore, perform)の命令に対する実行手続き ;;;
(define (make-save inst machine stack pc)
  (let ((reg (get-register machine
                           (stack-inst-reg-name inst)))) ; [new]
    (lambda ()
      (push stack (get-contents reg))
      (advance-pc pc))))

(define (make-restore inst machine stack pc)
  (let ((reg (get-register machine
                           (stack-inst-reg-name inst))))
    (lambda ()
      (set-contents! reg (pop stack))
      (advance-pc pc))))

(define (stack-inst-reg-name stack-instruction)
  (cadr stack-instruction))

(define (make-perform inst machine labels operations pc)
  (let ((action (perform-action inst))) ; [new] perform-action
    (if (operation-exp? action)
      (let ((action-proc
              (make-operation-exp
                action machine labels operations)))
        (lambda ()
          (action-proc)
          (advance-pc pc)))
      (error "Bad PERFORM instruction -- ASSEMBLE" inst))))

(define (perform-action inst) (cdr inst))


;;; 部分式の実行手続き ;;;
(define (make-primitive-exp exp machine labels)
  (cond ((constant-exp? exp); [new]
         (let ((c (constant-exp-value exp))) ; [new] constant-exp-value
           (lambda () c)))
        ((label-exp? exp)
         (let ((insts
                 (lookup-label labels
                               (label-exp-label exp))))
           (lambda () insts)))
        ((register-exp? exp)
         (let ((r (get-register machine
                                (register-exp-reg exp))))
           (lambda () (get-contents r))))
    (else
      (error "Unknown expression type -- ASSENBLE" exp))))

;; tagged-list? は昔定義したのを持ってくる?
(define (register-exp? exp) (tagged-list? exp 'reg))
(define (register-exp-reg exp) (cadr exp))
(define (constant-exp? exp) (tagged-list? exp 'const))
(define (constant-exp-value exp) (cadr exp))
(define (label-exp? exp) (tagged-list? exp 'label))
(define (label-exp-label exp) (cadr exp))


(define (make-operation-exp exp machine labels operations)
  (let ((op (lookup-prim (operation-exp-op exp) operations)) ; [new] lookup-prim, operation-exp-op
        (aprocs
          (map (lambda (e)
            (make-primitive-exp e machine labels))
               (operation-exp-operands exp)))) ; [new] operation-exp-operands
    (lambda ()
      (apply op (map (lambda (p) (p)) aprocs)))))

(define (operation-exp? exp)
  (and (pair? exp) (tagged-list? (car exp) 'op)))
(define (operation-exp-op operation-exp)
  (cadr (car operation-exp)))
(define (operation-exp-operands operation-exp)
  (cdr operation-exp))

(define (lookup-prim symbol operations)
  (let ((val (assoc symbol operations)))
    (if val
      (cadr val)
      (error "Unknown operation -- ASSEMBLE" symbol))))

;; => q5.9.scm, q5.10.scm, q5.11.scm, q5.12.scm, q5.13.scm
