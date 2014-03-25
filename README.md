medusa
======

In Greek mythology Medusa was a monster, a Gorgon, generally described as having the face of a hideous human female with living venomous snakes in place of hair. Gazing directly upon her would turn onlookers to stone. Most sources describe her as the daughter of Phorcys and Ceto.

In modern software development, Medusa, a Gem, is generally described as the most beautiful parallel build system, evar. Running directly upon your servers will turn slow CI cycles to ash. Most sources describe her as the impossible daughter of Hydra, testbot, and test-queue (who says multiple inheritance is bad?).

Goals
=====

Phase 1 
- Clean up inner workings to provide streaming feedback and centralised result format from the master.
- Tidy the tests to the point that they run without any additional configuration.
- Worker or Runner errors propogate to master.
 
Phase 2
- Separate changes made to work with rails into an easy-to-use setup/generator (bundle local, requiring environment, etc)
- Running medusa on a new project should be as easy as running rspec.
- Runner artifact propogation to master.
  - Capture log file output for each runner.
  - Capture process statistics for the spec's run.
  - Capture shared resource load (DB load, etc)
  - Cucumber screenshot failures, HTML, etc.

Goals
- Running medusa on CI should be as simple as one command.
- Integrations for common CI platforms - TeamCity, Bamboo, Buildbot, Jenkins, etc.
- Integrations for common ruby platforms - Rails, Sinatra, etc.
- Ensure shared build machines (i.e. CI nodes) aren't flooded with too many runners/workers.
- Works with all the popular testing platforms.

One day...
- Worker/Runners for Java, Go, etc.
