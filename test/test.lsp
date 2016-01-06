; test comment

(println core)
(asserteq 3 3)
(assert (!= 3 4))
(asserteq (3 (+ 3 3) (- 3 3)) (3 6 0))

(asserteq -3 -3)
(asserteq (1 2) (1 2))
(asserteq (1 . 2) (1 . 2))
(asserteq (1 . 2) (cons 1 2))
(assert (not (== (1 . 2) (1 . 3))))
(asserteq (list a b c) (a b c))
(assert (!= (1 . 2) (1 . 3)))
(assert (!= (1 1) (1 2)))
(assert (> 10 7))
(assert (< 1 4))
(assert (> 10 -4))
(assert (< -1 40))

(asserteq (+ 1.1 1.1) 2.2)
(assert (> 10.1 7.2))
(assert (< 1.5 4.77))
(assert (> 10.0 -4.99))
(assert (< -1.56 40.732))

(asserteq (len (1 2 3)) 3)
(asserteq (len ()) 0)
(asserteq (len nil) 0)
(asserteq (len true) 0)
(asserteq (len len) 0)
(asserteq (len [1 2 3]) 3)

(asserteq (and true true) true)
(asserteq (and 1 true) true)
(asserteq (and true 1) true)
(asserteq (and true nil) nil)
(asserteq (and nil true) nil)
(asserteq (and nil 1) nil)
(asserteq (and nil nil) nil)

(asserteq (or true true) true)
(asserteq (or 1 true) true)
(asserteq (or true 1) true)
(asserteq (or true nil) true)
(asserteq (or nil true) true)
(asserteq (or nil 1) true)
(asserteq (or nil nil) nil)

; comments?

(println types)
(asserteq (eval (quote (+ 3 4))) 7)
(assert (is (type print) fn1))
(assert (is (type 3) int))
(assert (is (type foo) symbol))
(assert (not (is (1 2) (1 2))))
(assert (isinstance 3 int))
(assert (isinstance 3 symbol))
(assert (isinstance foo symbol))
(asserteq (3 . (4 . (5 . nil))) (3 4 5))
(asserteq (1 2 3) (1 2 3))
(assert (not (== (1 2 3) (1 3 5))))
(assert (not (!= (1 2) (1 2))))
(assert (!= (1 2) (3 4)))
(assert (!= (1 2) (1 2 3)))
(asserteq (apply cons (3 4)) (3 . 4))
(asserteq (apply ((a b) (cons a b)) (3 4)) (3 . 4))

(asserteq (eval (cons 3 4)) (3 . 4))
(assert (isinstance (time) int))

(println flow)

(asserteq (if true (1) (2)) 1)
(asserteq (if nil (1) (2)) 2)
(asserteq (if (== 3 4) ((cons 1 2))) nil)
(asserteq (if (== 4 4) ((cons 1 2))) (1 . 2))
(asserteq (if (== 4 4) ((cons 1 2)) ((cons 3 4))) (1 . 2))
(asserteq (if (== 4 5) ((cons 1 2)) ((cons 3 4))) (3 . 4))
(asserteq (if (!= 4 4) ((cons 1 2)) ((cons 3 4))) (3 . 4))

(set j nil)
(asserteq (do 4 (set j (cons 3 j))) (3 3 3 3))
(asserteq j (3 3 3 3))

(set k nil)
(set l nil)
(asserteq (do 4 (set l (cons 4 l)) (set k (cons 3 k))) (3 3 3 3))
(asserteq k (3 3 3 3))
(asserteq l (4 4 4 4))

(set m nil)
(set n nil)
(asserteq (for o 0 4 (set m (cons o m)) (set n (cons 8 n))) (8 8 8 8))
(asserteq m (3 2 1 0))
(asserteq n (8 8 8 8))

(set p nil)
(asserteq (for i (1 2 3) (set p (cons i p))) (3 2 1))
(asserteq p (3 2 1))

(asserteq (for q 0 10 (collect q)) (9 8 7 6 5 4 3 2 1 0))

(println xectors)
(assert (all (== [1 2 3] [1 2 3])))
(assert (!= [1 2 3] [4 5 6]))
(assert (all (== (+ [1 2 3] [4 5 6]) [5 7 9])))
(assert (all (== (+ (fill 1 3) (fill 1 3)) [2 2 2])))
(assert (all [1 1 1]))
(assert (not (all [0 0 0])))
(assert (not (all [1 1 0])))
(assert (any [1 0 0]))
(assert (any [1 1 1]))
(assert (not (any [0 0 0])))

(all (== (+ (fill 1.1 100) (fill 2.2 100)) (fill 3.3000000000000003 100)))
(assert (all (== (+ [1 2 3] [4 5 6]) [5 7 9])))
(assert (all (== (+ (fill 1 3) (fill 1 3)) [2 2 2])))
(assert (all [1 1 1]))
(assert (not (all [0 0 0])))
(assert (not (all [1 1 0])))
(assert (any [1 0 0]))
(assert (any [1 1 1]))
(assert (not (any [0 0 0])))

(println vars)
(set x 1)
(set y 2)
(set z (+ x y))
(asserteq x 1)
(asserteq y 2)
(asserteq z 3)

(set a [1 2 3])
(set b [2 3 4])
(set c (+ a b))
(assert (all (== a [1 2 3])))
(assert (all (== b [2 3 4])))
(assert (all (== c [3 5 7])))
(assert (not (any (== c a))))
(assert (not (all (== a [1 2 4]))))
(assert (any (== a [1 2 4])))

(set a [1 2 3])
(set b [2 3 4])
(assert (all (== (+= a b) [3 5 7])))
(assert (all (== a [3 5 7])))
(assert (all (== b [2 3 4])))

(set a [1 2 3])
(set b [2 3 4])
(assert (all (== (-= a b) [-1 -1 -1])))
(assert (all (== a [-1 -1 -1])))
(assert (all (== b [2 3 4])))

(set a [1 2 3])
(set b [2 3 4])
(assert (all (== (*= a b) [2 6 12])))
(assert (all (== a [2 6 12])))
(assert (all (== b [2 3 4])))

(set a [20 33 28])
(set b [2 3 4])
(assert (all (== (/= a b) [10 11 7])))
(assert (all (== a [10 11 7])))
(assert (all (== b [2 3 4])))

(println funcs)

(def foo (a b) (+ a b))
(asserteq (foo 3 4) 7)

(assert (is (type foo) user))
(asserteq (car foo) (quote (a b)))
(asserteq (car (cdr foo)) (quote (+ a b)))

(def ff (x) (if x ((+ (car x) (ff (cdr x)))) (0)))
(asserteq (ff (range 0 100 1)) 4950)

(set e 3)
(set f 4)
(def x (e f) (* e f))
(asserteq (x 5 6) 30)
(asserteq e 3)
(asserteq f 4)

(println passed)
