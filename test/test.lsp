; test comment

(println core)
(assert (== 3 3))
(assert (!= 3 4))
(assert (== (3 (+ 3 3) (- 3 3)) (3 6 0)))

(assert (== -3 -3))
(assert (== (1 2) (1 2)))
(assert (== (1 . 2) (1 . 2)))
(assert (== (1 . 2) (cons 1 2)))
(assert (not (== (1 . 2) (1 . 3))))
(assert (== (list a b c) (a b c)))
(assert (!= (1 . 2) (1 . 3)))
(assert (!= (1 1) (1 2)))
(assert (> 10 7))
(assert (< 1 4))
(assert (> 10 -4))
(assert (< -1 40))

(assert (== (+ 1.1 1.1) 2.2))
(assert (> 10.1 7.2))
(assert (< 1.5 4.77))
(assert (> 10.0 -4.99))
(assert (< -1.56 40.732))

(assert (== (len (1 2 3)) 3))
(assert (== (len ()) 0))
(assert (== (len nil) 0))
(assert (== (len true) 0))
(assert (== (len len) 0))
(assert (== (len [1 2 3]) 3))

(assert (== (and true true) true))
(assert (== (and 1 true) true))
(assert (== (and true 1) true))
(assert (== (and true nil) nil))
(assert (== (and nil true) nil))
(assert (== (and nil 1) nil))
(assert (== (and nil nil) nil))

(assert (== (or true true) true))
(assert (== (or 1 true) true))
(assert (== (or true 1) true))
(assert (== (or true nil) true))
(assert (== (or nil true) true))
(assert (== (or nil 1) true))
(assert (== (or nil nil) nil))

; comments?

(println types)
(assert (== (eval (quote (+ 3 4))) 7))
(assert (is (type print) fn1))
(assert (is (type 3) int))
(assert (is (type foo) symbol))
(assert (not (is (1 2) (1 2))))
(assert (isinstance 3 int))
(assert (isinstance 3 symbol))
(assert (isinstance foo symbol))
(assert (== (3 . (4 . (5 . nil))) (3 4 5)))
(assert (== (1 2 3) (1 2 3)))
(assert (not (== (1 2 3) (1 3 5))))
(assert (not (!= (1 2) (1 2))))
(assert (!= (1 2) (3 4)))
(assert (!= (1 2) (1 2 3)))
(assert (== (apply cons (3 4)) (3 . 4)))
(assert (== (eval (cons 3 4)) (3 . 4)))
(assert (isinstance (time) int))

(println flow)

(assert (== (if true 1 2) 1))
(assert (== (if nil 1 2) 2))
(assert (== (if (== 3 4) (cons 1 2)) nil))
(assert (== (if (== 4 4) (cons 1 2)) (1 . 2)))
(assert (== (if (== 4 4) (cons 1 2) (cons 3 4)) (1 . 2)))
(assert (== (if (== 4 5) (cons 1 2) (cons 3 4)) (3 . 4)))
(assert (== (if (!= 4 4) (cons 1 2) (cons 3 4)) (3 . 4)))

(set j nil)
(assert (== (do 4 (set j (cons 3 j))) (3 3 3 3)))
(assert (== j (3 3 3 3)))

(set k nil)
(set l nil)
(assert (== (do 4 (set l (cons 4 l)) (set k (cons 3 k))) (3 3 3 3)))
(assert (== k (3 3 3 3)))
(assert (== l (4 4 4 4)))

(set m nil)
(set n nil)
(assert (== (for o 0 4 (set m (cons o m)) (set n (cons 8 n))) (8 8 8 8)))
(assert (== m (3 2 1 0)))
(assert (== n (8 8 8 8)))

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
(assert (== x 1))
(assert (== y 2))
(assert (== z 3))

(set a [1 2 3])
(set b [2 3 4])
(set c (+ a b))
(assert (all (== a [1 2 3])))
(assert (all (== b [2 3 4])))
(assert (all (== c [3 5 7])))
(assert (not (any (== c a))))
(assert (not (all (== a [1 2 4]))))
(assert (any (== a [1 2 4])))

(println funcs)

(def foo (a b) (+ a b))

(assert (== (foo 3 4) 7))

(assert (is (type foo) user))
(assert (== (car foo) (quote (a b))))
(assert (== (car (cdr foo)) (quote (+ a b))))

(set e 3)
(set f 4)

(def x (e f) (* e f))
(assert (== (x 5 6) 30))
(assert (== e 3))
(assert (== f 4))

(println passed)
