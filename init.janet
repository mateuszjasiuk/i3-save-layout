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

(defn get-tree-string!
  "Spawns i3-msg get_tree process and returns tree as a string."
  []
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

(def- tree-keys ["id" "type" "nodes" "output" "name"])

(defn- filter-keys [aot]
  (filter (fn [(k _)] (not= nil (index-of k tree-keys))) aot))

(defn- containers-by-workspaces
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
       :containers (map (fn [tree-json] (containers-by-workspaces tree-json)) no)}

      (and (= t "con") (zero? nodes-length))
      @{:id (get node "id")}

      # Any other node type
      @[]
      )))

(defn- filter-outputs [containers]
  (filter (fn[c] (let [output (-> c keys first)]
                   (not= output "__i3"))) containers))


(defn save!
  "Parses and saves layout to file."
  []
  (->> (get-tree-string!)
       (json/decode)
       (containers-by-workspaces)
       (filter-outputs)
       (json/encode)
       (save-layout! "/tmp/i3-layout")))

(defn attach-container-to-workspace
  [workspace-name container-id]
  (let [p (os/spawn @("i3-msg" (string "[con_id=" container-id "]"
                                       " move workspace \""
                                       workspace-name
                                       "\""))
                    :p)]
    (:wait p)))

(defn move-workspace-to-output
  [workspace-name output]
  (let [p (os/spawn @("i3-msg" (string "[workspace=" "\"" workspace-name "\"" "]"
                                       " move workspace to output "
                                       output))
                    :p)]
    (:wait p)))

(defn attach-containers [entry]
  (let [[output workspaces] (kvs entry)]
    (map (fn [workspace]
           (map (fn [{"id" container-id}]
                  (do (attach-container-to-workspace (get workspace "name") container-id)
                    (move-workspace-to-output (get workspace "name") output)))
                (get workspace "containers"))
           ) workspaces)))

(defn load!
  "Loades and parses a layout from file."
  [] 
  (->> (read-from-file! "/tmp/i3-layout")
       (json/decode)
       (map attach-containers)))

(defn main [& args]
    (let [[_ action] (dyn :args)]
      (case action
        "--save" (save!)
        "--load" (load!)
        (print "Invalid action. Use \"--save\" or \"--load\""))))
