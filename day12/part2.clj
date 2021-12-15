(defn has-node?
  [node edge]
  (edge node))

(defn path-options
  [edges node]
  (filter (partial has-node? node) edges))

(defn remove-node
  [edges node]
  (remove (partial has-node? node) edges))

(defn small-cave?
  [node]
  (= node (clojure.string/lower-case node)))

(defn end?
  [node]
  (= node "end"))

(defn endpoint?
  [node]
  (or (= node "start") (end? node)))

(defn adjacent
  [node edge]
  (first (remove #{node} edge)))

(defn clean-edges
  [node edges edge]
  (if (small-cave? node) (remove-node edges node) edges))

(defn rename
  [cave node]
  (if (= node cave)
    (str 2 node)
    node))

(defn original-name
  [cave]
  (if (= \2 (get cave 0))
    (subs cave 1)
    cave))

(defn create-extension
  [edges cave]
  (mapv
    (comp set (partial mapv (partial rename cave)))
    (path-options edges cave)))

(defn small-caves
  [edges]
  (filter
    (partial small-cave?)
    (remove (partial endpoint?) (set (flatten (mapv seq edges))))))

(defn extend-edges
  [edges]
  (mapv (partial concat edges) (mapv (partial create-extension edges) (small-caves edges))))

(declare step)

(defn take-path
  [steps node edges]
  (def nsteps (conj steps (original-name node)))
  (if (end? node)
    [nsteps]
    (not-empty (mapcat (partial step nsteps node edges) (path-options edges node)))))

(defn step
  [steps node edges edge]
  (take-path steps (adjacent node edge) (clean-edges node edges edge)))

(defn explore
  [edges]
  (set (mapcat (partial take-path [] "start") edges)))

(def edges
  (->> (slurp "input.txt")
       clojure.string/split-lines
       (mapv (comp set (fn [l] (clojure.string/split l #"-"))))
       extend-edges
       ))

(println (count (explore edges)))
