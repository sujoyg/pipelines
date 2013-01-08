# 0.2.1
  * Feature: On screen logging displays thread number for a parallel block.
  * Feature: (Breaking change) Improve naming of cache files.

# 0.1.20
  * Fix: Tubes was not loading cached results on reruns.

# 0.1.19
  * Bug: run always returns nil, regardless of what the output was.

# 0.1.18
  * Feature: Use YAML instead of JSON for caching data.

# 0.1.17
  * Bug: present? is not available in vanilla ruby.

# 0.1.16
  * Bug: Do not require a directory.

# 0.1.15
  * Bug: Options were being passed in to invokes even if they were not present.
  * Bug: Cached output files were not being named correctly.

# 0.1.14
  * Feature: Ability to set and retrieve stats about the pipeline using set_stats and get_stats.
  * Bug: Options were not passed in with invoke.

# 0.1.13
  * Feature: Every invoked tube segment should get its own directory.

# 0.1.12
  * Bug: Catch all exceptions in invoke.

# 0.1.11
  * Feature: Adding unlocked_puts to print stuff while holding a lock.

# 0.1.10
  * Bug: Parallel and serial blocks where not setting their output correctly when themselves containing serial or parallel blocks.

# 0.1.9
  * Bug: Do not create a tracking directory for logs, lockfile and caches if one was not specified.

# 0.1.8
  * Feature: Input that will be used for the next segmment can now be queried from within the tube.

# 0.1.7
  * Bug: Cached results of parallel blocks were not being loaded properly.

# 0.1.6
  * Bug: Previous version did not include a complete fix.

# 0.1.5
  * Bug: Parallel block should not append its input to its final output.

# 0.1.4
  * Bug: `puts` in tubes was not returning nil.
  * Bug: The first invoked tube should not be passed any arguments unless explicitly specified.
# 0.1.3
  * Bug: Output of a parallel block should be a concatenation of the output from its constituents.

# 0.1.2
  * Feature: Options provided to invoke are passed to the corresponding tube.
  * Feature: If the main tube implements a notify method, it will be called after the main tube finishes execution. This is useful for notifying interested parties when a job is done.

# 0.1.1
  * Bug: Nested tubes were failing because of a conflict between global lock and thread lock.

# 0.1.0
  * Feature: Tubes create a lock in the working directory which is only removed on a successful completion. Attempts to run another instance while the lock exists will fail.

# 0.0.0
  * Feature: Introducing tubes, a way to design a pipeline of serial and parallel tasks.
