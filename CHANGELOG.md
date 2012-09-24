# 0.1.2
  * Feature: Options provided to invoke are passed to the corresponding tube.
  * Feature: If the main tube implements a notify method, it will be called after the main tube finishes execution. This is useful for notifying interested parties when a job is done.

# 0.1.1
  * Bug: Nested tubes were failing because of a conflict between global lock and thread lock.

# 0.1.0
  * Feature: Tubes create a lock in the working directory which is only removed on a successful completion. Attempts to run another instance while the lock exists will fail.

# 0.0.0
  * Feature: Introducing tubes, a way to design a pipeline of serial and parallel tasks.
