(declare-project
  :name "i3-save-layout"
  :description "Lib that saves and restores i3 layout"

  # Optional urls to git repositories that contain required artifacts.
  :dependencies ["https://github.com/janet-lang/spork.git"
                 "https://github.com/pyrmont/testament"])

(declare-source
  # :source is an array or tuple that can contain
  # source files and directories that will be installed.
  # Often will just be a single file or single directory.
  :source ["init.janet"])

(declare-executable
 :name "i3-save-layout"
 :entry "init.janet"
 :install false)
