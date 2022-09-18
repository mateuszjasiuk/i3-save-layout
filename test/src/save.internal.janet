(import testament :prefix "" :exit true)
(import /src/save.internal :prefix "")


(deftest tuple->table 
  (is (== (tuple->table [:a :b]) @{:a :b})
      "[:a :b] -> @{:a :b}")
  (is (== (tuple->table []) @{})
      "[] -> @{}")
  (is (assert-thrown (tuple->table [:a :b :c]))
      "[:a :b :c] -> error (Uneven number of arguments)"))

(deftest array-of-tuples->table
  (is (== (array-of-tuples->table @[[:a :b]]) @{:a :b})
      "[[:a :b]] -> @{:a :b}")
  (is (== (array-of-tuples->table @[]) @{})
      "[] -> @{}")
  (is (assert-thrown (array-of-tuples->table @[[:a :b] [:c]]))
      "[[:a :b] :c] -> error (Uneven number of arguments)")
  (is (== (array-of-tuples->table @[[:a :b] [:a :c]]) @{:a :c})
      "[[:a :b] [:a :c]] -> @{:a :c}"))

(run-tests!)

