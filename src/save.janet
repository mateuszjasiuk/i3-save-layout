(import spork/json :as json)
(import ./save.internal :prefix "")

(defn save!
  "Parses and saves layout to file."
  []
  (->> (get-tree-string!)
       (json/decode)
       (containers-by-workspaces)
       (filter-outputs)
       (json/encode)
       (save-layout! "/tmp/i3-layout")))
