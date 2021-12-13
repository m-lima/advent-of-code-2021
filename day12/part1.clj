(def edges
  (mapv
    (fn [l] (clojure.string/split l #"-"))
    (clojure.string/split-lines (slurp "input.txt"))))

(defn path-options
  [node edges]
  (keep (fn [edge] (if (.contains edge node) edge)) edges))

(defn remove-node
  [node edges]
  (remove (fn [edge] (if (.contains edge node) edge)) edges))

(defn single-visit?
  [node]
  (= node (clojure.string/lower-case node)))

(defn clean-edges
  [node edges edge]
  (if (single-visit? node) (remove-node node edges) edges))

(declare step)

(defn take-path
  [node edges]
  (if (= node "end")
    1
    (reduce + (mapv (partial step node edges) (path-options node edges)))))

(defn step
  [node edges edge]
  (take-path (first (remove #{node} edge)) (clean-edges node edges edge)))

(println (take-path "start" edges))
