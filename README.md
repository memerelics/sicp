理解不足の問題
=====================================

### 問題2.6

チャーチ数

### 問題2.16

一般に等価な式が異なる答えになる理由を説明せよ. この欠点がない算術演算パッケージを作成することは出来るか, あるいは不可能かも考えよ.

よく出てくる決まった構文が出てきたら置き換える
なるべく誤差の伝播が少ない形式を選ぶというアルゴリズムもある。


### Huffman木

* 問題2.69 Huffman木を生成する手続きを書け.
* 問題2.71 記号の相対頻度が`1,2,4,...2^(n-1)`であるとして, N=5, N=10のHuffman木を書け.
* 問題2.72

`make-code-tree` を使い, 集合の最小重みの要素を順に合体させ, 要素がひとつになったら止める.

* ref: http://d.hatena.ne.jp/bowmoq/20090421/1240268588


### 多項式システム

* 問題2.88 多項式システムに減算処理を追加する.
* 問題2.90 "薄い"多項式と"濃い"多項式の両方を扱うシステムを作る.
* 問題2.91 多項式の割り算. 素因数分解する必要がある.
* 問題2.92 変数に順序(index?)を付けて多項式パッケージを拡張し, 異なる変数の多項式とでも加算/乗算ができるようにせよ.


### 問題3.19

リストのcdrを調べ, 循環が含まれるかどうか判定する手続き(問題3.18)...を, 高速化する戦略.

* ref(基本戦略): http://d.hatena.ne.jp/mmitou/20100427/1272336295
* ref(解答例): http://wizardbook.wordpress.com/2010/12/16/exercise-3-19/


### 問題3.23

デキュー(deque: double-ended queue) を実装する.
デキューは項目が先頭と末尾のどちらでも挿入/削除が可能な並び.
すべての演算は `O(1)` ステップで完了する実装でなければならない.


### 問題3.26

二進木で表(table)を組織化し, 巨大データも効率良く扱えるようにする.


### 問題3.46

test-and-set!を通常の手続き(演算を不可分化しない)で実装した場合, 相互排除器(mutex)が破綻することを示せ.

![](https://www.evernote.com/shard/s11/sh/b079d381-9054-481a-91e5-c55247b7e5ca/591a9d1ab74448cfe152144e6be80ca7/res/246c6366-bb7f-4279-812b-74556dfd44a7/SICP%E5%95%8F%E9%A1%8C3.46%20-%20tmurata%E3%81%AE%E6%97%A5%E8%A8%98%20-%20ViFox%20%28Build%2020120713134347%29.jpg?resizeSmall&width=832)


### 冪級数

* 問題3.61

定数項が1の冪級数S(ref: 問題3.59)に対して
`S・X = 1` となる級数Xを見つけるには, 以下のように解けば良い

            S・X = 1
    (1 + S_R)・X = 1
      X + S_R・X = 1
               X = 1 - S_R・X

> 言い換えればXは定数項が1で, 高次の項は`S_R`掛けるXの符号を変えたものの冪級数である.
> この考え方を使い, 定数項が1の冪級数Sについて, `1/S`を計算する手続き`invert-unit-series`を書け.


* 問題3.62

問題3.60と問題3.61を使い, 二つの冪級数を割る手続き`div-series`を定義せよ.


### 問題3.64

引数としてstreamと数値(許容誤差) をとる`stream-limit`を定義せよ. 用例は以下.

    (define (sqrt x tolerance)
      (stream-limit (sqrt-stream x) tolerance))


### 問題4.36

`a-pythagorean-triple-between`は, 整数3ツ組`(i,j,k)`のうち, `i<=j`で`j^2+j^2=k^2` であるものを見つける手続き.
これを改良し, 無限にPythagras三角形を生成するような手続きを書け. 単に`an-integer-between`を`an-integer-starting-from`に書き換えただけでは動かない.


### 問題4.41

multiple-dwelling問題を解くための "通常の" Schemeプログラムを書け.

* ref: http://wqzhang.wordpress.com/2010/04/27/sicp-exercise-4-41/


### 問題4.44

非決定性計算amb評価器を使い, エイトクイーンパズルを解け... の理解.

    (define (safe? positions)
      (define (two-queens-safe? q1 q2)
        (let ((row1 (car q1))
              (col1 (cadr q1))
              (row2 (car q2))
              (col2 (cadr q2)))
          (and (not (= row1 row2))
               (not (= (- col2 col1)
                       (abs (- row2 row1)))))))
      (let ((new-queen (list (last positions) (length positions))))
        (define (check col positions)
          (cond ((null? (cdr positions)) true)
                ((two-queens-safe? (list (car positions) col)
                                   new-queen)
                 (check (+ col 1) (cdr positions)))
                (else false)))
        (check 1 positions)))


### 問題4.67

質問システム(`query-driver-loop`のやつ)にループ検知システムを実装せよ

> 一般的な考え方は, システムは現在の推論のある種の歴史を保持し, 既に作業した質問の処理を始めないようにするものである.
> この歴史にどのような情報(パターンやフレーム)を入れるべきか, またどうチェックしたらよいか述べよ.


### 問題5.28

本文中にある"末尾再帰じゃないバージョン"のev-sequenceを利用したところ
total-pushesとmaximum-depshが固定値になってしまう.
問題文的にはすべて線形増加になってほしいのに.


### 問題5.30

評価器のエラーハンドリング


TODOs
===================================================================

    neon $ git grep TODO

    my_defs.scm:17:; TODO: extend average so that it can be used with any number of arguments
    sec2/q2.39.scm:21:; TODO: appendを使わないパターン
    sec2/sicp/sec2.4.3-message-passing.scm:20:;; TODO: => q2.75, 2.76
    sec3/q3.61.scm:3:;; TODO
    sec3/q3.62.scm:1:;; TODO
    sec3/q3.64.scm:7:;; TODO
    sec3/q3.65.scm:5:               (stream-map - (ln2-summands ...TODO))))
    sec3/q3.71.scm:39:;; TODO: in Haskell
    sec3/sec3.1.2.scm:8:  ;... TODO
    sec3/sec3.2.4.scm:16:;; TODO: 図3.11


Clojure
===================================================================

On 2nd lap, I'd like to use Clojure.

    $ cd clj
    $ lein deps

