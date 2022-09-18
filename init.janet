#!/usr/bin/env janet
(import spork/json :as json)
(import ./src/save :prefix "")

(defn- read-from-file!
  "Reads contents of file as a buffer."
  [file-path]
  (with [fl (file/open file-path)]
    (var lines @[])
    (loop [line :iterate (file/read fl :line)]
      (array/push lines line))
    (string/join lines)))

(defn attach-container-to-workspace
  "Attach container(by id) to a specific workspace(by name)."
  [workspace-name container-id]
  (let [workspace-name (string/replace-all "\"" "'" workspace-name)
        p (os/spawn @("i3-msg" (string "[con_id=" container-id "]"
                                       " move workspace "
                                       "\"" workspace-name "\""))
                    :p)]
    (:wait p)))

(defn- move-workspace-to-output
  "Move workspace(by name) to the specific output."
  [workspace-name output]
  (let [p (os/spawn @("i3-msg" (string "[workspace=" "\"" workspace-name "\"" "]"
                                       " move workspace to output "
                                       output))
                    :p)]
    (:wait p)))

(defn- load-containers
  "Load containers, by moving them to workspace and attaching workspace to the output."
  [entry]
  (let [[output workspaces] (kvs entry)]
    (map (fn [{"containers" containers "name" name}]
           (do (map (fn [{"id" container-id}]
                      (attach-container-to-workspace name container-id))
                    containers)
             (move-workspace-to-output name output)))
         workspaces)))

(defn load!
  "Loades and parses a layout from file."
  [] 
  (->> (read-from-file! "/tmp/i3-layout")
       (json/decode)
       (map load-containers)))

(defn main [& args]
    (let [[_ action] (dyn :args)]
      (case action
        "--save" (save!)
        "--load" (load!)
        (print "Invalid action. Use \"--save\" or \"--load\""))))
