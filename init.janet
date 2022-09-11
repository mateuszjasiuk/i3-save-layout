#!/usr/bin/env janet
(import spork/json :as json)

(defn- read-from-file!
  "Reads contents of file as a buffer."
  [file-path]
  (with [fl (file/open file-path)]
    (var lines @[])
    (loop [line :iterate (file/read fl :line)]
      (array/push lines line))
    (string/join lines)))

(defn- write-to-file!
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

(defn get-tree-string! []
  "Spawns i3-msg get_tree process and returns tree as a string."
  (let [p (os/spawn @("i3-msg" "-t" "get_tree")
                    :p
                    {:in :pipe :out :pipe})
        tree-string (:read (p :out) :all)]
    (:wait p)
    tree-string))

(defn- tuple->table [t]
  (apply table t))

(defn- array-of-tuples->table [aot]
  (->> aot
       (map tuple->table)
       (apply merge)))

(def- tree-keys ["id" "type" "nodes" "output"])

(defn- filter-keys [aot]
  (filter (fn [(k _)] (not= nil (index-of k tree-keys))) aot))

(defn- get-tree-entires
  "Recursively returns array of tables with specified keys."
  [res tree-json]
  (let [{"id" i "type" t "output" o "nodes" n} (->> (pairs tree-json)
                                                    filter-keys
                                                    array-of-tuples->table)
        nodes-res (mapcat (fn [tree-json] (get-tree-entires @[] tree-json)) n)]
    (array/concat (array/push res @{:id i :type t :output o}) nodes-res)))

(defn- filter-containers [t]
  (filter (fn[t] (and (= (get t :type) "con")
                      (not= (get t  :output) "__i3"))) t))

(defn save!
  "Parses and saves layout to file."
  []
  (->> (get-tree-string!)
       (json/decode)
       (get-tree-entires @[])
       (filter-containers)
       (json/encode)
       (save-layout! "/tmp/i3-layout")))


# i3-msg '[con_id=93910984132864] move container to output eDP-1'
(defn load!
  "Loades and parses a layout from file."
  [] 
  (-> (read-from-file! "/tmp/i3-layout")
      (json/decode)))


(comment (save!))
(comment (load!))

(defn main [& args]
    # You can also get command-line arguments through (dyn :args)
    (print "args: " ;(interpose ", " args)))
