(declare-project
  :name "i3-save-layout"
  :description "Lib that saves and restores i3 layout"

  # Optional urls to git repositories that contain required artifacts.
  :dependencies ["https://github.com/janet-lang/spork.git"])

(declare-source
  # :source is an array or tuple that can contain
  # source files and directories that will be installed.
  # Often will just be a single file or single directory.
  :source ["main.janet"])

(declare-executable
 :name "i3-save-layout"
 :entry "main.janet"
 :install false)
