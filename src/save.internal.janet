# save.inter.janet
# Holds all the private functions of save.janet

(defn get-tree-string!
  "Spawns i3-msg get_tree process and returns tree as a string."
  []
  (let [p (os/spawn @("i3-msg" "-t" "get_tree")
                    :p
                    {:in :pipe :out :pipe})
        tree-string (:read (p :out) :all)]
    (:wait p)
    tree-string))

(defn tuple->table [t]
  (apply table t))

(defn array-of-tuples->table [aot]
  (->> aot
       (map tuple->table)
       (apply merge)))

(def- tree-keys ["id" "type" "nodes" "output" "name"])

(defn filter-keys [aot]
  (filter (fn [(k _)] (not= nil (index-of k tree-keys))) aot))

(defn containers-by-workspaces
  "Recursively returns array of tables with specified keys."
  [tree-json]
  (let [node (->> (pairs tree-json)
                  filter-keys
                  array-of-tuples->table)
        {"type" t "name" nm "nodes" no "id" id} node
        nodes-length (length no)]
    (cond 
      (= t "root")
      (map (fn [tree-json] (containers-by-workspaces tree-json)) no)

      (= t "output")
      {(get node "name") (mapcat (fn [tree-json] (containers-by-workspaces tree-json)) no)}

      (and (= t "con") (pos? nodes-length))
      (map (fn [tree-json] (containers-by-workspaces tree-json)) no)

      (= t "workspace")
      {:name nm
       :containers (mapcat (fn [tree-json] (containers-by-workspaces tree-json)) no)}

      (and (= t "con") (zero? nodes-length))
      @{:id (get node "id")}

      # Any other node type
      @[])))

(defn filter-outputs
  "We ignore __i3 output."
  [containers]
  (filter (fn[c] (let [output (-> c keys first)]
                   (not= output "__i3")))
          containers))

(defn write-to-file!
  "Writes buffer to a file."
  [file-path buf]
  (with [fl (file/open file-path :w)]
    (file/write fl buf)))

(defn save-layout!
  "Creates new file and writes to it."
  [file-path buf]
  (do (os/shell (string "touch " file-path))
    (os/rm file-path)
    (os/shell (string "touch " file-path))
    (write-to-file! file-path buf)))

